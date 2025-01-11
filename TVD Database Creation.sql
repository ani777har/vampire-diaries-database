create database TVD;
use TVD;

CREATE TABLE Species (
    SpeciesName VARCHAR(100) PRIMARY KEY,
    MainAbility VARCHAR(100) NOT NULL,
    MainWeakness VARCHAR(100) NOT NULL
);

CREATE TABLE Families (
    FamilyName VARCHAR(255) PRIMARY KEY,
    FamilyDescription TEXT NOT NULL,
    Residence VARCHAR(255) NOT NULL,
    CurrentHead VARCHAR(255) NOT NULL,
    Founder VARCHAR(255) NOT NULL,
    OriginDate DATE NOT NULL
);
CREATE TABLE ActorInfo (
    Actor_id INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    DateOfBirth DATE NOT NULL,
    BirthCity VARCHAR(50),
    BirthCountry VARCHAR(50) NOT NULL, 
    NetWorthInMln DECIMAL(10,2),
    Nationality VARCHAR(50),
    NofMovies INT,
    TotalApperancesinSeries INT NOT NULL,
    SalaryPerEpisode INT NOT NULL
);

CREATE TABLE CharacterInformation (
    Char_id INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    Species VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    PlaceOfBirth VARCHAR(255),
    Bloodline_Family VARCHAR(255),
    Actor_id INT NOT NULL,
    Height VARCHAR(10),
    EyeColor VARCHAR(50),
    HairColor VARCHAR(50),
	FOREIGN KEY (Species) REFERENCES Species(SpeciesName),
    FOREIGN KEY (Bloodline_Family) REFERENCES Families(FamilyName),
    FOREIGN KEY (Actor_id) REFERENCES ActorInfo(Actor_id)
);

CREATE TABLE Season (
    SeasonNumber INT PRIMARY KEY,
    Rating VARCHAR(30),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);


CREATE TABLE Relationships (
    Char_id_1 INT,
    Char_id_2 INT,
    Relationship_type VARCHAR(100) NOT NULL,
    EnemyOrAlly VARCHAR(10) NOT NULL,
    DurationInMonths INT,
    PRIMARY KEY (Char_id_1, Char_id_2),
    FOREIGN KEY (Char_id_1) REFERENCES CharacterInformation(Char_id),
    FOREIGN KEY (Char_id_2) REFERENCES CharacterInformation(Char_id),
	CHECK (EnemyOrAlly IN ('Enemies', 'Allies', 'Neutral')) -- Add CHECK constraint
);

CREATE TABLE Director (
    Director_id INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    DateOfBirth DATE ,
    Nationality VARCHAR(100)
);

CREATE TABLE Episode (
    EpisodeNumber INT,
    Season INT,
    Title VARCHAR(255) NOT NULL,
    ReleaseDate DATE NOT NULL,
    Director_id INT,
    ViewsInMln DECIMAL(10 , 2 ),
    PRIMARY KEY (Season , EpisodeNumber),
    FOREIGN KEY (Season)
        REFERENCES Season (SeasonNumber),
    FOREIGN KEY (Director_id)
        REFERENCES Director (Director_id)
);

CREATE TABLE Songs (
    Song_id INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Artist VARCHAR(255) NOT NULL,
    Album VARCHAR(255),
    ReleaseYear INT NOT NULL,
    Genre VARCHAR(100) NOT NULL
);

CREATE TABLE Songs_Episodes (
    Song_id INT,
    Season INT,
    EpisodeNumber INT,
    PRIMARY KEY (Song_id, EpisodeNumber, Season),
    FOREIGN KEY (Song_id) REFERENCES Songs(Song_id),
    FOREIGN KEY (Season, EpisodeNumber) REFERENCES Episode(Season,EpisodeNumber)
);

CREATE TABLE ArtifactsObjects (
    ObjectID INT AUTO_INCREMENT PRIMARY KEY,
    ObjectName VARCHAR(255) NOT NULL,
    Description TEXT,
    CurrentOwner INT,
    FOREIGN KEY (CurrentOwner) REFERENCES CharacterInformation(Char_id)
);


CREATE TABLE Powers (
    PowerName VARCHAR(255) PRIMARY KEY,
    Weakness VARCHAR(100) NOT NULL,
    UniqueTrait VARCHAR(100) NOT NULL
);


CREATE TABLE Species_Powers (
    SpeciesName VARCHAR(100),
    PowerName VARCHAR(255),
    PRIMARY KEY (SpeciesName, PowerName),
    FOREIGN KEY (SpeciesName) REFERENCES Species(SpeciesName),
    FOREIGN KEY (PowerName) REFERENCES Powers(PowerName)
);


CREATE TABLE Curses(
    CurseName VARCHAR(255) PRIMARY KEY,
    IntroSeason INT NOT NULL,
    IntroEpisode INT NOT NULL,
    BreakSeason INT NOT NULL,
    BreakEpisode INT NOT NULL,
	FOREIGN KEY (IntroSeason, IntroEpisode) REFERENCES Episode(Season,EpisodeNumber),
    FOREIGN KEY (BreakSeason, BreakEpisode) REFERENCES Episode(Season,EpisodeNumber)
);


CREATE TABLE Characters_Death_Episodes(
	Char_id INT,
    Season INT NOT NULL,
    EpisodeNumber INT NOT NULL,
	PRIMARY KEY(Char_id, Season, EpisodeNumber),
	FOREIGN KEY (Season, EpisodeNumber) REFERENCES Episode(Season,EpisodeNumber),
    FOREIGN KEY (Char_id) REFERENCES CharacterInformation(Char_id)
);

