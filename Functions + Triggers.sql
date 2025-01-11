-- select all the tables from our database
SELECT 
    table_name AS TVDinformation
FROM
    information_schema.tables
WHERE
    table_schema = 'tvd';
    
-- add columnn TotalSalary to the table Actorinfo
ALTER TABLE actorinfo
ADD COLUMN TotalSalary DECIMAL(10, 2);

SELECT 
    *
FROM
    actorinfo;
    
-- set the formula for the column TotalSalary
UPDATE actorinfo 
SET 
    TotalSalary = TotalApperancesinSeries * SalaryPerEpisode
WHERE
    actor_id > 0;

-- TRIGGERS
-- 1
-- create trigger before updating actorinfo
CREATE 
    TRIGGER  before_update_actorinfo
 BEFORE UPDATE ON actorinfo FOR EACH ROW 
    SET NEW . TotalSalary = NEW.TotalApperancesinSeries * NEW.SalaryPerEpisode;


-- now check how trigger works
-- update the salary per episode for Nina Dobrev and check 

UPDATE actorinfo 
SET 
    SalaryPerEpisode = SalaryPerEpisode + 10000
WHERE
    actor_id = 3;

SELECT 
    *
FROM
    actorinfo;

-- 2
-- create trigger before inserting into actorinfo
create trigger before_insert_actorinfo
before insert on actorinfo
for each row
set new.TotalSalary = new.TotalApperancesinSeries * new.SalaryPerEpisode;

-- insert a row into actorinfo and then check the trigger

insert into actorinfo
values(14, 'Sara', 'Canning', '1987-07-14', 'Newfoundland', 'Canada', 1.5, 'Canadian', 12, 34, 12000, NULL);
SELECT 
    *
FROM
    actorinfo;
    
select * from director;

-- 3
-- create trigger so that whenever a director is deleted, the episodes he directed would have Null value as a foreign key
CREATE 
    TRIGGER  before_delete_director
 BEFORE DELETE ON director FOR EACH ROW 
    UPDATE episode e SET e.Director_id = NULL WHERE
        e.Director_id = OLD.Director_id;

-- delete a director, then check the table episode
SELECT 
    Title, Director_id
FROM
    episode;
    
DELETE FROM director 
WHERE
    Director_id = 1;
    
show triggers;

-- FUNCTIONS
-- 1
-- Takes as a parameter the season no and returns the avg views in mln for each episode in that season.

DELIMITER //
create function season_avg_view (s_no int)
returns decimal(10, 2)
READS SQL DATA
DETERMINISTIC
begin
	declare avg_views integer;
		SELECT 
    avg(ViewsInMln)
INTO avg_views FROM
    episode 
WHERE
    episode.season = s_no;
        
	return avg_views;
end;

//             
DELIMITER ;

select season_avg_view(4) as "Avg views for 1 episode in season 4";
select season_avg_view(8) as "Avg views for 1 episode in season 8";


-- 2
-- Takes character name and returns the number of powers he/she holds.

DELIMITER //
create function character_s_powers_number (char_fname varchar(30), char_lname varchar(30))
returns int
READS SQL DATA
DETERMINISTIC
begin
	declare number_of_powers integer;
		SELECT count(p.powername) into number_of_powers
		from characterinformation c join species s on c.species = s.speciesname
        join species_powers sp using(speciesname) join powers p using(powername)
        where c.firstname = char_fname and c.lastname = char_lname;
        
	return number_of_powers;
end;

//             
DELIMITER ;
select * from characterinformation;
select character_s_powers_number("Damon", "Salvatore") as "The number of powers Damon holds";
select character_s_powers_number("Bonnie", "Bennett") as "The number of powers Bonnie holds";

--3
-- takes the nationaliy as a parameter and returns the person of that nationality who receivec highest salary in the frames of TVD show.
DELIMITER //
create function highestsalary_actor_of_nationality (nation varchar(50))
returns varchar(50)
READS SQL DATA
DETERMINISTIC
begin
	declare actor varchar(50);
		SELECT concat(a.firstname, " ", a.lastname) into actor
		from actorinfo a
        where nationality = nation
        order by totalsalary desc
        limit 1;
        
        
	return actor;
end;

//             
DELIMITER ;

select highestsalary_actor_of_nationality("American") as "American actor with highest total salary.";
select highestsalary_actor_of_nationality("Bulgarian") as "Bulgarian actor with highest total salary.";


-- 4
-- Takes a character name as a paremeter and returns the character name with whom he/she was in a romantic relationship for the longest time.


DELIMITER //

CREATE FUNCTION longest_romantic_partner (partner1_fn VARCHAR(50), partner1_ln VARCHAR(50))
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE partner2 VARCHAR(50);

    SELECT concat(c.firstname, " ", c.lastname) INTO partner2
    FROM (
        SELECT r.DurationInMonths as dur, c2.firstname, c2.lastname
		FROM characterinformation c1 
		JOIN relationships r ON r.char_id_1 = c1.char_id
		JOIN characterinformation c2 ON r.char_id_2 = c2.char_id
		WHERE c1.firstname = partner1_fn AND c1.lastname = partner1_ln AND r.relationship_type = 'Romantic'
		UNION
		SELECT r.DurationInMonths, c2.firstname, c2.lastname
		FROM characterinformation c1 
		JOIN relationships r ON r.char_id_2 = c1.char_id
		JOIN characterinformation c2 ON r.char_id_1 = c2.char_id
		WHERE c1.firstname = partner1_fn AND c1.lastname = partner1_ln AND r.relationship_type = 'Romantic') AS c
    ORDER BY dur DESC
    LIMIT 1;

    RETURN partner2;
END;

//

DELIMITER ;

select longest_romantic_partner("Damon", "Salvatore") as "Damon's longest Romantic Partner";
select longest_romantic_partner("Elena", "Gilbert") as "Elena's longest Romantic Partner";



-- PROCEDURES

-- 1 
-- Takes the director name and returns all the directed episodes.

DELIMITER //
create procedure director_episodes (d_fname VARCHAR(30), d_lname VARCHAR(30))

begin
		select concat(d.firstname, " ", d.lastname) as Director, e.*
		from episode e inner join director d on e.director_id = d.director_id
        where d.firstname = d_fname and d.lastname = d_lname;
        
end;

//             
DELIMITER ;


call director_episodes("Julie", "Plec");
call director_episodes("Ernest", "Dickerson");

-- 2 
-- The function takes as parameters the number of episode and season and returns the table of  the songss which were played in that episode.

DELIMITER //

CREATE PROCEDURE episode_songs (IN s_no INT, IN e_no INT)
BEGIN
    SELECT e.season Season, e.episodenumber Episodes, s.*
    FROM songs s
    INNER JOIN songs_episodes se ON s.song_id = se.song_id
    INNER JOIN episode e ON se.season = e.season AND se.episodenumber = e.episodenumber
    WHERE e.Season = s_no AND e.episodenumber = e_no;
END

//
DELIMITER ;

call episode_songs(8, 16);
call episode_songs(1, 3);

-- 3 
-- Takes as parameters the power name and returns the table of all the characters who hold the power.
DELIMITER //
create procedure characters_of_power (p_name VARCHAR(30))

begin
		select concat(c.firstname, " ", c.lastname) as "Character", p.powername, s.speciesname
        from powers p join species_powers sp using(powername) 
        join species s using(speciesname) join characterinformation c on c.species = s.speciesname
        where p.powername = p_name;
        
end;

//             
DELIMITER ;

call characters_of_power("Compulsion");
call characters_of_power("Dream Manipulation");


