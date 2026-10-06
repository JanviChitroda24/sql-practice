# **Question 1:**

# You have a DataFrame called `orders` with the following data:

# | order_id | customer_id | product_id | order_date | quantity | unit_price | status |
# |----------|------------|------------|------------|----------|------------|-----------|
# | O001 | C1 | P10 | 2026-09-15 | 2 | 50.00 | completed |
# | O002 | C1 | P20 | 2026-09-20 | 1 | 120.00 | completed |
# | O003 | C1 | P30 | 2026-09-25 | 3 | 40.00 | cancelled |
# | O004 | C2 | P10 | 2026-08-10 | 1 | 50.00 | completed |
# | O005 | C2 | P40 | 2026-09-18 | 2 | 75.00 | completed |
# | O006 | C3 | P20 | 2026-09-22 | 4 | 120.00 | returned |
# | O007 | C3 | P50 | 2026-07-01 | 1 | 200.00 | completed |
# | O008 | C4 | P10 | 2026-09-28 | 5 | 50.00 | pending |

# For each customer, find their most recent completed order. 
# Return the customer_id, order_date, and total_amount (quantity × unit_price) for that order.

# **Expected output:**

# | customer_id | order_date | total_amount |
# |------------|------------|-------------|
# | C1 | 2026-09-20 | 120.00 |
# | C2 | 2026-09-18 | 150.00 |
# | C3 | 2026-07-01 | 200.00 |

# order_id (string)
# customer_id (string)
# product_id (string)
# order_date (date)
# quantity (integer)
# unit_price (double)
# status (string)

#####################
from pyspark.sql import SparkSession
from pyspark.sql import functions as F 
from pyspark.sql.types import StructType, StructField, StringType, DateType, IntegerType, DoubleType
from pyspark.sql.window import Window

spark = SparkSession.builder.appName('myApp').getOrCreate()

data = [
    ("O001", "C1", "P10", date(2026, 9, 15), 2, 50.00, "completed"),
    ("O002", "C1", "P20", date(2026, 9, 20), 1, 120.00, "completed"),
    ("O003", "C1", "P30", date(2026, 9, 25), 3, 40.00, "cancelled"),
    ("O004", "C2", "P10", date(2026, 8, 10), 1, 50.00, "completed"),
    ("O005", "C2", "P40", date(2026, 9, 18), 2, 75.00, "completed"),
    ("O006", "C3", "P20", date(2026, 9, 22), 4, 120.00, "returned"),
    ("O007", "C3", "P50", date(2026, 7, 1), 1, 200.00, "completed"),
    ("O008", "C4", "P10", date(2026, 9, 28), 5, 50.00, "pending"),
]

schema = StructType([
    StructField('order_id', StringType()),
    StructField('customer_id',StringType()),
    StructField('product_id', StringType()),
    StructField('order_date', DateType()),
    StructField('quantity', IntegerType()),
    StructField('unit_price', DoubleType()),
    StructField('status', StringType())
])

orders = spark.createDataFrame(data, schema)
result = orders
w = Window.partitionBy('customer_id').orderBy(F.col('order_date').desc())
result = orders.filter(F.col('status')=='completed')
result = result.withColumn('order_rank', F.row_number().over(w))
result =    (
            result.filter(F.col('order_rank')==1)
            .select(F.col('customer_id'), F.col('order_date'), (F.col('quantity')*F.col('unit_price')).alias('total_amount'))
            )


