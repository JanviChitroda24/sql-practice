# You have a DataFrame called `inventory_events`:

# | event_id | product_id | warehouse_id | stock_change | event_timestamp |
# |----------|-----------|-------------|-------------|-----------------|
# | E001 | P10 | W1 | 100 | 2026-09-01 08:00:00 |
# | E002 | P10 | W1 | -5 | 2026-09-01 10:30:00 |
# | E003 | P10 | W1 | -3 | 2026-09-01 14:00:00 |
# | E004 | P10 | W2 | 50 | 2026-09-01 09:00:00 |
# | E005 | P10 | W2 | -10 | 2026-09-01 16:00:00 |
# | E006 | P20 | W1 | 200 | 2026-09-01 07:00:00 |
# | E007 | P20 | W1 | -25 | 2026-09-01 11:00:00 |
# | E008 | P20 | W1 | 30 | 2026-09-01 15:00:00 |

# Each row represents a stock change event — positive means stock received, negative means stock sold. 
# Compute the running stock level for each product at each warehouse over time.

# **Expected output:**

# | product_id | warehouse_id | event_timestamp | stock_change | running_stock |
# |-----------|-------------|-----------------|-------------|--------------|
# | P10 | W1 | 2026-09-01 08:00:00 | 100 | 100 |
# | P10 | W1 | 2026-09-01 10:30:00 | -5 | 95 |
# | P10 | W1 | 2026-09-01 14:00:00 | -3 | 92 |
# | P10 | W2 | 2026-09-01 09:00:00 | 50 | 50 |
# | P10 | W2 | 2026-09-01 16:00:00 | -10 | 40 |
# | P20 | W1 | 2026-09-01 07:00:00 | 200 | 200 |
# | P20 | W1 | 2026-09-01 11:00:00 | -25 | 175 |
# | P20 | W1 | 2026-09-01 15:00:00 | 30 | 205 |

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import IntegerType, StructType, StructField, StringType, TimestampType
from pyspark.sql.window import Window
from datetime import datetime

inv_data = [
    ("E001", "P10", "W1", 100, datetime(2026, 9, 1, 8, 0, 0)),
    ("E002", "P10", "W1", -5, datetime(2026, 9, 1, 10, 30, 0)),
    ("E003", "P10", "W1", -3, datetime(2026, 9, 1, 14, 0, 0)),
    ("E004", "P10", "W2", 50, datetime(2026, 9, 1, 9, 0, 0)),
    ("E005", "P10", "W2", -10, datetime(2026, 9, 1, 16, 0, 0)),
    ("E006", "P20", "W1", 200, datetime(2026, 9, 1, 7, 0, 0)),
    ("E007", "P20", "W1", -25, datetime(2026, 9, 1, 11, 0, 0)),
    ("E008", "P20", "W1", 30, datetime(2026, 9, 1, 15, 0, 0)),
]

inv_schema = StructType([
    StructField("event_id", StringType()),
    StructField("product_id", StringType()),
    StructField("warehouse_id", StringType()),
    StructField("stock_change", IntegerType()),
    StructField("event_timestamp", TimestampType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
inventory_events = spark.createDataFrame(inv_data, inv_schema)

w = Window.partitionBy('product_id', 'warehouse_id').orderBy('event_timestamp')

result = inventory_events.withColumn('running_stock', F.sum(F.col('stock_change')).over(w))
result = result.select('product_id', 'warehouse_id', 'event_timestamp', 'stock_change', 'running_stock')

result.show()


# Window does not collapse anything. 
# It keeps every row and just computes a value across the defined window frame. 
# So partitionBy('product_id', 'warehouse_id') 
#     means "compute this function within each product-warehouse group, but keep every individual row."