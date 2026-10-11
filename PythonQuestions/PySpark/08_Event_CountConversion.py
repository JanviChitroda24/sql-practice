# You have a DataFrame called events with the following data:

# user_id	event_type	event_date
# U1	page_view	2026-09-01
# U1	add_to_cart	2026-09-01
# U1	purchase	2026-09-01
# U2	page_view	2026-09-01
# U2	add_to_cart	2026-09-01
# U3	page_view	2026-09-01
# U4	page_view	2026-09-02
# U4	add_to_cart	2026-09-02
# U4	purchase	2026-09-02
# U5	page_view	2026-09-02
# U5	page_view	2026-09-02
# U6	add_to_cart	2026-09-02

# For each event_date, count the number of distinct users at each funnel stage: 
# page_view, add_to_cart, and purchase. 
# Then compute the conversion rate from page_view to add_to_cart, and from add_to_cart to purchase.

# Expected output:

# event_date	views	carts	purchases	view_to_cart	cart_to_purchase
# 2026-09-01	3	2	1	0.67	0.50
# 2026-09-02	3	2	1	0.67	0.50

from pyspark.sql import SparkSession
from pyspark.sql.types import StructField, StructType, StringType, DateType
from pyspark.sql import functions as F
from pyspark.sql.window import Window 
from datetime import date

spark = SparkSession.builder.appName('myApp').getOrCreate()


event_data = [
    ("U1", "page_view", date(2026, 9, 1)),
    ("U1", "add_to_cart", date(2026, 9, 1)),
    ("U1", "purchase", date(2026, 9, 1)),
    ("U2", "page_view", date(2026, 9, 1)),
    ("U2", "add_to_cart", date(2026, 9, 1)),
    ("U3", "page_view", date(2026, 9, 1)),
    ("U4", "page_view", date(2026, 9, 2)),
    ("U4", "add_to_cart", date(2026, 9, 2)),
    ("U4", "purchase", date(2026, 9, 2)),
    ("U5", "page_view", date(2026, 9, 2)),
    ("U5", "page_view", date(2026, 9, 2)),
    ("U6", "add_to_cart", date(2026, 9, 2)),
]

event_schema = StructType([
    StructField("user_id", StringType()),
    StructField("event_type", StringType()),
    StructField("event_date", DateType()),
])

events = spark.createDataFrame(event_data, event_schema)

# result = events.groupBy('event_date').agg(
#     F.countDistinct('user_id').filter(F.col('event_type') == F.lit('page_view')).alias('views'),
#     F.countDistinct('user_id').filter(F.col('event_type') == F.lit('add_to_cart')).alias('carts'),
#     F.countDistinct('user_id').filter(F.col('event_type') == F.lit('purchase')).alias('purchases'),
#     F.countDistinct('user_id').filter((F.col('event_type') == F.lit('page_view')) & (F.col('event_type') == F.lit('add_to_cart'))).alias('view_to_cart'),
#     F.countDistinct('user_id').filter((F.col('event_type') == F.lit('add_to_cart')) & (F.col('event_type') == F.lit('purchase'))).alias('cart_to_purchase')
# )

temp_result = events.groupBy('event_date').agg(
    F.countDistinct( F.when(F.col('event_type') == F.lit('page_view'), F.col('user_id') ) ).alias('views'),
    F.countDistinct( F.when(F.col('event_type') == F.lit('add_to_cart'), F.col('user_id') ) ).alias('carts'),
    F.countDistinct( F.when(F.col('event_type') == F.lit('purchase'), F.col('user_id') ) ).alias('purchases')
)

result = temp_result \
            .withColumn('view_to_cart', 
                    F.when( 
                        F.col('views')>0,
                        F.round(F.col('carts')/F.col('views'), 2)
                        ).otherwise(0.0)
            ) \
            .withColumn('cart_to_purchase', 
                    F.when(
                        F.col('carts')>0,
                        F.round(F.col('purchases')/F.col('carts'), 2)
                    ).otherwise(0.0)
                )
        
result.show()