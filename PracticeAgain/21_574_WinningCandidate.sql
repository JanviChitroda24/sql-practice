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
--naive appraoch
WITH cand_vote AS (
    SELECT c.name, 
        COUNT(v.id) OVER(PARTITION BY c.id) AS vote_cnt
    FROM Candidate c JOIN Vote v 
    ON c.id = v.CandidateId
),
cand_rank AS (
SELECT name, ROW_NUMBER() OVER(ORDER BY vote_cnt DESC) AS ranking
FROM cand_vote
)
SELECT DISTINCT name
FROM cand_rank
WHERE ranking = 1;

--optimal approach -- without limit
WITH cand_votes AS (
    SELECT c.name, COUNT(v.id) AS vote_cnt
    FROM Candidate c JOIN Vote v 
        ON c.id = v.CandidateId
    GROUP BY c.name 
)
SELECT name
FROM  cand_votes
WHERE vote_cnt = (SELECT MAX(vote_cnt) FROM cand_votes)

-- most optimal -- with limit
SELECT c.name
FROM Candidate c JOIN Vote v 
    ON c.id = v.CandidateId
GROUP BY c.name
ORDER BY COUNT(v.id) DESC
LIMIT 1;