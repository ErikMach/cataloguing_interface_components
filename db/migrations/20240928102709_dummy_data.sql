INSERT INTO Composer (LastName, FirstName, MiddleNames, Born, Died) VALUES
    ("Beethoven", "Ludwig van", NULL, 1770, 1827),
    ("Mozart", "Wolfgang", "Amadeus Gotleib", 1756, 1791);

INSERT INTO Librettist VALUES
    (0, "Da Ponte", "Lorenzo", NULL, 1749, 1838);

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