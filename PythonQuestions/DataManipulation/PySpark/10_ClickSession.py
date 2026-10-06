
# **Question 5:**

# You have a DataFrame called `clickstream`:

# | user_id | page_url | event_time |
# |---------|---------|------------|
# | U1 | /home | 2026-09-01 10:00:00 |
# | U1 | /product/123 | 2026-09-01 10:05:00 |
# | U1 | /cart | 2026-09-01 10:08:00 |
# | U1 | /home | 2026-09-01 11:00:00 |
# | U1 | /product/456 | 2026-09-01 11:03:00 |
# | U2 | /home | 2026-09-01 09:00:00 |
# | U2 | /product/789 | 2026-09-01 09:10:00 |
# | U2 | /cart | 2026-09-01 10:15:00 |
# | U2 | /checkout | 2026-09-01 10:18:00 |

# A new session starts when the gap between consecutive events for the same user exceeds 30 minutes. 
# Assign a session_id (starting from 1) to each event per user.

# **Expected output:**

# | user_id | page_url | event_time | session_id |
# |---------|---------|------------|-----------|
# | U1 | /home | 2026-09-01 10:00:00 | 1 |
# | U1 | /product/123 | 2026-09-01 10:05:00 | 1 |
# | U1 | /cart | 2026-09-01 10:08:00 | 1 |
# | U1 | /home | 2026-09-01 11:00:00 | 2 |
# | U1 | /product/456 | 2026-09-01 11:03:00 | 2 |
# | U2 | /home | 2026-09-01 09:00:00 | 1 |
# | U2 | /product/789 | 2026-09-01 09:10:00 | 1 |
# | U2 | /cart | 2026-09-01 10:15:00 | 2 |
# | U2 | /checkout | 2026-09-01 10:18:00 | 2 |

from pyspark.sql import SparkSession
from pyspark.sql.window import Window
from pyspark.sql import functions as F 
from pyspark.sql.types import TimestampType, StringType, StructField, StructType
from datetime import datetime

click_data = [
    ("U1", "/home", datetime(2026, 9, 1, 10, 0, 0)),
    ("U1", "/product/123", datetime(2026, 9, 1, 10, 5, 0)),
    ("U1", "/cart", datetime(2026, 9, 1, 10, 8, 0)),
    ("U1", "/home", datetime(2026, 9, 1, 11, 0, 0)),
    ("U1", "/product/456", datetime(2026, 9, 1, 11, 3, 0)),
    ("U2", "/home", datetime(2026, 9, 1, 9, 0, 0)),
    ("U2", "/product/789", datetime(2026, 9, 1, 9, 10, 0)),
    ("U2", "/cart", datetime(2026, 9, 1, 10, 15, 0)),
    ("U2", "/checkout", datetime(2026, 9, 1, 10, 18, 0)),
]

click_schema = StructType([
    StructField("user_id", StringType()),
    StructField("page_url", StringType()),
    StructField("event_time", TimestampType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
clickstream = spark.createDataFrame(click_data, click_schema)

w = Window.partitionBy('user_id').orderBy('event_time')

result = (
            clickstream.withColumn('time_difference',
                    (F.col('event_time').cast('long') -
                            (F.lag( F.col('event_time'), 1
                            ).over(w)).cast('long')
                    )/60
                )
        )
result = (result.withColumn('separate_session',
            F.when( (F.col('time_difference')>30) | (F.col('time_difference').isNull()), 1)
                .otherwise(0)
        ))

result = (result.withColumn('sessoin_id', 
            F.sum(F.col('separate_session')).over(w)
         ))

result = result.select('user_id', 'page_url', 'event_time', 'sessoin_id')

result.show()

# optimized 
w = Window.partitionBy('user_id').orderBy('event_time')
result_optimized = (
            clickstream
                .withColumn('prev_time',  F.lag(F.col('event_time')).over(w) )
                .withColumn( 'time_differnece', ( F.col('event_time').cast('long') - F.col('prev_time').cast('long') ) /60 )
                .withColumn( 'session_flag', F.when( (F.col('time_differnece')>30) | (F.col('time_differnece').isNull()) , 1).otherwise(0) )
                .withColumn( 'session_id', F.sum(F.col('session_flag')).over(w))
)

result_optimized = result_optimized.select('user_id', 'page_url', 'event_time', 'session_id')
result_optimized.show()