CREATE VIEW EventStatusView AS
SELECT 
    e.event_id,
    e.locatie,
    m.movie_name,
    e.event_date,
    e.nr_participants,
    CASE 
        WHEN COUNT(ep.event_id) >= e.nr_participants THEN 'Full'
        ELSE CONVERT(VARCHAR, e.nr_participants - COUNT(ep.event_id)) + ' locuri rămase'
    END AS status
FROM 
    Event e
JOIN 
    Movie m ON e.movie_id = m.movie_id
LEFT JOIN 
    Event_participant ep ON e.event_id = ep.event_id
WHERE 
    e.event_date > GETDATE()
GROUP BY 
    e.event_id, e.locatie, m.movie_name, e.event_date, e.nr_participants;
