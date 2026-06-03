"""
1077 - Project Employees III
https://leetcode.ca/all/1077.html

Write an SQL query that reports the most experienced employees in each project. 
In case of a tie, report all employees with the maximum number of experience years.

Table: Project

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| project_id  | int     |
| employee_id | int     |
+-------------+---------+
(project_id, employee_id) is the primary key of this table.
employee_id is a foreign key to Employee table.
Table: Employee

+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| employee_id      | int     |
| name             | varchar |
| experience_years | int     |
+------------------+---------+
employee_id is the primary key of this table.

The query result format is in the following example:

Project table:
+-------------+-------------+
| project_id  | employee_id |
+-------------+-------------+
| 1           | 1           |
| 1           | 2           |
| 1           | 3           |
| 2           | 1           |
| 2           | 4           |
+-------------+-------------+

Employee table:
+-------------+--------+------------------+
| employee_id | name   | experience_years |
+-------------+--------+------------------+
| 1           | Khaled | 3                |
| 2           | Ali    | 2                |
| 3           | John   | 3                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+

Result table:
+-------------+---------------+
| project_id  | employee_id   |
+-------------+---------------+
| 1           | 1             |
| 1           | 3             |
| 2           | 1             |
+-------------+---------------+
Both employees with id 1 and 3 have the most experience among the employees of the first project. For the second project, the employee with id 1 has the most experience.
"""

WITH emp_exp_rank AS (
	SELECT p.project_id, p.employee_id,
		DENSE_RANK() OVER(PARTITION BY p.project_id ORDER BY e.experience_years DESC) AS exp_rank
	FROM Project p JOIN Employee e 
		ON p.employee_id = e.employee_id
)
SELECT project_id, employee_id
FROM emp_exp_rank
WHERE exp_rank = 1;

-- optimized:
SELECT p.project_id, e.employee_id
FROM Project p JOIN Employee e
		ON e.employee_id = p.employee_id
WHERE (p.project_id, e.experience_years) IN (
	SELECT p.project_id,  MAX(e.experience_years) AS max_exp_years
	FROM Project p JOIN Employee e 
		ON p.employee_id = e.employee_id
	GROUP BY p.project_id
);

WITH emp_max_exp AS (
	SELECT p.project_id,  MAX(e.experience_years) AS max_exp_years
	FROM Project p JOIN Employee e 
		ON p.employee_id = e.employee_id
	GROUP BY p.project_id
)
SELECT p.project_id, e.employee_id
FROM emp_max_exp ep JOIN Project p
		ON ep.project_id = p.project_id
	JOIN Employee e
		ON p.employee_id = e.employee_id AND ep.max_exp_years = e.experience_years;
