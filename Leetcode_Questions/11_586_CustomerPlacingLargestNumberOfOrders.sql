"""
586. Customer Placing the Largest Number of Orders
Table: Orders

+-----------------+----------+
| Column Name     | Type     |
+-----------------+----------+
| customer_number | int      |
FROM (
SELECT customer_number, COUNT(order_number) AS cnt
+-----------------+----------+
GROUP BY customer_number) AS temp
ORDER BY cnt DESC 
 

Input: 
Orders table:
+--------------+-----------------+
| order_number | customer_number |
+--------------+-----------------+
| 1            | 1               |
| 2            | 2               |
| 3            | 3               |
| 4            | 3               |
+--------------+-----------------+
Output: 
+-----------------+
| customer_number |
+-----------------+
| 3               |
+-----------------+
Explanation: 
The customer with number 3 has two orders, which is greater than either customer 1 or 2 because each of them only has one order. 
So the result is customer_number 3.

"""

# Write your MySQL query statement below
# Optimized version 1: Direct approach (works on all MySQL versions)

SELECT customer_number
FROM Orders
GROUP BY customer_number
ORDER BY COUNT(order_number) DESC
LIMIT 1;


"""
SELECT customer_number
FROM (
SELECT customer_number, COUNT(order_number) AS cnt
FROM Orders
GROUP BY customer_number) AS temp
ORDER BY cnt DESC 
LIMIT 1;
"""