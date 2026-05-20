-- 618. Students Report By Geography
-- https://leetcode.ca/all/618.html

-- A U.S graduate school has students from Asia, Europe and America. The students' location information are stored in table student as below.
 

-- | name   | continent |
-- |--------|-----------|
-- | Jack   | America   |
-- | Pascal | Europe    |
-- | Xi     | Asia      |
-- | Jane   | America   |
 

-- Pivot the continent column in this table so that each name is sorted alphabetically and displayed underneath its corresponding continent. The output headers should be America, Asia and Europe respectively. It is guaranteed that the student number from America is no less than either Asia or Europe.
 

-- For the sample input, the output is:
-- | America | Asia | Europe |
-- |---------|------|--------|
-- | Jack    | Xi   | Pascal |
-- | Jane    |      |        |
 

-- Follow-up: If it is unknown which continent has the most students, can you write a query to generate the student report?
 

SELECT 
    CASE continent
        WHEN 'America' THEN name
    END AS 'America',
    CASE continent
        WHEN 'Asia' THEN name
    END AS 'Asia',
    CASE continent
         WHEN 'Europe' THEN name
    END AS 'Europe'
FROM student;

No — your query would produce something like this:

-- | America | Asia | Europe |
-- |---------|------|--------|
-- | Jack | NULL | NULL |
-- | NULL | NULL | NULL |
-- | NULL | Xi | NULL |
-- | Jane | NULL | NULL |
-- | NULL | NULL | Pascal |

-- Each row has only one non-NULL value because each student belongs to one continent. You need the names to **line up side by side**.

-- The trick is: you need a **row number** to align names across continents. Think about it — Jack and Xi should be on the same row because they're both the **first** name alphabetically in their respective continents.

-- Hint: use `ROW_NUMBER() OVER (PARTITION BY continent ORDER BY name)` to assign each student a position within their continent. Then GROUP BY that row number and use your CASE expressions with MAX to collapse the rows.

-- Don't overthink it — you already know pivot and ROW_NUMBER. This just combines them. Go try it!

WITH stud_rn AS (
    SELECT name, continent, 
        ROW_NUMBER() OVER(PARTITION BY continent ORDER BY name) AS rn
    FROM student
)
SELECT COALESCE(MAX(CASE continent
        WHEN 'America' THEN name
        END),'') AS 'America',
        COALESCE(MAX(CASE continent
        WHEN 'Asia' THEN name
        END),'') AS 'Asia',
        COALESCE(MAX(CASE continent
        WHEN 'Europe' THEN name
        END),'') AS 'Europe'
FROM stud_rn
GROUP BY rn;

-- The query is correct. Now let me explain the NULL issue.

-- **Without ROW_NUMBER and GROUP BY, your raw data looks like:**

-- | name | continent |
-- |------|-----------|
-- | Jack | America |
-- | Jane | America |
-- | Xi | Asia |
-- | Pascal | Europe |

-- Each row produces CASE values like:

-- | Row | America | Asia | Europe |
-- |-----|---------|------|--------|
-- | Jack | Jack | NULL | NULL |
-- | Jane | Jane | NULL | NULL |
-- | Xi | NULL | Xi | NULL |
-- | Pascal | NULL | NULL | Pascal |

-- Four rows, each with two NULLs. No way to combine them.

-- **With ROW_NUMBER, each student gets a position within their continent:**

-- | name | continent | rn |
-- |------|-----------|-----|
-- | Jack | America | 1 |
-- | Jane | America | 2 |
-- | Xi | Asia | 1 |
-- | Pascal | Europe | 1 |

-- **Now GROUP BY rn collapses rows with the same rn:**

-- Group rn=1 contains: Jack (America), Xi (Asia), Pascal (Europe)

-- | | America | Asia | Europe |
-- |---|---------|------|--------|
-- | Jack | Jack | NULL | NULL |
-- | Xi | NULL | Xi | NULL |
-- | Pascal | NULL | NULL | Pascal |

-- `MAX` picks the non-NULL value from each column: Jack, Xi, Pascal → one clean row.

-- Group rn=2 contains: Jane (America) only

-- | | America | Asia | Europe |
-- |---|---------|------|--------|
-- | Jane | Jane | NULL | NULL |

-- `MAX` picks: Jane, NULL, NULL → second row.

-- **Final result:**

-- | America | Asia | Europe |
-- |---------|------|--------|
-- | Jack | Xi | Pascal |
-- | Jane | NULL | NULL |

-- So ROW_NUMBER creates the **alignment** and MAX **collapses** the NULLs within each group. That's the pattern.