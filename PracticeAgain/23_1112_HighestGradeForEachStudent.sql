"""
1112 - Highest Grade For Each Student
https://leetcode.ca/all/1112.html

Write a SQL query to find the highest grade with its corresponding course for each student. 
In case of a tie, you should find the course with the smallest course_id. The output must be sorted by increasing student_id.
The query result format is in the following example:

Table: Enrollments
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| student_id    | int     |
| course_id     | int     |
| grade         | int     |
+---------------+---------+
(student_id, course_id) is the primary key of this table.

The query result format is in the following example:

Enrollments table:
+------------+-------------------+
| student_id | course_id | grade |
+------------+-----------+-------+
| 2          | 2         | 95    |
| 2          | 3         | 95    |
| 1          | 1         | 90    |
| 1          | 2         | 99    |
| 3          | 1         | 80    |
| 3          | 2         | 75    |
| 3          | 3         | 82    |
+------------+-----------+-------+

Result table:
+------------+-------------------+
| student_id | course_id | grade |
+------------+-----------+-------+
| 1          | 2         | 99    |
| 2          | 2         | 95    |
| 3          | 3         | 82    |
+------------+-----------+-------+
"""

WITH student_grades_rank AS (
    SELECT student_id, course_id, grade,
        DENSE_RANK() OVER(PARTITION BY student_id ORDER BY grade DESC) AS grade_rank
    FROM Enrollments
),
highest_grade AS (
    SELECT student_id, course_id, grade, 
        ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY course_id) AS course_rank
    FROM student_grades_rank
    WHERE grade_rank = 1 
)
SELECT student_id, course_id, grade
FROM highest_grade
WHERE course_rank = 1;

-- optimized solution -- single window function pass
WITH student_grades_rank AS (
    SELECT student_id, course_id, grade,
        ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC, course_id) AS grade_rank
    FROM Enrollments
)
SELECT student_id, course_id, grade
FROM student_grades_rank
WHERE grade_rank = 1;


-- **Now, your misconception — this is important:**

-- You can absolutely have multiple columns in BOTH `PARTITION BY` and `ORDER BY`. 
-- No restrictions on either.

-- ```sql
-- -- Multiple columns in PARTITION BY: totally valid
-- OVER(PARTITION BY dept_id, region_id ORDER BY salary DESC)

-- -- Multiple columns in ORDER BY: totally valid
-- OVER(PARTITION BY student_id ORDER BY grade DESC, course_id ASC)

-- -- Multiple in both: also valid
-- OVER(PARTITION BY dept_id, region_id ORDER BY salary DESC, hire_date ASC)
-- ```

-- **Think of it this way:**

-- PARTITION BY answers: 
--     "What groups do I create?" 
--         — you can group by as many columns as you need, just like GROUP BY.

-- ORDER BY answers: 
--     "Within each group, how do I sort the rows?" 
--         — you can sort by as many tiebreakers as you need, just like a regular ORDER BY clause.

-- They're independent of each other. 
-- No limit on either. 
-- Glad you asked — this misconception would have cost you on harder problems.