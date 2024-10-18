/*
 *	MAIN TABLES
 */

CREATE TABLE IF NOT EXISTS Work
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    ComposerID		INTEGER,
    LibrettistID	INTEGER,
    LanguageID		INTEGER,
    Name		TEXT,

    FOREIGN KEY (ComposerID)	REFERENCES Composer(ID) ON UPDATE CASCADE,
    FOREIGN KEY (LibrettistID)	REFERENCES Librettist(ID) ON UPDATE CASCADE,
    FOREIGN KEY (LanguageID)	REFERENCES Language(ID) ON UPDATE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Song
(
    UEDR			INTEGER NOT NULL PRIMARY KEY,
    WorkID			INTEGER NOT NULL,
    OriginalMusicalKeyID	INTEGER,
    ImportanceRankID		INTEGER NOT NULL DEFAULT 1,
    Name			TEXT,
    TextIncipit			TEXT,
    Notes			TEXT,
    Link			TEXT,
    Hold			INTEGER NOT NULL DEFAULT 0,	-- BOOL

    FOREIGN KEY (WorkID)		REFERENCES Work(ID) ON UPDATE CASCADE,
    FOREIGN KEY (OriginalMusicalKeyID)	REFERENCES MusicalKey(ID) ON UPDATE CASCADE,
    FOREIGN KEY (ImportanceRankID)	REFERENCES ImportanceRank(ID) ON UPDATE CASCADE,

    CHECK (Hold == 0 OR Hold == 1)
) STRICT;

CREATE TABLE IF NOT EXISTS Variation
(
    UEDR		INTEGER NOT NULL,
    VariationDigit1	INTEGER NOT NULL DEFAULT 0,
    VariationDigit2	INTEGER NOT NULL DEFAULT 0,
    MusicalKeyID	INTEGER,
    InstrumentID	INTEGER,
    FolderID		INTEGER,
    FileExtID		INTEGER,
    Notes		TEXT,

    PRIMARY KEY (UEDR, VariationDigit1, VariationDigit2),

    FOREIGN KEY (UEDR)		REFERENCES Song(UEDR) ON UPDATE CASCADE,
    FOREIGN KEY (MusicalKeyID)	REFERENCES MusicalKey(ID) ON UPDATE CASCADE,
    FOREIGN KEY (InstrumentID)	REFERENCES Instrument(ID) ON UPDATE CASCADE,
    FOREIGN KEY (FolderID)	REFERENCES Folder(ID) ON UPDATE CASCADE,
    FOREIGN KEY (FileExtID)	REFERENCES FileExt(ID) ON UPDATE CASCADE,

    CHECK (VariationDigit1 BETWEEN 0 AND 9),
    CHECK (VariationDigit2 BETWEEN 0 AND 9),
    CHECK (VariationDigit2 = 9 OR InstrumentID IS NULL) -- Only have a unique Instrument if VD2==9
) STRICT;

/*
 *	LOOKUP TABLES
 */

CREATE TABLE IF NOT EXISTS Composer
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    LastName		TEXT NOT NULL,
    FirstName		TEXT NOT NULL,
    Born		INTEGER,	-- Year
    Died		INTEGER,	-- Year

    UNIQUE (LastName, FirstName, MiddleNames),
    CHECK (Born BETWEEN 1000 AND 2000),
    CHECK (Died BETWEEN 1000 AND 2000)
) STRICT;

CREATE TABLE IF NOT EXISTS Librettist
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    LastName		TEXT NOT NULL,
    FirstName		TEXT NOT NULL,
    Born		INTEGER,	-- Year
    Died		INTEGER,	-- Year

    UNIQUE (LastName, FirstName, MiddleNames),
    CHECK (Born BETWEEN 1000 AND 2000),
    CHECK (Died BETWEEN 1000 AND 2000)
) STRICT;

CREATE TABLE IF NOT EXISTS Language
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS Character
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS ImportanceRank
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS Keyword
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS MusicalKey
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS Folder
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS FileExt
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS SongProgressStep
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS VariationProgressStep
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

-- `Instrument` Table acts as a "VariationDigit2_Instrument" Domain table, for VD2 != 9
--		      acts as an InstrumentLUT for VD2 == 9
-- Should this be renormalised into 2 tables?
CREATE TABLE IF NOT EXISTS Instrument
(
    ID			INTEGER NOT NULL PRIMARY KEY,
    Name		TEXT NOT NULL UNIQUE
) STRICT;

CREATE TABLE IF NOT EXISTS VocalRange
(
    VariationDigit1	INTEGER NOT NULL,
    VocalRange		TEXT NOT NULL  UNIQUE,
    PRIMARY KEY (VariationDigit1),
    CHECK (VariationDigit1 BETWEEN 0 AND 10)
) STRICT;

/*
 * 	JUNCTION TABLES
 */

CREATE TABLE IF NOT EXISTS Composer_Language
(
    ComposerID		INTEGER NOT NULL,
    LanguageID		INTEGER NOT NULL,
    PRIMARY KEY (ComposerID, LanguageID),
    FOREIGN KEY (ComposerID) REFERENCES Composer(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Langauge(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Song_Character
(
    UEDR		INTEGER NOT NULL,
    CharacterID		INTEGER NOT NULL,
    PRIMARY KEY (UEDR, CharacterID),
    FOREIGN KEY (UEDR)		REFERENCES Song(UEDR) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (CharacterID)	REFERENCES Character(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Work_Keyword
(
    WorkID		INTEGER NOT NULL,
    KeywordID		INTEGER NOT NULL,
    PRIMARY KEY (WorkID, KeywordID),
    FOREIGN KEY (WorkID) REFERENCES Work(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KeywordID) REFERENCES Keyword(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Song_Keyword
(
    UEDR		INTEGER NOT NULL,
    KeywordID		INTEGER NOT NULL,
    PRIMARY KEY (UEDR, KeywordID),
    FOREIGN KEY (UEDR) REFERENCES Song(UEDR) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KeywordID) REFERENCES Keyword(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Variation_Keyword
(
    UEDR		INTEGER NOT NULL,
    VariationDigit1	INTEGER NOT NULL,
    VariationDigit2	INTEGER NOT NULL,
    KeywordID		INTEGER NOT NULL,
    PRIMARY KEY (UEDR, VariationDigit1, VariationDigit2, KeywordID),
    FOREIGN KEY (UEDR, VariationDigit1, VariationDigit2) REFERENCES Variation(UEDR, VariationDigit1, VariationDigit2) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (KeywordID) REFERENCES Keyword(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Song_SongProgressStep
(
    UEDR		INTEGER NOT NULL,
    StepID		INTEGER NOT NULL,
    PRIMARY KEY (UEDR, StepID),
    FOREIGN KEY (UEDR) REFERENCES Song(UEDR) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (StepID) REFERENCES SongProgressStep(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

CREATE TABLE IF NOT EXISTS Variation_VariationProgressStep
(
    UEDR		INTEGER NOT NULL,
    VariationDigit1	INTEGER NOT NULL,
    VariationDigit2	INTEGER NOT NULL,
    StepID		INTEGER NOT NULL,
    PRIMARY KEY (UEDR, VariationDigit1, VariationDigit2, StepID),
    FOREIGN KEY (UEDR, VariationDigit1, VariationDigit2) REFERENCES Variation(UEDR, VariationDigit1, VariationDigit2) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (StepID) REFERENCES VariationProgressStep(ID) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;

/*
 *	DOMAIN TABLES
 */

CREATE TABLE IF NOT EXISTS Domain_Variation_Instrument
(
    VariationDigit2	INTEGER NOT NULL,
    InstrumentID	INTEGER NOT NULL,
    PRIMARY KEY (VariationDigit2, InstrumentID),
    FOREIGN KEY (InstrumentID) REFERENCES Instrument(ID)
) STRICT;

CREATE TABLE IF NOT EXISTS Domain_Folder_FileExt
(
    FolderID	INTEGER NOT NULL,
    FileExtID	INTEGER NOT NULL,
    PRIMARY KEY (FolderID, FileExtID),
    FOREIGN KEY (FolderID) REFERENCES Folder(ID),
    FOREIGN KEY (FileExtID) REFERENCES FileExt(ID)
) STRICT;

/* ----------------------
 *	Triggers
 * ----------------------
 */

CREATE TRIGGER check_folder_fileExt_insert
BEFORE INSERT ON Variation
WHEN (NEW.FolderID IS NOT NULL AND NEW.FileExtID IS NOT NULL)
BEGIN
    SELECT CASE
	WHEN NOT (SELECT EXISTS(SELECT 1 FROM Domain_Folder_FileExt WHERE (FolderID == NEW.FolderID AND FileExtID == NEW.FileExtID)))
	THEN RAISE(ABORT, "Error: Illegal Folder and Filetype combination")
    END;
END;

CREATE TRIGGER check_folder_fileExt_update
BEFORE UPDATE ON Variation
WHEN (NEW.FileID IS NOT NULL AND NEW.FolderID IS NOT NULL)
BEGIN
    SELECT CASE
	WHEN NOT (SELECT EXISTS(SELECT 1 FROM Domain_Folder_FileExt WHERE (FolderID == NEW.FolderID AND FileExtID == NEW.FileExtID)))
	THEN RAISE(ABORT, "Error: Illegal Folder and Filetype combination")
    END;
END;


/* ----------------------
 *	Static Values
 * ----------------------
 */

INSERT INTO ImportanceRank (Name) VALUES
    ("Low"),
    ("Medium"),
    ("High");

INSERT INTO Folder (Name) VALUES
    ("PUBLISHED"),
    ("TO_PUBLISH"),
    ("WIP"),
    ("UNCONVERTED");

INSERT INTO FileExt (Name) VALUES
    ("pdf"),
    ("sib"),
    ("xml"),
    ("mxl"),
    ("musicxml"),
    ("cap");

INSERT INTO Domain_Folder_FileExt
    SELECT fo.ID, fi.ID
    FROM Folder fo
    CROSS JOIN FileExt fi
    WHERE
	(fo.Name, fi.Name) IN (
	VALUES
	    ('TO_PUBLISH',  'pdf'),
	    ('PUBLISHED',   'pdf'),
	    ('WIP',	    'sib'),
	    ('UNCONVERTED', 'xml'),
	    ('UNCONVERTED', 'mxl'),
	    ('UNCONVERTED', 'musicxml'),
	    ('UNCONVERTED', 'cap')
	);

-- Use these tables to create populate MusicalKey
CREATE TABLE IF NOT EXISTS MusicalNote
(
    ID		INTEGER PRIMARY KEY NOT NULL,
    Name	TEXT
) STRICT;
CREATE TABLE IF NOT EXISTS MusicalAccidental
(
    ID		INTEGER PRIMARY KEY NOT NULL,
    Name	TEXT
) STRICT;
CREATE TABLE IF NOT EXISTS MusicalMode
(
    ID		INTEGER PRIMARY KEY NOT NULL,
    Name	TEXT
) STRICT;

INSERT INTO MusicalNote (Name) VALUES
    ("A"),
    ("B"),
    ("C"),
    ("D"),
    ("E"),
    ("F"),
    ("G");

INSERT INTO MusicalAccidental (Name) VALUES
    (""),
    ("-sharp"),
    ("-flat");

INSERT INTO MusicalMode (Name) VALUES
    ("Major"),
    ("Minor");

INSERT INTO MusicalKey (Name) SELECT concat(n.name, a.name, ' ', m.name)
    FROM MusicalNote			n
    CROSS JOIN MusicalAccidental	a
    CROSS JOIN MusicalMode		m;

-- Drop tables as they are no longer needed
DROP TABLE MusicalNote;
DROP TABLE MusicalAccidental;
DROP TABLE MusicalMode;


-- VD1 *matters* here
INSERT INTO VocalRange (VariationDigit1, VocalRange) VALUES
    (0, "Original"),
    (1, "High"),
    (2, "Medium High"),
    (3, "Medium"),
    (4, "Medium Low"),
    (5, "Low"),
    (6, "Medium (Bass Clef)"),
    (7, "Medium Low (Bass Clef)"),
    (8, "Low (Bass Clef)");

-- ID *matters* here (it's VD2 in disguise)
INSERT INTO Instrument (ID, Name) VALUES
    (0, "Piano/Vocal"),
    (1, "Violin"),
    (2, "Flute/Piccolo/Oboe"),
    (3, "Clarinet in B-flat"),
    (4, "Clarinet in A"),
    (5, "Viola"),
    (6, "Cello"),
    (7, "Trumpet in B-flat"),
    (8, "Trumpet (Alternative Key)");

INSERT INTO SongProgressStep (ID, Name) VALUES
    (0, "Fill out Metadata"),
    (1, "Acquire Source"),
    (2, "Convert to Sibelius"),
    (3, "Clean up score");

INSERT INTO VariationProgressStep (ID, Name) VALUES
    (0, "Write Part"),
    (1, "Format with plugin"),
    (2, "Polish to publishing standard"),
    (3, "Convert to PDF");

/*
-- Test folder/fileExt trigger on Variation
INSERT INTO Work (ID) Values (1);

INSERT INTO Song (UEDR, WorkID) Values (0, 1);

INSERT INTO Variation (UEDR, VariationDigit1, VariationDigit2, FolderID, FileExtID, Notes) VALUES
    (0,0,0,
    (SELECT FolderID FROM Domain_Folder_FileExt d
	JOIN FileExt fi ON d.FileExtID = fi.ID
	WHERE FileExtID = "xml"
	LIMIT 1
    ),
    (SELECT ID FROM FileExt WHERE Name = "xml"),
    "Hi");	-- OK

INSERT INTO Variation (UEDR, VariationDigit1, VariationDigit2, FolderID, FileExtID, Notes) VALUES
    (0,1,0,
    (SELECT FolderID FROM Domain_Folder_FileExt d
	JOIN FileExt fi ON d.FileExtID = fi.ID
	WHERE FileExtID = "xml"
	LIMIT 1
    ),
    (SELECT ID FROM FileExt WHERE Name = "sib"),
    "Yo!");	-- Fails
*/
