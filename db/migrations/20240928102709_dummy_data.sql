INSERT INTO Composer (LastName, FirstName, Born, Died) VALUES
    ("Beethoven", "Ludwig van", 1770, 1827),
    ("Mozart", "Wolfgang", "Amadeus Gotleib", 1756, 1791);

INSERT INTO Librettist (LastName, FirstName, Born, Died) VALUES
    ("Da Ponte", "Lorenzo", 1749, 1838);

INSERT INTO Language (Name) VALUES
    ("English"),
    ("Italian"),
    ("German"),
    ("French"),
    ("Spanish");

INSERT INTO Work (ComposerID, LibrettistID, LanguageID, Name) VALUES
    (
	(SELECT ID FROM Composer WHERE LastName = "Mozart"),
	(SELECT ID FROM Librettist WHERE (LastName = "Da Ponte" AND FirstName = "Lorenzo")),
	(SELECT ID FROM Language WHERE Name = "Italian"),
	"Le Nozze di Figaro"
    ),
    (
	(SELECT ID FROM Composer WHERE LastName = "Mozart"),
	(SELECT ID FROM Librettist WHERE (LastName = "Da Ponte" AND FirstName = "Lorenzo")),
	(SELECT ID FROM Language WHERE Name = "Italian"),
	"Don Giovanni"
    );

/* 
    UEDR			INTEGER NOT NULL PRIMARY KEY,
    WorkID			INTEGER NOT NULL,
    OriginalMusicalKeyID	INTEGER,
    ImportanceRankID		INTEGER NOT NULL DEFAULT 1,
    Name			TEXT,
    TextIncipit			TEXT,
    Notes			TEXT,
    Link			TEXT,
    Hold			INTEGER NOT NULL DEFAULT 0,	-- BOOL
*/
INSERT INTO Song (UEDR, WorkID, Name) VALUES
    (
	203,
	(SELECT ID FROM Work WHERE Name = "Le Nozze di Figaro"),
	"Cinque Dieci, Venti"
    ),
    (
	204,
	(SELECT ID FROM Work WHERE Name = "Don Giovanni"),
	"Catalogue Aria"
    );

/*
    UEDR		INTEGER NOT NULL,
    VariationDigit1	INTEGER NOT NULL DEFAULT 0,
    VariationDigit2	INTEGER NOT NULL DEFAULT 0,
    MusicalKeyID	INTEGER,
    InstrumentID	INTEGER,
    FolderID		INTEGER,
    FileExtID		INTEGER,
    Notes		TEXT,
*/

INSERT INTO Variation (UEDR, VariationDigit1, VariationDigit2) VALUES
    (
	(
	    SELECT UEDR
	    FROM
		Song s
		JOIN Work w ON w.ID = s.WorkID
		JOIN Composer c ON c.ID = w.ComposerID
	    WHERE
		s.Name = "Cinque Dieci, Venti" AND
		c.LastName = "Mozart"
	),
	0,
	0
    ),
    (
	(
	    SELECT UEDR
	    FROM
		Song s
		JOIN Work w ON w.ID = s.WorkID
		JOIN Composer c ON c.ID = w.ComposerID
	    WHERE
		s.Name = "Catalogue Aria" AND
		c.LastName = "Mozart"
	),
	0,
	0
    );

UPDATE Song
SET
    Name = "Cinque, Dieci, Venti",
    TextIncipit = Name
WHERE
    UEDR = 203;

INSERT INTO Character (Name) VALUES
    ("Claudia"),
    ("Leonardo");

INSERT INTO Song_Character VALUES
    (
	203,
	(SELECT ID FROM Character WHERE Name = "Claudia")
    );

/*
SELECT
    s.Name AS song_name,
    c.ID AS character_ID,
    c.Name AS character_name
FROM
    Song s
    JOIN Song_Character sc ON s.UEDR = sc.UEDR
    JOIN Character c ON sc.CharacterID = c.ID;

UPDATE Character
SET
    ID = 43
WHERE
    Name = "Claudia";

SELECT
    s.Name AS song_name,
    c.ID AS character_ID,
    c.Name AS character_name
FROM
    Song s
    JOIN Song_Character sc ON s.UEDR = sc.UEDR
    JOIN Character c ON sc.CharacterID = c.ID;
*/

/* Select all info from all works
SELECT
  w.Name,
  c.Name AS composer,
  lib.Name AS librettist,
  lang.Name AS language
    FROM Work w
    INNER JOIN Composer c ON c.ID = w.ComposerID
    INNER JOIN Librettist lib ON lib.ID = w.LibrettistID
    INNER JOIN Language lang ON lang.ID = w.LangID;
*/