# You have two DataFrames:

# **`orders`**

# | order_id | customer_id | product_id | order_date | quantity | unit_price |
# |----------|------------|------------|------------|----------|------------|
# | O001 | C1 | P10 | 2026-09-01 | 2 | 50.00 |
# | O002 | C1 | P20 | 2026-09-05 | 1 | 80.00 |
# | O003 | C1 | P10 | 2026-09-12 | 3 | 50.00 |
# | O004 | C2 | P30 | 2026-09-03 | 1 | 200.00 |
# | O005 | C2 | P10 | 2026-09-20 | 4 | 50.00 |
# | O006 | C3 | P20 | 2026-09-08 | 2 | 80.00 |
# | O007 | C3 | P30 | 2026-09-15 | 1 | 200.00 |
# | O008 | C3 | P40 | 2026-09-22 | 5 | 30.00 |

# **`products`**

# | product_id | product_name | category |
# |------------|-------------|----------|
# | P10 | Sneakers | Footwear |
# | P20 | Handbag | Accessories |
# | P30 | Jacket | Outerwear |
# | P40 | Scarf | Accessories |
# | P50 | Boots | Footwear |

# For each category, find the total revenue and the number of unique customers who purchased from that category. 
# Then return only categories where more than one distinct customer purchased.

# **Expected output:**

# | category | total_revenue | unique_customers |
# |----------|--------------|-----------------|
# | Footwear | 450.00 | 2 |
# | Accessories | 390.00 | 2 |
# | Outerwear | 400.00 | 2 |


from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StructField, StructType, IntegerType, StringType, DateType, DoubleType
from datetime import date

spark = SparkSession.builder.appName('myApp').getOrCreate()

order_data = [
    ("O001", "C1", "P10", date(2026, 9, 1), 2, 50.00),
    ("O002", "C1", "P20", date(2026, 9, 5), 1, 80.00),
    ("O003", "C1", "P10", date(2026, 9, 12), 3, 50.00),
    ("O004", "C2", "P30", date(2026, 9, 3), 1, 200.00),
    ("O005", "C2", "P10", date(2026, 9, 20), 4, 50.00),
    ("O006", "C3", "P20", date(2026, 9, 8), 2, 80.00),
    ("O007", "C3", "P30", date(2026, 9, 15), 1, 200.00),
    ("O008", "C3", "P40", date(2026, 9, 22), 5, 30.00),
]

order_schema = StructType([
    StructField("order_id", StringType()),
    StructField("customer_id", StringType()),
    StructField("product_id", StringType()),
    StructField("order_date", DateType()),
    StructField("quantity", IntegerType()),
    StructField("unit_price", DoubleType()),
])

orders = spark.createDataFrame(order_data, order_schema)

product_data = [
    ("P10", "Sneakers", "Footwear"),
    ("P20", "Handbag", "Accessories"),
    ("P30", "Jacket", "Outerwear"),
    ("P40", "Scarf", "Accessories"),
    ("P50", "Boots", "Footwear"),
]

product_schema = StructType([
    StructField("product_id", StringType()),
    StructField("product_name", StringType()),
    StructField("category", StringType()),
])

products = spark.createDataFrame(product_data, product_schema)

prod_order = products.join(orders, 'product_id', 'inner')
cat_group = prod_order.groupBy('category').agg( 
    F.countDistinct(F.col('customer_id')).alias('unique_customers'),
    F.sum(F.col('quantity')*F.col('unit_price')).alias('total_revenue')
)

result_df = cat_group.select(F.col('category'), F.col('total_revenue'), F.col('unique_customers')) \
    .filter(F.col('unique_customers') > 1)

result_df.show()