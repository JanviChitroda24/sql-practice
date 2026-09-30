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

spark = SparkSession.builder.appName('myApp').getOrCreate()

orders = spark.read.csv('./../InputData/07.csv', header=True)
orders.show()

invalid_orders = orders.withColumn('invalid_reason', \
                    F.concat_ws( ', ', \
                        F.when( (F.col('order_id').isNull() | F.col('order_id').try_cast('integer').isNull()), F.lit('Invalid order_id')), \
                        F.when( (F.col('customer_name').isNull() | (F.trim(F.col('customer_name')) == F.lit("")) ), F.lit('Invalid customer_name')), \
                        F.when( (F.col('amount').isNull() | F.col('amount').try_cast('float').isNull()), F.lit('Invalid amount')), \
                        F.when( (F.col('order_date').isNull() | F.try_to_date(F.col('order_date'),'yyyy-MM-dd' ).isNull() ), F.lit('Invalid order_date'))
                    )
                )

print("Valid Orders")
valid_orders = invalid_orders.filter(F.trim(F.col('invalid_reason')) == F.lit("")).select('order_id', 'customer_name', 'amount', 'order_date')
valid_orders.show()

print("Invalid Orders")
invalid_orders = invalid_orders.filter(F.trim(F.col('invalid_reason')) != F.lit(""))
invalid_orders.show()