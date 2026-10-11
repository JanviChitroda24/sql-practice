# **Question 10:**

# You have two DataFrames:

# **`current_products`** (what's currently in the dimension table)
# | product_id | product_name | price | effective_date | end_date | is_current |
# |-----------|-------------|-------|---------------|----------|-----------|
# | P10 | Sneakers | 89.99 | 2026-01-01 | 9999-12-31 | true |
# | P20 | Handbag | 149.99 | 2026-03-15 | 9999-12-31 | true |
# | P30 | Jacket | 199.99 | 2026-06-01 | 9999-12-31 | true |

# **`new_feed`** (today's daily product feed, date is 2026-10-07)
# | product_id | product_name | price |
# |-----------|-------------|-------|
# | P10 | Sneakers | 94.99 |
# | P20 | Handbag | 149.99 |
# | P40 | Boots | 129.99 |

# Implement SCD Type 2 logic:
# 1. P10 has a price change → close the old row, insert new row
# 2. P20 is unchanged → do nothing
# 3. P30 is missing from the feed → leave as-is (don't close it)
# 4. P40 is new → insert as a new current row

# **Expected output:**
# | product_id | product_name | price | effective_date | end_date | is_current |
# |-----------|-------------|-------|---------------|----------|-----------|
# | P10 | Sneakers | 89.99 | 2026-01-01 | 2026-10-06 | false |
# | P10 | Sneakers | 94.99 | 2026-10-07 | 9999-12-31 | true |
# | P20 | Handbag | 149.99 | 2026-03-15 | 9999-12-31 | true |
# | P30 | Jacket | 199.99 | 2026-06-01 | 9999-12-31 | true |
# | P40 | Boots | 129.99 | 2026-10-07 | 9999-12-31 | true |


from pyspark.sql.types import BooleanType, StructType, StructField, StringType, DoubleType, DateType
from datetime import date
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

current_data = [
    ("P10", "Sneakers", 89.99, date(2026, 1, 1), date(9999, 12, 31), True),
    ("P20", "Handbag", 149.99, date(2026, 3, 15), date(9999, 12, 31), True),
    ("P30", "Jacket", 199.99, date(2026, 6, 1), date(9999, 12, 31), True),
]

current_schema = StructType([
    StructField("product_id", StringType()),
    StructField("product_name", StringType()),
    StructField("price", DoubleType()),
    StructField("effective_date", DateType()),
    StructField("end_date", DateType()),
    StructField("is_current", BooleanType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
current_products = spark.createDataFrame(current_data, current_schema)

feed_data = [
    ("P10", "Sneakers", 94.99),
    ("P20", "Handbag", 149.99),
    ("P40", "Boots", 129.99),
]

feed_schema = StructType([
    StructField("product_id", StringType()),
    StructField("product_name", StringType()),
    StructField("price", DoubleType()),
])

new_feed = spark.createDataFrame(feed_data, feed_schema)

new_feed_alias = (new_feed
                    .withColumnRenamed('product_name', 'new_product_name')
                    .withColumnRenamed('price', 'new_price')
                )
products_feed = current_products.join(new_feed_alias, 'product_id', 'full')

# we cannot use withColumn and chain when condidtion -- what only works when 1 input row produces one output row
# in scd2 in a case when we modify existing value we do close the current now by changing is_current and end_date
    # we also need to create new row for the values we cannot do inplace modifications 

# best way is to do a union of all different cases 

# condition 1: when we get a new value
pf_new_unmatched = (products_feed
            .filter(F.col('product_name').isNull() & F.col('price').isNull())
            .withColumn('product_name', F.col('new_product_name'))
            .withColumn('price', F.col('new_price'))
            .withColumn('effective_date', F.current_date())
            .withColumn('end_date', F.lit(date(9999, 12, 31)))
            .withColumn('is_current', F.lit(True))
            .select('product_id', 'product_name', 'price', 'effective_date', 'end_date', 'is_current')
        )

# condition 2: matched and unchanged
pf_matched_unchanged = (products_feed
    .filter( (F.col('product_name')==F.col('new_product_name')) & (F.col('price')==F.col('new_price')) )
    .select('product_id', 'product_name', 'price', 'effective_date', 'end_date', 'is_current')
)

#conditoin 3: matched and changed
pf_matched_old = (products_feed
        .filter( (F.col('product_name')!=F.col('new_product_name')) | (F.col('price')!=F.col('new_price')) )
        .withColumn('end_date', F.date_sub(F.current_date(), 1))
        .withColumn('is_current', F.lit(False))
        .select('product_id', 'product_name', 'price', 'effective_date', 'end_date', 'is_current')
    )   

pf_matched_new = (products_feed
        .filter( (F.col('product_name')!=F.col('new_product_name')) | (F.col('price')!=F.col('new_price')) )
        .withColumn('product_name', F.col('new_product_name'))
        .withColumn('price', F.col('new_price'))
        .withColumn('effective_date', F.current_date())
        .withColumn('end_date', F.lit(date(9999, 12, 31)))
        .withColumn('is_current', F.lit(True))
        .select('product_id', 'product_name', 'price', 'effective_date', 'end_date', 'is_current')
    ) 

pf_matched_changed = pf_matched_old.union(pf_matched_new)

# condition 4: original values
pf_old_unmatched = (products_feed
        .filter( F.col('new_product_name').isNull() | F.col('new_price').isNull() ) 
        .select('product_id', 'product_name', 'price', 'effective_date', 'end_date', 'is_current')
    ) 

final_answer = pf_new_unmatched.union(pf_old_unmatched).union(pf_matched_unchanged).union(pf_matched_changed)
final_answer.show()