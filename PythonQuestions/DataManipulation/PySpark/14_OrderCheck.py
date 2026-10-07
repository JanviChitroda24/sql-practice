# **Question 9:**

# You have a DataFrame called `raw_orders`:

# | order_id | customer_id | order_date | amount | product_id |
# |----------|------------|------------|--------|-----------|
# | O001 | C1 | 2026-09-01 | 150.00 | P10 |
# | null | C2 | 2026-09-02 | 200.00 | P20 |
# | O003 | C3 | 2026-09-03 | -50.00 | P30 |
# | O004 | null | 2026-09-04 | 100.00 | P10 |
# | O001 | C1 | 2026-09-01 | 150.00 | P10 |
# | O005 | C5 | 2027-01-15 | 300.00 | P20 |
# | O006 | C6 | 2026-09-06 | 0.00 | P40 |
# | O007 | C7 | 2026-09-07 | 75.00 | null |
# | O008 | C1 | 2026-09-01 | 150.00 | P10 |

# This is raw data landing from a source system. Before loading to the warehouse, implement data quality checks. Flag each row with all violations it has, separate clean rows from bad rows, and write both to different paths. The rules are:

# 1. `order_id` must not be null
# 2. `customer_id` must not be null
# 3. `amount` must be greater than 0
# 4. `order_date` must not be in the future (today is 2026-10-07)
# 5. No duplicate `order_id` — keep only the first occurrence

# **Expected clean output:**

# | order_id | customer_id | order_date | amount | product_id |
# |----------|------------|------------|--------|-----------|
# | O001 | C1 | 2026-09-01 | 150.00 | P10 |
# | O006 | C6 | 2026-09-06 | 0.00 | P40 |
# | O007 | C7 | 2026-09-07 | 75.00 | null |

# Wait — O006 has amount 0.00 which fails rule 3 (amount > 0). Let me correct:

# **Expected clean output:**

# | order_id | customer_id | order_date | amount | product_id |
# |----------|------------|------------|--------|-----------|
# | O001 | C1 | 2026-09-01 | 150.00 | P10 |
# | O007 | C7 | 2026-09-07 | 75.00 | null |

# **Expected quarantine output** (all rows that violated at least one rule):

# | order_id | customer_id | order_date | amount | product_id | dq_flags |
# |----------|------------|------------|--------|-----------|----------|
# | null | C2 | 2026-09-02 | 200.00 | P20 | null_order_id |
# | O003 | C3 | 2026-09-03 | -50.00 | P30 | negative_amount |
# | O004 | null | 2026-09-04 | 100.00 | P10 | null_customer_id |
# | O001 | C1 | 2026-09-01 | 150.00 | P10 | duplicate |
# | O005 | C5 | 2027-01-15 | 300.00 | P20 | future_date |
# | O006 | C6 | 2026-09-06 | 0.00 | P40 | zero_amount |
# | O008 | C1 | 2026-09-01 | 150.00 | P10 | duplicate |

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DateType, DoubleType
from pyspark.sql import functions as F
from datetime import date
from pyspark.sql.window import Window

raw_data = [
    ("O001", "C1", date(2026, 9, 1), 150.00, "P10"),
    (None, "C2", date(2026, 9, 2), 200.00, "P20"),
    ("O003", "C3", date(2026, 9, 3), -50.00, "P30"),
    ("O004", None, date(2026, 9, 4), 100.00, "P10"),
    ("O001", "C1", date(2026, 9, 1), 150.00, "P10"),
    ("O005", "C5", date(2027, 1, 15), 300.00, "P20"),
    ("O006", "C6", date(2026, 9, 6), 0.00, "P40"),
    ("O007", "C7", date(2026, 9, 7), 75.00, None),
    ("O008", "C1", date(2026, 9, 1), 150.00, "P10"),
]

raw_schema = StructType([
    StructField("order_id", StringType()),
    StructField("customer_id", StringType()),
    StructField("order_date", DateType()),
    StructField("amount", DoubleType()),
    StructField("product_id", StringType()),
])

spark = SparkSession.builder.appName('myApp').getOrCreate()
raw_orders = spark.createDataFrame(raw_data, raw_schema)

w = Window.partitionBy('order_id').orderBy('order_date')
orders_flag = (
        raw_orders
            .withColumn('null_order_id', 
                F.when(F.col('order_id').isNull(), 'null_order_id').otherwise(None))
            .withColumn('null_customer_id', 
                F.when(F.col('customer_id').isNull(), 'null_customer_id').otherwise(None))
            .withColumn('zero_amount',
                F.when(F.col('amount')<=0, 'zero_amount').otherwise(None))
            .withColumn('future_date', 
                F.when(
                    F.datediff(F.col('order_date'), F.current_date()) > 0, 'future_date'
                    ).otherwise(None))
            .withColumn('duplicate', 
                F.when(
                    ((F.row_number().over(w) > 1) & F.col('order_id').isNotNull()), 'duplicate' 
                ).otherwise(None))
)

clean_orders = (orders_flag
                .filter(F.col('null_order_id').isNull() &
                        F.col('null_customer_id').isNull() & 
                        F.col('zero_amount').isNull() & 
                        F.col('future_date').isNull() & 
                        F.col('duplicate').isNull()
                    )
                .select('order_id','customer_id','order_date','amount','product_id')
    )

quarantine_orders = (orders_flag
                    .filter(F.col('null_order_id').isNotNull() |
                        F.col('null_customer_id').isNotNull() | 
                        F.col('zero_amount').isNotNull() | 
                        F.col('future_date').isNotNull() | 
                        F.col('duplicate').isNotNull()
                    )
                    .withColumn('dq_flags', 
                        F.concat_ws(',', 
                                    F.col('null_order_id'), 
                                    F.col('null_customer_id'),
                                    F.col('zero_amount'),
                                    F.col('future_date'),
                                    F.col('duplicate'))
                        )
                    .select('order_id','customer_id','order_date','amount','product_id', 'dq_flags')
    )

clean_orders.show()
quarantine_orders.show()
# if we do a window over order_id and just do a condition where count > 0 than it will flag all the entiries as duplications 
# instead we should do a row_number() and then in when we should do the condition where row_number()>1 
# so first entry wont be a duplicate just hte later ones would be marked as duplicate