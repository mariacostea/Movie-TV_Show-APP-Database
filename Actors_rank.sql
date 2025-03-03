CREATE VIEW ActorScoresView AS
WITH ActorScores AS (
    SELECT 
        c.person_id,
        CONCAT(c.person_first_name, ' ', c.person_last_name) AS full_name,
        FLOOR(DATEDIFF(DAY, c.birthdate, GETDATE()) / 365.25) AS age,
        SUM(CASE WHEN p.movie_id IS NOT NULL AND cm.person_id = c.person_id THEN 50 ELSE 0 END) + 
        SUM(CASE WHEN p.movie_id IS NOT NULL AND cm.person_id = c.person_id AND p.person_id IS NOT NULL AND p.person_id = c.person_id THEN 50 ELSE 0 END) + 
        SUM(CASE WHEN r.average_rating > 9 THEN 100 WHEN r.average_rating > 8 THEN 50 ELSE 0 END) AS total_score
    FROM Crew c
    JOIN Crew_movie cm ON c.person_id = cm.person_id
    JOIN Movie m ON cm.movie_id = m.movie_id
    LEFT JOIN Prize p ON m.movie_id = p.movie_id
    LEFT JOIN (
        SELECT movie_id, AVG(CAST(rating AS FLOAT)) AS average_rating 
        FROM Review 
        GROUP BY movie_id
    ) r ON m.movie_id = r.movie_id
    WHERE c.job = 'actor'
    GROUP BY c.person_id, c.person_first_name, c.person_last_name, c.birthdate
    HAVING SUM(CASE WHEN r.average_rating > 9 THEN 100 WHEN r.average_rating > 8 THEN 50 ELSE 0 END) >= 100
)
SELECT 
    full_name,
    age,
    CASE
        WHEN total_score > 1000 THEN 1
        WHEN total_score > 750 THEN 2
        WHEN total_score > 500 THEN 3
        WHEN total_score > 250 THEN 4
        WHEN total_score > 0 THEN 5
        ELSE 'No Rank'
    END AS rank
FROM ActorScores;
