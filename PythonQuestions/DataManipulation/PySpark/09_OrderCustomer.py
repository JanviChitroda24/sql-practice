# **Question 4:**

# You have a DataFrame called `orders`:

# | order_id | customer_id | order_date | amount |
# |----------|------------|------------|--------|
# | O001 | C1 | 2026-09-01 | 100.00 |
# | O002 | C1 | 2026-09-03 | 150.00 |
# | O003 | C1 | 2026-09-08 | 200.00 |
# | O004 | C2 | 2026-09-02 | 300.00 |
# | O005 | C2 | 2026-09-05 | 50.00 |
# | O006 | C2 | 2026-09-12 | 175.00 |
# | O007 | C3 | 2026-09-01 | 80.00 |
# | O008 | C3 | 2026-09-15 | 220.00 |

# For each customer and each order, compute:
# 1. Running total of amount up to that order (ordered by order_date)
# 2. Days since their previous order
# 3. Difference in amount compared to their previous order

# **Expected output:**

# | customer_id | order_date | amount | running_total | days_since_prev | amount_diff |
# |------------|------------|--------|--------------|----------------|-------------|
# | C1 | 2026-09-01 | 100.00 | 100.00 | null | null |
# | C1 | 2026-09-03 | 150.00 | 250.00 | 2 | 50.00 |
# | C1 | 2026-09-08 | 200.00 | 450.00 | 5 | 50.00 |
# | C2 | 2026-09-02 | 300.00 | 300.00 | null | null |
# | C2 | 2026-09-05 | 50.00 | 350.00 | 3 | -250.00 |
# | C2 | 2026-09-12 | 175.00 | 525.00 | 7 | 125.00 |
# | C3 | 2026-09-01 | 80.00 | 80.00 | null | null |
# | C3 | 2026-09-15 | 220.00 | 300.00 | 14 | 140.00 |


from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, DateType, DoubleType, StringType
from pyspark.sql import functions as F
from pyspark.sql.window import Window
import copy
from datetime import date

order_data = [
    ("O001", "C1", date(2026, 9, 1), 100.00),
    ("O002", "C1", date(2026, 9, 3), 150.00),
    ("O003", "C1", date(2026, 9, 8), 200.00),
    ("O004", "C2", date(2026, 9, 2), 300.00),
    ("O005", "C2", date(2026, 9, 5), 50.00),
    ("O006", "C2", date(2026, 9, 12), 175.00),
    ("O007", "C3", date(2026, 9, 1), 80.00),
    ("O008", "C3", date(2026, 9, 15), 220.00),
]

order_schema = StructType([
    StructField("order_id", StringType()),
    StructField("customer_id", StringType()),
    StructField("order_date", DateType()),
    StructField("amount", DoubleType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
orders = spark.createDataFrame(order_data, order_schema)

w = Window.partitionBy(F.col('customer_id')).orderBy(F.col('order_date'))

result = (
            orders
                .withColumn('running_total', F.sum(F.col('amount')).over(w.rowsBetween( Window.unboundedPreceding, Window.currentRow)) )  
                .withColumn('days_since_prev', F.datediff( F.col('order_date'), F.lag(F.col('order_date'),1).over(w) ))
                .withColumn('amount_diff', F.col('amount')-F.lag( F.col('amount') ,1).over(w) )
                # .withColumn('temp', F.col('order_date') - F.lag(F.col('order_date'),1).over(w) )
        )
result.show()

