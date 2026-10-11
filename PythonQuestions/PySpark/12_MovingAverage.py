# **Question 7:**

# **`daily_sales`**
# | sale_date | product_id | units_sold | revenue |
# |-----------|-----------|------------|---------|
# | 2026-09-01 | P10 | 10 | 500.00 |
# | 2026-09-02 | P10 | 15 | 750.00 |
# | 2026-09-03 | P10 | 8 | 400.00 |
# | 2026-09-04 | P10 | 20 | 1000.00 |
# | 2026-09-05 | P10 | 12 | 600.00 |
# | 2026-09-06 | P10 | 5 | 250.00 |
# | 2026-09-07 | P10 | 18 | 900.00 |
# | 2026-09-08 | P10 | 9 | 450.00 |
# | 2026-09-01 | P20 | 25 | 2000.00 |
# | 2026-09-02 | P20 | 30 | 2400.00 |
# | 2026-09-03 | P20 | 22 | 1760.00 |
# | 2026-09-04 | P20 | 28 | 2240.00 |
# | 2026-09-05 | P20 | 35 | 2800.00 |

# For each product and each date, compute the 3-day moving average of revenue (current day + previous 2 days). 
# Only return rows where a full 3-day window is available.

# **Expected output:**
# | sale_date | product_id | revenue | moving_avg_3d |
# |-----------|-----------|---------|--------------|
# | 2026-09-03 | P10 | 400.00 | 550.00 |
# | 2026-09-04 | P10 | 1000.00 | 716.67 |
# | 2026-09-05 | P10 | 600.00 | 666.67 |
# | 2026-09-06 | P10 | 250.00 | 616.67 |
# | 2026-09-07 | P10 | 900.00 | 583.33 |
# | 2026-09-08 | P10 | 450.00 | 533.33 |
# | 2026-09-03 | P20 | 1760.00 | 2053.33 |
# | 2026-09-04 | P20 | 2240.00 | 2133.33 |
# | 2026-09-05 | P20 | 2800.00 | 2266.67 |

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from pyspark.sql.types import DoubleType, DateType, StringType, StructType, StructField, IntegerType
from datetime import date

sales_data = [
    (date(2026, 9, 1), "P10", 10, 500.00),
    (date(2026, 9, 2), "P10", 15, 750.00),
    (date(2026, 9, 3), "P10", 8, 400.00),
    (date(2026, 9, 4), "P10", 20, 1000.00),
    (date(2026, 9, 5), "P10", 12, 600.00),
    (date(2026, 9, 6), "P10", 5, 250.00),
    (date(2026, 9, 7), "P10", 18, 900.00),
    (date(2026, 9, 8), "P10", 9, 450.00),
    (date(2026, 9, 1), "P20", 25, 2000.00),
    (date(2026, 9, 2), "P20", 30, 2400.00),
    (date(2026, 9, 3), "P20", 22, 1760.00),
    (date(2026, 9, 4), "P20", 28, 2240.00),
    (date(2026, 9, 5), "P20", 35, 2800.00),
]

sales_schema = StructType([
    StructField("sale_date", DateType()),
    StructField("product_id", StringType()),
    StructField("units_sold", IntegerType()),
    StructField("revenue", DoubleType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
daily_sales = spark.createDataFrame(sales_data, sales_schema)

w = Window.partitionBy('product_id').orderBy('sale_date')

result = (daily_sales
            .withColumn('moving_avg_3d', F.round(F.avg(F.col('revenue')).over(w.rowsBetween(-2, Window.currentRow)), 2) )
            .withColumn('row_num', F.row_number().over(w))
)

result = result.filter(F.col('row_num')>=3)
result = result.select('sale_date' , 'product_id' , 'revenue' , 'moving_avg_3d')
result.show()

# alternative without row_number(), calenda gaps matter
w = Window.partitionBy('product_id').orderBy('sale_date').rangeBetween(-2,0)
alternate_r = (
                daily_sales
                .withColumn('moving_avg_3d', 
                    F.round(
                        F.avg(F.col('revenue')).over(w)
                        ,2))
                .withColumn('running_size', F.count('sale_date').over(w))
            )
alterante_r  = alternate_r.filter(F.col('running_size')>=3)
alterante_r = alterante_r.select('sale_date' , 'product_id' , 'revenue' , 'moving_avg_3d')
alterante_r.show()