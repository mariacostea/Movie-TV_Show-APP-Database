CREATE DATABASE movie_db;
GO

USE movie_db;
GO

CREATE TABLE Crew (
    person_id INT PRIMARY KEY,
    person_first_name VARCHAR(100),
    person_last_name VARCHAR(100),
    birthdate DATE,
    job VARCHAR(100)
);

CREATE TABLE Movie (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    duration INT NOT NULL CHECK (duration > 0),
    release_date DATE
);

CREATE TABLE Genre (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(100)
);

CREATE TABLE Genre_Movie (
    genre_id INT NOT NULL REFERENCES Genre(genre_id),
    movie_id INT NOT NULL REFERENCES Movie(movie_id),
    PRIMARY KEY (genre_id, movie_id)
);

CREATE TABLE Prize (
    prize_id INT PRIMARY KEY,
    movie_id INT NOT NULL REFERENCES Movie(movie_id),
    person_id INT REFERENCES Crew(person_id),
    category VARCHAR(100) NOT NULL,
    prize_year INT
);

CREATE TABLE Crew_movie (
    person_id INT NOT NULL REFERENCES Crew(person_id),
    movie_id INT NOT NULL REFERENCES Movie(movie_id),
    PRIMARY KEY (person_id, movie_id)
);

CREATE TABLE [User] (
    user_id INT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(100),
    register_date DATE DEFAULT CAST(GETDATE() AS DATE)
);

CREATE TABLE Review (
    review_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES [User](user_id),
    movie_id INT NOT NULL REFERENCES Movie(movie_id),
    rating INT CHECK (rating >= 1 AND rating <= 10),
    comment TEXT,
    review_date DATE DEFAULT CAST(GETDATE() AS DATE)
);

CREATE TABLE Event (
    event_id INT PRIMARY KEY,
    movie_id INT NOT NULL REFERENCES Movie(movie_id),
    event_date DATE NOT NULL,
    locatie VARCHAR(200),
    nr_participants INT,
    descriere TEXT
);

CREATE TABLE Event_participant (
    event_id INT NOT NULL REFERENCES Event(event_id),
    user_id INT NOT NULL REFERENCES [User](user_id),
    tip VARCHAR(200),
    PRIMARY KEY (event_id, user_id)
);

ALTER TABLE Event_participant
ADD CONSTRAINT chk_EventParticipant_Tip CHECK (tip IN ('host', 'participant'));
GO

CREATE OR ALTER TRIGGER trg_ValidatePrizeCrewMembership
ON Prize
INSTEAD OF INSERT
AS
BEGIN
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN Crew_movie cm ON i.person_id = cm.person_id AND i.movie_id = cm.movie_id
        WHERE i.person_id IS NOT NULL AND cm.person_id IS NULL
    )
    BEGIN
        DECLARE @person_id INT;
        DECLARE @movie_id INT;

        
        SELECT TOP 1 @person_id = i.person_id, @movie_id = i.movie_id
        FROM inserted i
        LEFT JOIN Crew_movie cm ON i.person_id = cm.person_id AND i.movie_id = cm.movie_id
        WHERE i.person_id IS NOT NULL AND cm.person_id IS NULL;

              RAISERROR ('Persoana cu ID %d nu este în distribuția filmului cu ID %d.', 16, 1, @person_id, @movie_id);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    INSERT INTO Prize (prize_id, movie_id, person_id, category, prize_year)
    SELECT prize_id, movie_id, person_id, category, prize_year
    FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER trg_PreventDuplicateParticipation
ON Event_participant
INSTEAD OF INSERT
AS
BEGIN

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Event e1 ON i.event_id = e1.event_id
        JOIN Event_participant ep ON ep.user_id = i.user_id
        JOIN Event e2 ON ep.event_id = e2.event_id
        WHERE e1.event_date = e2.event_date
          AND e1.event_id <> e2.event_id
    )
    BEGIN
        RAISERROR ('Utilizatorul este deja înscris la un alt eveniment care are loc în aceeași zi.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Event_participant ep ON ep.event_id = i.event_id
        WHERE i.tip = 'host' AND ep.tip = 'host'
    )
    BEGIN
        RAISERROR ('Evenimentul deja are un host. Nu pot exista mai mulți organizatori pentru același eveniment.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    INSERT INTO Event_participant (event_id, user_id, tip)
    SELECT event_id, user_id, tip
    FROM inserted;
END;
GO

