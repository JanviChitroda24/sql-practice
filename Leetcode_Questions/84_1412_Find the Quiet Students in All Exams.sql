-- 1412. Find the Quiet Students in All Exams
-- https://leetcode.ca/all/1412.html

-- Table: Student

-- +---------------------+---------+
-- | Column Name         | Type    |
-- +---------------------+---------+
-- | student_id          | int     |
-- | student_name        | varchar |
-- +---------------------+---------+
-- student_id is the primary key for this table.
-- student_name is the name of the student.
 

-- Table: Exam

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | exam_id       | int     |
-- | student_id    | int     |
-- | score         | int     |
-- +---------------+---------+
-- (exam_id, student_id) is the primary key for this table.
-- Student with student_id got score points in exam with id exam_id.
 

-- A "quite" student is the one who took at least one exam and didn't score neither the high score nor the low score.

-- Write an SQL query to report the students (student_id, student_name) being "quiet" in ALL exams.Programming

-- Don't return the student who has never taken any exam. Return the result table ordered by student_id.

-- The query result format is in the following example.

 

-- Student table:
-- +-------------+---------------+
-- | student_id  | student_name  |
-- +-------------+---------------+
-- | 1           | Daniel        |
-- | 2           | Jade          |
-- | 3           | Stella        |
-- | 4           | Jonathan      |
-- | 5           | Will          |
-- +-------------+---------------+

-- Exam table:
-- +------------+--------------+-----------+
-- | exam_id    | student_id   | score     |
-- +------------+--------------+-----------+
-- | 10         |     1        |    70     |
-- | 10         |     2        |    80     |
-- | 10         |     3        |    90     |
-- | 20         |     1        |    80     |
-- | 30         |     1        |    70     |
-- | 30         |     3        |    80     |
-- | 30         |     4        |    90     |
-- | 40         |     1        |    60     |
-- | 40         |     2        |    70     |
-- | 40         |     4        |    80     |
-- +------------+--------------+-----------+

-- Result table:
-- +-------------+---------------+
-- | student_id  | student_name  |
-- +-------------+---------------+
-- | 2           | Jade          |
-- +-------------+---------------+

-- For exam 1: Student 1 and 3 hold the lowest and high score respectively.
-- For exam 2: Student 1 hold both highest and lowest score.
-- For exam 3 and 4: Studnet 1 and 4 hold the lowest and high score respectively.
-- Student 2 and 5 have never got the highest or lowest in any of the exam.
-- Since student 5 is not taking any exam, he is excluded from the result.
-- So, we only return the information of Student 2.

WITH stud_exam AS (
    SELECT s.student_id, s.student_name, 
        DENSE_RANK() OVER(PARTITION BY e.exam_id ORDER BY score) AS min_rank,
        DENSE_RANK() OVER(PARTITION BY e.exam_id ORDER BY score DESC) AS max_rank
    FROM Student s JOIN Exam e
        ON s.student_id = e.student_id
)
SELECT DISTINCT s1.student_id, s1.student_name
FROM stud_exam s1
WHERE NOT EXISTS (
    SELECT 1
    FROM stud_exam s2 
    WHERE s1.student_id = s2.student_id AND 
        (s2.min_rank = 1 OR s2.max_rank = 1)
)
ORDER BY s1.student_id;

-- apprach 2 using nor in
WITH stu_exam AS (
    SELECT s.student_id, s.student_name, 
        DENSE_RANK() OVER(PARTITION BY e.exam_id ORDER BY e.score) AS min_rank,
        DENSE_RANK() OVER(PARTITION BY e.exam_id ORDER BY e.score DESC) AS max_rank
    FROM Student s JOIN Exam e
        ON s.student_id = e.student_id
)
SELECT DISTINCT student_id, student_name
FROM stu_exam
WHERE student_id NOT IN (
    SELECT student_id
    FROM stu_exam
    WHERE min_rank=1 OR max_rank=1
)
ORDER BY student_id;

-- **NOT EXISTS vs NOT IN — Performance Comparison:**

-- **NOT EXISTS:**
-- - Stops scanning as soon as it finds the first matching row (short-circuits)
-- - Handles NULLs safely — if `student_id` is NULL in the subquery, it still works correctly
-- - Generally preferred by optimizers for correlated subqueries

-- **NOT IN:**
-- - Must evaluate the entire subquery result set
-- - **Dangerous with NULLs** — if ANY value in the subquery is NULL, the entire NOT IN returns no rows (because `x NOT IN (1, NULL)` is UNKNOWN, not TRUE)
-- - Simpler to read

-- **For this specific problem:** performance is essentially the same because `student_id` is a primary key (never NULL) and the dataset is small. Most modern optimizers generate similar execution plans for both.

-- **Rule of thumb:**
-- - Use `NOT EXISTS` when NULLs are possible in the subquery — it's always safe
-- - Use `NOT IN` when you're certain there are no NULLs and readability matters
-- - When in doubt, default to `NOT EXISTS`

-- Move on to the next problem!