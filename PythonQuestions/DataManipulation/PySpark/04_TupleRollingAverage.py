# You have a list of (timestamp, value) tuples. 
# Write a function that computes a rolling average over a window of N entries.

data = [
    ("2024-01-01 09:00", 10),
    ("2024-01-01 09:05", 20),
    ("2024-01-01 09:10", 30),
    ("2024-01-01 09:15", 40),
    ("2024-01-01 09:20", 50),
    ("2024-01-01 09:25", 60),
]

window = 3

# Expected output (rolling average with window of 3):
# "2024-01-01 09:00" → 10.0        (only 1 value, avg of [10])
# "2024-01-01 09:05" → 15.0        (only 2 values, avg of [10,20])
# "2024-01-01 09:10" → 20.0        (avg of [10, 20, 30])
# "2024-01-01 09:15" → 30.0        (avg of [20, 30, 40])
# "2024-01-01 09:20" → 40.0        (avg of [30, 40, 50])
# "2024-01-01 09:25" → 50.0        (avg of [40, 50, 60])

from pyspark.sql import SparkSession 
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from pyspark.sql.types import StructField, StructType, IntegerType, TimestampType, StringType

spark = SparkSession.builder.appName('myApp').getOrCreate()

schema = StructType([
    StructField('log_timestamp',StringType()),
    StructField('value', IntegerType())
    ]   
)

df = spark.createDataFrame(data, schema)
w = Window.orderBy(F.col('log_timestamp')).rowsBetween(-window+1,0)
df = df.withColumn('rolling_avg', F.avg(F.col('value')).over(w) )
result = df.select(F.col('log_timestamp'), F.col('rolling_avg'))

result_list = [ tuple(row) for row in result.collect() ]

print(result_list)
