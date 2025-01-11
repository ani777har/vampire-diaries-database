use TVD;

select *
from Director;

select *
from Songs;

select *
from Episode;

select *
from Songs_episodes;

select *
from Season;

select *
from ActorInfo;

select *
from Families;

select *
from Species;

select *
from Powers;

select *
from Species_Powers;

select *
from ArtifactsObjects;

select *
from Relationships;

select *
from CharacterInformation;

select *
from Characters_Death_Episodes;

select *
from Curses;

-- Ordinary queries

-- DISTINCT

-- 1) Find distinct birth countries of actors in the database.

SELECT DISTINCT
    BirthCountry
FROM
    ActorInfo;

-- 2) List all unique genres of songs in the database.

SELECT DISTINCT
    Genre
FROM
    Songs;


-- ORDER BY, LIMIT

-- 3) Retrieve those actors that are older than 45 years old and take the one with highest number of movies.

SELECT 
    *
FROM
    ActorInfo
WHERE
    DateOfBirth < '1979-05-09'
ORDER BY NofMovies DESC
LIMIT 1;

-- 4) Find the top 5 actors with the highest net worth in million (NetWorthInMln) from the ActorInfo table.

SELECT 
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM
    ActorInfo
ORDER BY NetWorthInMln DESC
LIMIT 5;


-- 5) List the top 2 most common eye colors among characters.

SELECT 
    EyeColor, COUNT(Char_id) AS Count
FROM
    CharacterInformation
GROUP BY EyeColor
ORDER BY COUNT(Char_id) DESC
LIMIT 2;

-- LEFT JOIN, RIGHT JOIN, INNER JOIN

-- 6) Find all species and their main weakness along with any associated powers(with their unique trait), including species that don't have any powers listed yet.

SELECT 
    SpeciesName, MainWeakness, PowerName, p.UniqueTrait
FROM
    (Species s
    LEFT JOIN Species_Powers sp USING (SpeciesName))
        LEFT JOIN
    Powers p USING (PowerName);

-- 7) Find all species who do not have any powers listed.

SELECT 
    s.SpeciesName, sp.PowerName
FROM
    Species_Powers AS sp
        RIGHT JOIN
    Species AS s ON (sp.SpeciesName = s.SpeciesName)
WHERE
    sp.PowerName IS NULL;

-- 8) List all characters and their artifacts. (Only those who have artifacts) 

SELECT 
    ch.Char_id,
    CONCAT(ch.FirstName, ' ', ch.LastName) AS FullName,
    ao.ObjectName
FROM
    CharacterInformation AS ch
        INNER JOIN
    ArtifactsObjects AS ao ON ao.CurrentOwner = ch.Char_id;

-- STRING OPERATIONS

-- 9) Retrieve all episodes where the title contains the word 'Blood'.

SELECT 
    Season, EpisodeNumber, Title
FROM
    Episode
WHERE
    Title LIKE '%blood%';

-- 10) Find all characters whose first name ends with 'a'.

SELECT 
    Char_id, FirstName
FROM
    CharacterInformation
WHERE
    FirstName LIKE '%a';

-- 11) Find all actors whose first name consists of at least 4 characters.

SELECT 
    Actor_id, FirstName
FROM
    ActorInfo
WHERE
    FirstName LIKE '____%';

-- BETWEEN
-- 12) List the seasons with the average rating (Rating) greater or equal than 9 and less or equal than 9.5 from the Season table.

SELECT 
    SeasonNumber, Rating
FROM
    Season
WHERE
    Rating BETWEEN 9 AND 9.5;

-- NOT IN, NOT EXISTS

-- 13) List all the characters that do not own any artifacts/objects (using NOT EXISTS)

SELECT 
    FirstName
FROM
    CharacterInformation ch
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            ArtifactsObjects ao
        WHERE
            ao.CurrentOwner = ch.char_id);

-- 14) Retrieve FamilyNames, whose members do not appear in CharacterInformation table (using NOT IN)

SELECT 
    FamilyName
FROM
    Families AS f
WHERE
    FamilyName NOT IN (SELECT 
            Bloodline_Family
        FROM
            CharacterInformation AS ch
        WHERE
            ch.Bloodline_Family = f.FamilyName);


-- SET OPERATIONS

-- INTERSECT

-- 15) Retrieve those actors names who directed some episodes in the series

(SELECT FirstName, LastName
 FROM ActorInfo)

INTERSECT

(SELECT FirstName, LastName
 FROM Director);


-- UNION

-- 16) Retrieve the full names of all real people in this database

(SELECT CONCAT(FirstName, ' ', LastName) AS FullName
 FROM ActorInfo)

UNION

(SELECT CONCAT(FirstName, ' ', LastName) AS FullName
 FROM Director);
 
 
-- EXCEPT

-- 17) Retrieve the full names of directors, that do not have roles in Vampire Diaries

(SELECT FirstName, LastName
 FROM Director)
 
 EXCEPT
 
(SELECT FirstName, LastName
 FROM ActorInfo);

-- AGGREGATE FUNCTION, NESTED SUBQUERIES, GROUP BY, HAVING

-- 18) List all the romantic relationships where the duration in months is less than the average duration across all relationships.

SELECT 
    CONCAT(c1.FirstName, ' ', c2.LastName) AS Ch_1FullName,
    CONCAT(c2.FirstName, ' ', c2.LastName) AS Ch_2FullName,
    r.DurationInMonths
FROM
    Relationships r
        JOIN
    CharacterInformation c1 ON R.Char_id_1 = C1.Char_id
        JOIN
    CharacterInformation c2 ON R.Char_id_2 = C2.Char_id
WHERE
    R.DurationInMonths < (SELECT 
            AVG(DurationInMonths)
        FROM
            Relationships)
        AND Relationship_type = 'Romantic';

-- 19) List the title and views in thousands of the episodes with more than 3mln views.

SELECT 
    Title, 1000 * ViewsInMln AS ViewsInThousands
FROM
    Episode
WHERE
    ViewsInMln > 3;

-- -- 20) How many such episodes are there

SELECT 
    COUNT(*)
FROM
    Episode
WHERE
    ViewsInMln > 3;

-- 21) Give the list of directors with the number of episodes they directed.

SELECT 
    d.FirstName, d.LastName, COUNT(episodenumber)
FROM
    episode e
        NATURAL JOIN
    director d
GROUP BY director_id;


-- 22) List the seasons along with their views in million with rating > 8.8

SELECT 
    Season, s.Rating, SUM(e.ViewsInMln) AS SeasonViewsInMlmn
FROM
    Season s
        JOIN
    Episode e ON s.SeasonNumber = e.Season
GROUP BY s.SeasonNumber
HAVING s.Rating > 8.8;

-- SET COMPARISON

-- SOME
-- 23) List all the actors whose NetWorthInMln is greater than that of some actors.

SELECT 
    FirstName, LastName, NetWorthInMln
FROM
    ActorInfo
WHERE
    NetWorthInMln > SOME (SELECT 
            NetWorthInMln
        FROM
            ActorInfo);

-- 24) List the actors whose NetWorthInMln is greater than that of all actors younger than 40 years old.

SELECT 
    FirstName, LastName, NetWorthInMln
FROM
    ActorInfo
WHERE
    NetWorthInMln > ALL (SELECT 
            NetWorthInMln
        FROM
            ActorInfo
        WHERE
            DateOfBirth > '1984-05-09');

-- DELETION (not to mix everything, I commented the deletion)

-- 25) Delete all the artifacts, whose current owner is a vampire.
-- select * from ArtifactsObjects;

-- delete from ArtifactsObjects
-- where CurrentOwner in (select Char_id
-- from CharacterInformation
-- where Species = "Vampire");

-- select * from ArtifactsObjects;


-- INSERTION (the same commenting reason for insertion:))

-- 26) Elena and Matt have been dating for about 3 years, so why aren't they in our database 

-- INSERT INTO Relationships(Char_id_1, Char_id_2, Relationship_type, EnemyOrAlly, DurationInMonths)
-- VALUES 
-- (1, 6, 'Romantic', 'Allies', 36)

-- UPDATE (the same reason mentioned above)

-- 27) The screenwriter has decided that for the next episodes all the actors whose eye color is blue, should dye their hair blue and all others to black.

-- UPDATE CharacterInformation 
-- SET 
--     HairColor = CASE
--         WHEN EyeColor = 'Blue' THEN 'blue'
--         ELSE 'black'
--     END;

-- select HairColor
-- from CharacterInformation;

-- VIEWS
-- 28) Actors do not want others to see their networth, let's hide it. (why would someone have the right to look into their pockets?!)

create view actors_2 as (
select Actor_id, FirstName, LastName, DateOfBirth, BirthCity, BirthCountry, Nationality, NofMovies
from ActorInfo
);

-- Let's see what's in it
select *
from actors_2;

-- Now let's delete the view 
drop view actors_2;

-- 29) Find total number of deaths per episode.

WITH DeathsPerEpisode AS (
    SELECT e.Season, e.EpisodeNumber, COUNT(*) AS DeathCount
    FROM Characters_Death_Episodes AS cde
    JOIN Episode AS e ON (cde.EpisodeNumber = e.EpisodeNumber and cde.Season = e.Season)
    GROUP BY e.Season, e.EpisodeNumber
)
SELECT dpe.Season, dpe.EpisodeNumber, dpe.DeathCount
FROM DeathsPerEpisode AS dpe
ORDER BY dpe.Season, dpe.EpisodeNumber;


