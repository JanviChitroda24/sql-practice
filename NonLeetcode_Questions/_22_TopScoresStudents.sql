-- Q22

-- You have a table called exam_scores:

-- exam_scores
-- ├── student_id     INT
-- ├── subject        VARCHAR(50)
-- ├── score          INT
-- ├── exam_date      DATE

-- A student can take the same subject exam multiple times. 
-- Write a query that returns each student's score for each subject, 
--     along with the highest score anyone achieved in that subject, 
--     and the percentage difference between the student's score and that top score. 
-- But here's the catch — use a subquery in the WHERE clause to only include students 
--     whose average score across all subjects is above the overall average of all students. 
-- Return student_id, subject, score, top_score_in_subject, and pct_from_top (rounded to 2 decimals).


--INTERPRETATION 1
WITH student_highest_sub_score AS (
    SELECT student_id, subject, score,
        MAX(score) OVER(PARTITION BY subject) AS top_score_in_subject
    FROM exam_scores
    WHERE student_id IN (
        SELECT student_id
        FROM exam_scores
        GROUP BY student_id
        HAVING AVG(score) >
            (
                SELECT AVG(score)
                FROM exam_scores
            )
    ) 
)
SELECT student_id, subject, score, top_score_in_subject, 
    ROUND( ((top_score_in_subject-score)*100.0)/top_score_in_subject ,2) AS pct_from_top
FROM student_highest_sub_score;

--INTERPRETATION 2
WITH student_highest_sub_score AS (
    SELECT student_id, subject, score,
        MAX(score) OVER(PARTITION BY subject) AS top_score_in_subject
    FROM exam_scores
)
SELECT student_id, subject, score, top_score_in_subject, 
    ROUND( ((top_score_in_subject-score)*100.0)/top_score_in_subject ,2) AS pct_from_top
FROM student_highest_sub_score
WHERE student_id IN (
        SELECT student_id
        FROM exam_scores
        GROUP BY student_id
        HAVING AVG(score) >
            (
                SELECT AVG(score)
                FROM exam_scores
            )
    ) 