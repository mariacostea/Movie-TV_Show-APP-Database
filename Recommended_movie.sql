CREATE VIEW Recommended_Movie AS
WITH user_genre_avg AS (
    SELECT 
        u.user_id,
        u.username,
        g.genre_name,
        AVG(r.rating) AS average_rating
    FROM 
        Review r
    JOIN 
        [User] u ON r.user_id = u.user_id
    JOIN 
        Movie m ON r.movie_id = m.movie_id
    JOIN 
        Genre_Movie gm ON m.movie_id = gm.movie_id
    JOIN 
        Genre g ON gm.genre_id = g.genre_id
    GROUP BY 
        u.user_id, u.username, g.genre_name
),
preferred_genre AS (
    SELECT 
        uga.user_id,
        uga.username,
        uga.genre_name
    FROM 
        user_genre_avg uga
    WHERE 
        uga.average_rating = (
            SELECT MAX(uga_in.average_rating)
            FROM user_genre_avg uga_in
            WHERE uga_in.user_id = uga.user_id
        )
),
best_unwatched_movie AS (
    SELECT 
        pg.username,
        m.movie_name,
        pg.genre_name AS preferred_genre,
        AVG(r.rating) AS avg_movie_rating,
        COUNT(pr.prize_id) AS prize_count,
        ROW_NUMBER() OVER (
            PARTITION BY pg.username 
            ORDER BY AVG(r.rating) DESC, COUNT(pr.prize_id) DESC
        ) AS rank
    FROM 
        preferred_genre pg
    JOIN 
        Genre g ON g.genre_name = pg.genre_name
    JOIN 
        Genre_Movie gm ON gm.genre_id = g.genre_id
    JOIN 
        Movie m ON gm.movie_id = m.movie_id
    LEFT JOIN 
        Review r ON r.movie_id = m.movie_id AND r.user_id = pg.user_id
    LEFT JOIN 
        Prize pr ON pr.movie_id = m.movie_id
    WHERE 
        r.rating IS NULL 
    GROUP BY 
        pg.username, pg.user_id, m.movie_name, pg.genre_name
)
SELECT 
    username,
    preferred_genre,
    movie_name AS recommended_movie
FROM 
    best_unwatched_movie
WHERE 
    rank = 1;
