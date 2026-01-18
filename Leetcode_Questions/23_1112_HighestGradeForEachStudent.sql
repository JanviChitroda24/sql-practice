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

-- ROW_NUMBER: one row per student. ORDER BY grade DESC then course_id = highest grade, tie-break smallest course_id.
WITH top_grade_course AS (
  	SELECT student_id, course_id, grade,	
		ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC,course_id) AS top_grade
	FROM Enrollments
)
SELECT student_id, course_id, grade
FROM top_grade_course
WHERE top_grade=1
ORDER BY student_id;