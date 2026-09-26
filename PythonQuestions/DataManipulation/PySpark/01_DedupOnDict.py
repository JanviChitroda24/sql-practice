# data = [
#     {"id": 1, "timestamp": "2024-01-01 10:00", "value": "A"},
#     {"id": 2, "timestamp": "2024-01-01 11:00", "value": "B"},
#     {"id": 3, "timestamp": "2024-01-01 12:00", "value": "C"},
#     {"id": 1, "timestamp": "2024-01-01 09:00", "value": "D"},
#     {"id": 2, "timestamp": "2024-01-01 12:00", "value": "C"},
#     {"id": 1, "timestamp": "2024-01-01 03:00", "value": "D"},
# ]

# here the output should be in same format 
# just htat we want the latest timestampt for each id.. just the lastest timestamp

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName('First').getOrCreate()

data = [
    {"id": 1, "timestamp": "2024-01-01 10:00", "value": "A"},
    {"id": 2, "timestamp": "2024-01-01 11:00", "value": "B"},
    {"id": 3, "timestamp": "2024-01-01 12:00", "value": "C"},
    {"id": 1, "timestamp": "2024-01-01 09:00", "value": "D"},
    {"id": 2, "timestamp": "2024-01-01 12:00", "value": "C"},
    {"id": 1, "timestamp": "2024-01-01 03:00", "value": "D"},
]

df = spark.createDataFrame(data)
print(df)
df.show()
df.printSchema()

inter = df.groupBy('id').agg(F.max('timestamp').alias('timestamp')).select('id')
output = df.join(inter, 'id', 'inner')
output.show()

result = [row.asDict() for row in output.collect()]
print(result)
