# **Question 8:**

# You have a DataFrame called `user_orders`:
# | user_id | order_id | order_date | amount | product_category |
# |---------|---------|------------|--------|-----------------|
# | U1 | O001 | 2026-09-01 | 120.00 | Electronics |
# | U1 | O002 | 2026-09-05 | 80.00 | Clothing |
# | U1 | O003 | 2026-09-12 | 200.00 | Electronics |
# | U1 | O004 | 2026-09-18 | 50.00 | Books |
# | U2 | O005 | 2026-09-02 | 300.00 | Electronics |
# | U2 | O006 | 2026-09-08 | 150.00 | Electronics |
# | U2 | O007 | 2026-09-15 | 90.00 | Clothing |
# | U3 | O008 | 2026-09-03 | 400.00 | Electronics |
# | U3 | O009 | 2026-09-10 | 60.00 | Books |
# | U3 | O010 | 2026-09-20 | 350.00 | Electronics |

# Find each user's favorite category (the category they spent the most on) 
#     and what percentage of their total spend went to that category.
# Round to 2 decimal places.

# **Expected output:**

# | user_id | favorite_category | category_spend | total_spend | spend_pct |
# |---------|------------------|---------------|------------|----------|
# | U1 | Electronics | 320.00 | 450.00 | 71.11 |
# | U2 | Electronics | 450.00 | 540.00 | 83.33 |
# | U3 | Electronics | 750.00 | 810.00 | 92.59 |

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, DateType, DoubleType
from datetime import date
from pyspark.sql.window import Window

user_order_data = [
    ("U1", "O001", date(2026, 9, 1), 120.00, "Electronics"),
    ("U1", "O002", date(2026, 9, 5), 80.00, "Clothing"),
    ("U1", "O003", date(2026, 9, 12), 200.00, "Electronics"),
    ("U1", "O004", date(2026, 9, 18), 50.00, "Books"),
    ("U2", "O005", date(2026, 9, 2), 300.00, "Electronics"),
    ("U2", "O006", date(2026, 9, 8), 150.00, "Electronics"),
    ("U2", "O007", date(2026, 9, 15), 90.00, "Clothing"),
    ("U3", "O008", date(2026, 9, 3), 400.00, "Electronics"),
    ("U3", "O009", date(2026, 9, 10), 60.00, "Books"),
    ("U3", "O010", date(2026, 9, 20), 350.00, "Electronics"),
]

user_order_schema = StructType([
    StructField("user_id", StringType()),
    StructField("order_id", StringType()),
    StructField("order_date", DateType()),
    StructField("amount", DoubleType()),
    StructField("product_category", StringType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
user_orders = spark.createDataFrame(user_order_data, user_order_schema)

result = user_orders.groupBy('user_id', 'product_category').agg(F.sum('amount').alias('category_spend'))

w = Window.partitionBy('user_id')
result = (
    result.withColumn('cat_rank', F.row_number().over(w.orderBy(F.col('category_spend').desc())))
                .withColumn('total_spend', F.sum(F.col('category_spend')).over(w))
)

result = result.filter(F.col('cat_rank')==1)

result = (
    result.withColumn('favorite_category', F.col('product_category'))
        .withColumn('spend_pct', F.round((F.col('category_spend')*100)/F.col('total_spend'),2))
)

result = result.select('user_id','favorite_category','category_spend','total_spend','spend_pct')

result.show()