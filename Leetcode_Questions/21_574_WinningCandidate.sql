"""
574. Winning Candidate
https://leetcode.ca/all/574.html

574. Winning Candidate
Table: Candidate
+-----+---------+
| id  | Name    |
+-----+---------+
| 1   | A       |
| 2   | B       |
| 3   | C       |
| 4   | D       |
| 5   | E       |
+-----+---------+

Table: Vote
+-----+--------------+
| id  | CandidateId  |
+-----+--------------+
| 1   |     2        |
| 2   |     4        |
| 3   |     3        |
| 4   |     2        |
| 5   |     5        |
+-----+--------------+
id is the auto-increment primary key,
CandidateId is the id appeared in Candidate table.
Write a sql to find the name of the winning candidate, the above example will return the winner B.

+------+
| Name |
+------+
| B    |
+------+

Notes:

You may assume there is no tie, in other words there will be at most one winning candidate.
"""

-- Optimization: Already efficient — one aggregation over Vote, LIMIT 1, then one join to Candidate.
-- Index on Vote(CandidateId) would speed up GROUP BY if Vote is large.

WITH winner_candidate AS (
  	SELECT CandidateId, COUNT(id) AS no_of_votes
	FROM Vote
  	GROUP BY CandidateId		
	ORDER BY no_of_votes DESC
	LIMIT 1
)
SELECT c.name as Name
FROM Candidate c JOIN winner_candidate w
ON c.id = w.CandidateId;

-- ============================================================================
-- SOLUTION USING RANK (or DENSE_RANK): rank by vote count, then take rank = 1
-- ============================================================================
WITH votes_per_candidate AS (
    SELECT CandidateId, COUNT(id) AS no_of_votes
    FROM Vote
    GROUP BY CandidateId
),
ranked AS (
    SELECT CandidateId, no_of_votes,
           RANK() OVER (ORDER BY no_of_votes DESC) AS rnk
    FROM votes_per_candidate
)
SELECT c.name AS Name
FROM Candidate c
JOIN ranked r ON c.id = r.CandidateId
WHERE r.rnk = 1;
--
-- Note: DENSE_RANK() works too (same result when there's no tie). RANK() and
-- DENSE_RANK() both give 1 to the top voter; with ties you'd get multiple
-- rows — problem says "at most one winning candidate" so one row expected.