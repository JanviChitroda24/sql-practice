# Write a function that takes two lists of dictionaries (like two tables) 
# and performs a left join on a shared key, returning the merged result.

# Table 1: Orders
orders = [
    {"order_id": 101, "customer_id": 1, "amount": 250},
    {"order_id": 102, "customer_id": 2, "amount": 150},
    {"order_id": 103, "customer_id": 3, "amount": 300},
    {"order_id": 104, "customer_id": 4, "amount": 500},
]

# Table 2: Customers
customers = [
    {"customer_id": 1, "name": "Alice", "city": "Boston"},
    {"customer_id": 2, "name": "Bob", "city": "NYC"},
    {"customer_id": 3, "name": "Charlie", "city": "Chicago"},
]

# Left join: orders LEFT JOIN customers ON customer_id
# Expected output:
# [
#     {"order_id": 101, "customer_id": 1, "amount": 250, "name": "Alice", "city": "Boston"},
#     {"order_id": 102, "customer_id": 2, "amount": 150, "name": "Bob", "city": "NYC"},
#     {"order_id": 103, "customer_id": 3, "amount": 300, "name": "Charlie", "city": "Chicago"},
#     {"order_id": 104, "customer_id": 4, "amount": 500, "name": None, "city": None},
# ]

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName('SparkApp').getOrCreate()

orders_df = spark.createDataFrame(orders)
customers_df = spark.createDataFrame(customers)

result_df = orders_df.join(customers_df, 'customer_id', 'left')
result_df.show()

result = [ row.asDict() for row in result_df.collect() ]
print(result)