# Given two PySpark DataFrames, one large (orders) and one small (product lookup), 
# write an optimized join that handles data skew. Explain why a regular join would be slow.

# Why a regular join is slow with skewed data:
#     In a regular Spark join, data gets shuffled across the cluster by the join key. 
#     Each row with the same key ends up on the same executor. 
#     If one key has way more rows than others (that's skew), 
#         one executor gets overloaded while others sit idle. 
#     For example, 
#         if product_id "P001" has 10 million orders but every other product has 1,000, 
#         one executor processes 10 million rows while the rest handle 1,000. 
#     That one executor becomes the bottleneck and the job either runs forever 
#         or crashes with an out-of-memory error.

######################################## INPUT ########################################
# Large table — orders (imagine millions of rows, heavily skewed on product_id)
orders = [
    {"order_id": 1, "product_id": "P001", "quantity": 5, "customer_id": 101},
    {"order_id": 2, "product_id": "P001", "quantity": 3, "customer_id": 102},
    {"order_id": 3, "product_id": "P001", "quantity": 7, "customer_id": 103},
    {"order_id": 4, "product_id": "P001", "quantity": 2, "customer_id": 104},
    {"order_id": 5, "product_id": "P001", "quantity": 1, "customer_id": 105},
    {"order_id": 6, "product_id": "P002", "quantity": 4, "customer_id": 106},
    {"order_id": 7, "product_id": "P003", "quantity": 6, "customer_id": 107},
]
# Notice P001 has 5 orders while P002 and P003 have 1 each — that's skew

# Small table — product lookup
products = [
    {"product_id": "P001", "name": "Running Shoes", "category": "Footwear"},
    {"product_id": "P002", "name": "Backpack", "category": "Accessories"},
    {"product_id": "P003", "name": "Water Bottle", "category": "Gear"},
]

######################################## OUTPUT ########################################
# +----------+--------+--------+-----------+--------------+----------+
# |product_id|order_id|quantity|customer_id|          name|  category|
# +----------+--------+--------+-----------+--------------+----------+
# |      P001|       1|       5|        101| Running Shoes|  Footwear|
# |      P001|       2|       3|        102| Running Shoes|  Footwear|
# |      P001|       3|       7|        103| Running Shoes|  Footwear|
# |      P001|       4|       2|        104| Running Shoes|  Footwear|
# |      P001|       5|       1|        105| Running Shoes|  Footwear|
# |      P002|       6|       4|        106|      Backpack|Accessories|
# |      P003|       7|       6|        107|  Water Bottle|      Gear|
# +----------+--------+--------+-----------+--------------+----------+


from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName('DataSkew').getOrCreate()
orders_df = spark.createDataFrame(orders)
products_df = spark.createDataFrame(products)

# BAD — regular join (causes shuffle, skew kills performance)
# result = orders_df.join(products_df, "product_id", "left")

# GOOD — broadcast join (small table sent to all executors, no shuffle)
result = orders_df.join(F.broadcast(products_df), 'product_id', 'left')
result.show()

result = F.broadcast(products_df).join(orders_df, 'product_id', 'left')
result.show()
# "In this specific case where the small table is on the left side, your original syntax works. 
# Spark will still broadcast the products table correctly 
#     because F.broadcast() is just a hint telling Spark "this one is small, send it everywhere." 
# The hint applies regardless of which side of the join it's on.

# "For a join between a large and small table, I'd use a broadcast join. 
# F.broadcast(products_df) tells Spark to send the entire small DataFrame to every executor, 
#     so the large table doesn't need to be shuffled at all. 
# This eliminates the skew problem because no single executor is overloaded by a hot key. 
# Spark actually does this automatically when the small table is under 10MB (the spark.sql.autoBroadcastJoinThreshold config), 
#     but I prefer being explicit with F.broadcast() so the intent is clear 
#     and it doesn't silently fall back to a shuffle join if the table grows."

# Follow-up: "What if both tables are large?"
#     Then broadcast won't work. 
#     Options are: 
#         salting the skewed key (add a random suffix to the hot key to spread it across partitions), 
#         repartitioning, 
#         adaptive query execution (AQE) in Spark 3+ which handles skew automatically.


# On Adaptive Query Execution (AQE):
# AQE is a Spark 3.0+ feature that optimizes your query while it's running, not just at planning time. 
# Without AQE, Spark creates an execution plan before the job starts and sticks with it. 
# The problem is, Spark doesn't always know the actual data distribution upfront, so it can make bad decisions.

# AQE fixes this by collecting real statistics at each stage boundary (after each shuffle), 
# then re-optimizing the remaining plan based on what it actually saw. Three main things it does:
#     Coalescing shuffle partitions — if Spark created 200 partitions but most are tiny, AQE merges the small ones together automatically, reducing overhead.
#     Converting sort-merge join to broadcast join — if Spark originally planned a shuffle join but then realizes one side is actually small enough after filtering, it switches to a broadcast join mid-execution.
#     Skew join optimization — if AQE detects that one partition is way bigger than the others (a hot key), it automatically splits that partition into smaller pieces and replicates the matching data from the other side. So the hot key gets processed in parallel across multiple tasks instead of one overloaded task.