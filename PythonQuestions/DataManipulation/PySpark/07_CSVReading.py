# Write a Python function that reads a CSV file, 
#     validates each row (checks for nulls in required fields, correct data types, valid date formats), 
#     logs bad rows to a separate file, and returns only the clean rows.

# Input:
# order_id,customer_name,amount,order_date
# 1,Alice,250.00,2024-01-15
# 2,,150.00,2024-01-16
# 3,Charlie,bad_amount,2024-01-17
# 4,Diana,300.00,2024-13-01
# 5,Eve,475.50,2024-01-19
# 6,Frank,,2024-01-20
# 7,Grace,120.00,
# 8,Hank,890.00,2024-01-22

# order_id — required, must be an integer
# customer_name — required, cannot be empty
# amount — required, must be a valid float
# order_date — required, must be valid YYYY-MM-DD format

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import csv

spark = SparkSession.builder.appName('myApp').getOrCreate()

with open('./../InputData/07.csv', 'r') as f:
    reader = csv.DictReader(f)
    d_list = []
    for row in reader:
        d_list.append(row)

print(d_list)
orders = spark.createDataFrame(d_list)


valid_orders = orders.filter(F.col('order_id').isNotNull() & F.col('order_id').try_cast('integer').isNotNull()) \
                    .filter(F.col('customer_name').isNotNull() & (F.trim(F.col('customer_name'))!=F.lit(""))) \
                    .filter(F.col('amount').isNotNull() & F.col('amount').try_cast('float').isNotNull()) \
                    .filter(F.col('order_date').isNotNull() & F.try_to_date(F.col('order_date'), 'yyyy-MM-dd').isNotNull())

valid_orders.show()

invalid_orders = orders.join(valid_orders, 'order_id', 'anti')
invalid_orders.show()
