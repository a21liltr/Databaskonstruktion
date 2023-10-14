DROP DATABASE IF EXISTS a21liltr;
CREATE DATABASE IF NOT EXISTS a21liltr;
USE a21liltr;

CREATE TABLE Farlighet(
    id          TINYINT UNSIGNED AUTO_INCREMENT,
    grad        VARCHAR(16) UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE Kännetecken(
    attribut    VARCHAR(30),
    PRIMARY KEY (attribut)
);

CREATE TABLE Alien(
    IDkod       CHAR(25),
    farlighet   TINYINT UNSIGNED DEFAULT 4,
    rasID       SMALLINT DEFAULT 1,
    ras_namn    VARCHAR(30),
    PRIMARY KEY (IDkod),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id)
);

CREATE INDEX alien_rasnamn_index ON Alien (ras_namn ASC) USING BTREE;

CREATE TABLE Kännetecken_Tillhör_Alien (
    IDkod       CHAR(25),
    alien_kännetecken VARCHAR(32),
    ras_kännetecken VARCHAR(32),
    PRIMARY KEY (IDkod),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),
    FOREIGN KEY (alien_kännetecken) REFERENCES Kännetecken(attribut),
    FOREIGN KEY (ras_kännetecken) REFERENCES Kännetecken(attribut)
);

CREATE TABLE Oregistrerad_Alien(
    namn        VARCHAR (30),
    IDkod       CHAR(25),
    införelsedatum CHAR(15),
    PRIMARY KEY (IDkod),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_införelsedatum_format
    CHECK ( regexp_like(införelsedatum, '^[0-9]{8}-[0-9]{6}$') )
);

CREATE PROCEDURE addera_alien(IN new_id CHAR(25))
    BEGIN
        INSERT IGNORE INTO Alien (IDkod) VALUES (new_id);
    END;

CREATE TRIGGER addera_efter_oregistrerad
    BEFORE INSERT ON Oregistrerad_Alien
    FOR EACH ROW
    BEGIN
        CALL addera_alien(NEW.IDkod);
    END;

CREATE TRIGGER sätt_datum_oreg_alien
    BEFORE INSERT ON Oregistrerad_Alien
    FOR EACH ROW
    BEGIN
        IF NEW.införelsedatum IS NULL OR NEW.införelsedatum = '' THEN
            SET NEW.införelsedatum = CONCAT(DATE_FORMAT(NOW(), '%Y%m%d-'), DATE_FORMAT(NOW(), '%H%i%s'));
        END IF;
    END;

CREATE TABLE Registrerad_Alien(
    namn        VARCHAR(30),
    IDkod       CHAR(25),
    pnr         CHAR(13) UNIQUE,
    hemplanet   VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDkod),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_pnr_format
    CHECK ( regexp_like(pnr, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TRIGGER addera_efter_registrerad
    BEFORE INSERT ON Registrerad_Alien
    FOR EACH ROW
    BEGIN
        CALL addera_alien(NEW.IDkod);
    END;

CREATE FUNCTION sätt_pnr_reg_alien() RETURNS CHAR(13)
DETERMINISTIC
BEGIN
    DECLARE count INT;
    DECLARE new_pnr CHAR(13);

    SELECT COUNT(*) INTO count
    FROM Registrerad_Alien;

    SET new_pnr = CONCAT(DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(count + 1, 4, '0'));
    RETURN new_pnr;
END;

CREATE TRIGGER sätt_datum_reg_alien
    BEFORE INSERT ON Registrerad_Alien
    FOR EACH ROW
    BEGIN
        IF NEW.pnr IS NULL OR NEW.pnr = '' THEN
            SET NEW.pnr = sätt_pnr_reg_alien();
        END IF;
    END;

CREATE TABLE Alien_Relation(
    IDkodA      CHAR(25),
    IDkodB      CHAR(25),
    relation    VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDkodA, IDkodB),
    FOREIGN KEY (IDkodA) REFERENCES Alien(IDkod),
    FOREIGN KEY (IDkodB) REFERENCES Alien(IDkod)
);

CREATE TABLE Alien_Hemligstämplade_Logg(
    loggID      SMALLINT AUTO_INCREMENT,
    logg_datum  DATETIME DEFAULT NOW(),
    IDkod       CHAR(25),
    rasID       SMALLINT,
    ras_namn    VARCHAR(30),
    ras_kännetecken VARCHAR(255) NOT NULL,
    PRIMARY KEY (loggID)
);

CREATE INDEX hemlig_logg_index ON Alien_Hemligstämplade_Logg (logg_datum ASC) USING BTREE;

CREATE TABLE Alien_Hemligstämplade_Logg_Kommentar(
    loggID      SMALLINT AUTO_INCREMENT,
    kommentar   VARCHAR(255),
    PRIMARY KEY (loggID),
    FOREIGN KEY (loggID) REFERENCES Alien_Hemligstämplade_Logg(loggID)
);

CREATE TABLE Skepp(
    id          INT,
    sittplatser INT,
    tillverkningsplanet VARCHAR(30),
    tillverkat  DATE,
    PRIMARY KEY (id)
);

CREATE TRIGGER chk_skepp
BEFORE INSERT ON Skepp
FOR EACH ROW
BEGIN
    -- Det finns för lite information för att veta var ett skepp är tillverkat,
    -- därför sätts tillverkningsplaneten som OKÄNT i det fall då fältet är tomt.
    IF NEW.tillverkningsplanet IS NULL OR '' THEN
        SET NEW.tillverkningsplanet = 'OKÄNT';
    END IF;

    -- CONSTRAINTS som ser till att sittplatser är mellan 1-5000.
    IF NEW.sittplatser IS NULL OR NEW.sittplatser = '' THEN
        SET NEW.sittplatser = FLOOR(1 + RAND() * 5000);
    ELSEIF NEW.sittplatser > 5000 OR NEW.sittplatser < 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'SITTPLATSER must be between 1 and 5000.';
    END IF;
END;

CREATE TABLE Kännetecken_Tillhör_Skepp (
    id          INT,
    kännetecken VARCHAR(30),
    PRIMARY KEY (id, kännetecken),
    FOREIGN KEY (id) REFERENCES Skepp (id),
    FOREIGN KEY (kännetecken) REFERENCES Kännetecken (attribut)
);

CREATE TABLE Skepp_Alien(
    skepp_id    INT,
    alien_IDkod VARCHAR(25),
    PRIMARY KEY (skepp_id, alien_IDkod),
    FOREIGN KEY (skepp_id) REFERENCES Skepp(id),
    FOREIGN KEY (alien_IDkod) REFERENCES Alien(IDkod)
);

CREATE TABLE Vapen(
    vapen_IDnr  INT,
    tillverkat  DATE,
    farlighet   TINYINT UNSIGNED DEFAULT 4,
    alien_IDkod VARCHAR(25),
    skepp_id    INT,
    PRIMARY KEY (vapen_IDnr),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id),
    CONSTRAINT FOREIGN KEY (skepp_id) REFERENCES Skepp (id),
    CONSTRAINT FOREIGN KEY (alien_IDkod) REFERENCES Alien (IDkod),

    -- CHECK som kollar att så att ett fält är tomt.
    CONSTRAINT chk_vapen_null
    CHECK ( alien_IDkod IS NULL OR skepp_id IS NULL ),

    -- CHECK som kollar att ett fält INTE är tomt.
    CONSTRAINT chk_vapen_not_null
    CHECK ( alien_IDkod IS NOT NULL OR skepp_id IS NOT NULL )
);

CREATE TABLE Vapen_Ägare(
    vapen_IDnr  INT,
    alien_IDkod VARCHAR(25),
    skepp_id    INT,
    PRIMARY KEY (vapen_IDnr),
    CONSTRAINT FOREIGN KEY (skepp_id) REFERENCES Skepp (id),
    CONSTRAINT FOREIGN KEY (alien_IDkod) REFERENCES Alien (IDkod),

    -- CHECK som kollar att så att ett fält är tomt.
    CONSTRAINT chk_vapen_ägare_null
    CHECK ( alien_IDkod IS NULL OR skepp_id IS NULL ),

    -- CHECK som kollar att ett fält INTE är tomt.
    CONSTRAINT chk_vapen_ägare_not_null
    CHECK ( alien_IDkod IS NOT NULL OR skepp_id IS NOT NULL )
);

CREATE TABLE Vapen_Inköpsplatser(
    vapen_IDnr  INT,
    inköpsplats VARCHAR(30),
    PRIMARY KEY (vapen_IDnr, inköpsplats),
    FOREIGN KEY (vapen_IDnr) REFERENCES Vapen(vapen_IDnr)
);

CREATE TABLE Procedure_Begränsning (
    användare       VARCHAR(50),
    procedure_namn  VARCHAR(50),
    antal_användningar  TINYINT UNSIGNED NULL DEFAULT 0,
    begränsning     TINYINT UNSIGNED DEFAULT 3,
    PRIMARY KEY (användare, procedure_namn)
);

-- Räknar samtliga rader i Vapen OCH relationstabellen Skepp_Alien som en given Alien IDkod förekommer.
CREATE FUNCTION count_kopplingar(IDkod VARCHAR(25)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT COUNT(*) INTO count
    FROM Skepp_Alien
    JOIN Vapen ON Skepp_Alien.alien_IDkod = Vapen.alien_IDkod
    WHERE Skepp_Alien.alien_IDkod = IDkod;
    RETURN count;
END;

-- Säkerställer så att Alien inte kan har 15 eller fler kopplingar innan addering av ny rad.
CREATE TRIGGER chk_kopplingar_skepp
BEFORE INSERT ON Skepp_Alien
FOR EACH ROW
BEGIN
    DECLARE count INT;
    SET count = count_kopplingar(NEW.alien_IDkod);
    IF count >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alien har redan 15 kopplingar till vapen och/eller rymdkskepp.';
    END IF;
END;

-- Samma som föregående --
CREATE TRIGGER chk_kopplingar_vapen
BEFORE INSERT ON Vapen
FOR EACH ROW
BEGIN
    DECLARE count INT;
    SET count = count_kopplingar(NEW.alien_IDkod);
    IF count >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alien har redan 15 kopplingar till vapen och/eller rymdkskepp.';
    END IF;
END;

-- Hemligstämplar alla aliens rasfält samt rasen självt på rasID.
CREATE PROCEDURE hemligstämpla_ras_med_id(IN param_rasID SMALLINT)
    BEGIN
        -- Loggför aliens med rasen som hemligstämplas. --
        INSERT INTO Alien_Hemligstämplade_Logg(IDkod, rasID)
        SELECT IDkod, rasID FROM Alien
        WHERE rasID = param_rasID;

        -- Sparar information om rasen för återskapande senare.

        INSERT INTO Alien_Hemligstämplade_Logg (ras_namn, ras_kännetecken)
        SELECT a.ras_namn, k.ras_kännetecken
        FROM Kännetecken_Tillhör_Alien k
        JOIN Alien a ON k.IDkod = a.IDkod
        WHERE a.rasID = param_rasID;

        -- Uppdaterar aliens med param_rasID till 'HEMLIGSTÄMPLAT'.
        UPDATE
            Alien
        SET
            rasID = 'HEMLIGSTÄMPLAT'
        WHERE
            rasID = param_rasID;
    END;

-- Avklassificerar både ras och alien med rasID.
CREATE PROCEDURE avklassificera(IN param_rasID SMALLINT)
    BEGIN
        -- Återskapar eventuella kännetecken för rasen.
        INSERT IGNORE INTO Kännetecken_Tillhör_Alien (IDkod, ras_kännetecken)
        SELECT rasID, ras_kännetecken FROM Alien_Hemligstämplade_Logg
        WHERE rasID = param_rasID;

        -- Återger rasen till alla Aliens med samma ras innan hemligstämplande.
        UPDATE
            Alien,
            Alien_Hemligstämplade_Logg
        SET
            Alien.rasID = param_rasID
        WHERE
            Alien.IDkod = Alien_Hemligstämplade_Logg.IDkod
            AND Alien_Hemligstämplade_Logg.rasID = param_rasID;

    END;

-- Avklassificerar en specifik Alien.
CREATE PROCEDURE avklassificera_alien(IN param_alien_idkod CHAR(25))
    BEGIN
        DECLARE matchning TINYINT;

        -- CHECK så att idkoden är hemligstämplat till att börja med.
        SELECT COUNT(*) INTO matchning
        FROM Alien_Hemligstämplade_Logg
        WHERE IDkod = param_alien_idkod;

        -- matchning bör vara antingen 0 ELLER 1, då IDkoden är unik.
        IF matchning = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The IDkod of this Alien does not exist or is NOT HEMLIGSTÄMPLAT.';

        ELSE
            UPDATE
                Alien,
                Alien_Hemligstämplade_Logg
            SET
                Alien.rasID = Alien_Hemligstämplade_Logg.rasID
            WHERE
                Alien.IDkod = Alien_Hemligstämplade_Logg.IDkod
                AND Alien_Hemligstämplade_Logg.IDkod = param_alien_idkod;
        END IF;

    END;

CREATE PROCEDURE radera_alien(IN param_idkod CHAR(25))
BEGIN
    DECLARE användningar TINYINT;
    DECLARE stopp TINYINT;

    SET @nuvarande_användare = CURRENT_USER();

    -- CHECK raderingar --
    SELECT antal_användningar
    INTO användningar
    FROM Procedure_Begränsning
    WHERE användare = @nuvarande_användare
    AND procedure_namn = 'radera_alien';

    -- En USER kan ha en specialbegränsning som är annorlunda från standarden av 3.
    SELECT begränsning
    INTO stopp
    FROM Procedure_Begränsning
    WHERE användare = @nuvarande_användare
    AND procedure_namn = 'radera_alien';

    IF användningar >= stopp THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Du har nått din begränsning för att radera.';

    ELSE
        UPDATE Procedure_Begränsning
        SET antal_användningar = antal_användningar + 1
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_alien';


        -- Raderar alla tillhörande kopplingar, raderingen loggas INTE.
        START TRANSACTION;

        DELETE FROM Alien_Hemligstämplade_Logg WHERE IDkod = param_idkod;

        DELETE FROM Kännetecken_Tillhör_Alien WHERE IDkod = param_idkod;

        DELETE FROM Vapen WHERE alien_idkod = param_idkod;

        DELETE FROM Vapen_Ägare WHERE alien_idkod = param_idkod;

        DELETE FROM Skepp_Alien WHERE alien_idkod = param_idkod;

        DELETE FROM Oregistrerad_Alien WHERE IDkod = param_idkod;
        DELETE FROM Registrerad_Alien WHERE IDkod = param_idkod;

        DELETE FROM Alien_Relation
               WHERE IDkodA = param_idkod
                  OR IDkodB = param_idkod;

        -- Raderar den faktiska alien vars IDkod man har fyllt i.
        DELETE FROM Alien WHERE IDkod = param_idkod;

        COMMIT;
    END IF;
END;

CREATE PROCEDURE radera_skepp (IN rymdskepp_id INT)
    BEGIN
        DECLARE användningar TINYINT;
        DECLARE stopp TINYINT;

        SET @nuvarande_användare = CURRENT_USER();

        -- CHECK raderingar --
        SELECT antal_användningar
        INTO användningar
        FROM Procedure_Begränsning
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_skepp';

        -- En USER kan ha en specialbegränsning som är annorlunda från standarden av 3.
        SELECT begränsning
        INTO stopp
        FROM Procedure_Begränsning
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_skepp';

        IF användningar >= stopp THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Du har nått din begränsning för att radera rymdskepp.';

        ELSE
            UPDATE Procedure_Begränsning
            SET antal_användningar = antal_användningar + 1
            WHERE användare = @nuvarande_användare
            AND procedure_namn = 'radera_aien';

            -- Raderar alla tillhörande kopplingar, raderingen loggas INTE.
            START TRANSACTION;

            DELETE FROM Kännetecken_Tillhör_Skepp WHERE id = rymdskepp_id;

            DELETE FROM Vapen WHERE skepp_id = rymdskepp_id;

            DELETE FROM Skepp_Alien WHERE skepp_id = rymdskepp_id;

            -- Raderar det faktiska skeppet vars id man har fyllt i.
            DELETE FROM Skepp WHERE id = rymdskepp_id;

            COMMIT;
        END IF;
    END;

CREATE PROCEDURE nollställ_begränsning (IN agent VARCHAR(50), IN kommando VARCHAR(50))
    BEGIN
        UPDATE Procedure_Begränsning
        SET antal_användningar = 0
        WHERE användare = agent
        AND procedure_namn = kommando;
    END;

CREATE PROCEDURE ändra_begränsning (IN agent VARCHAR(50), IN kommando VARCHAR(50), IN gräns TINYINT)
    BEGIN
        UPDATE Procedure_Begränsning
        SET begränsning = gräns
        WHERE användare = agent
        AND procedure_namn = kommando;
    END;

-- Skapar olika USERS för databasen med specifika rättigheter beroende på USER typ.
CREATE USER IF NOT EXISTS 'a21liltr_agent'@'%' IDENTIFIED BY 'foo';
GRANT EXECUTE ON PROCEDURE a21liltr.radera_alien TO 'a21liltr_agent'@'%';

CREATE USER IF NOT EXISTS 'a21liltr_administratör'@'%' IDENTIFIED BY 'bar';
GRANT SELECT ON mysql.user TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.nollställ_begränsning TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.ändra_begränsning TO 'a21liltr_administratör'@'%';

-- Förenklad vy för att kunna få en överblick över alla 'personnummer' på registrerade aliens,
-- samt införelsedatum i databasen (som även dessa kommer stå under 'personnummer') för oregistrerade aliens,
-- dvs en överblick över alla registrerade och oregistrerade aliens i en tabell.
-- Här ser man även snabbt vilka aliens som är registrerade då de har en kortare personnummer,
-- medan de oregistrerade aliens har ett längre "personnummer".
CREATE VIEW Alien_Personnummer_view AS
SELECT IDkod, namn, pnr AS 'Personnummer', hemplanet
FROM Registrerad_Alien
UNION
SELECT IDkod, namn, införelsedatum AS 'Personnummer', NULL as 'hemplanet'
FROM Oregistrerad_Alien;

-- Här kan man se en vy över alla aliens och skepp som har kännetecken i en och samma tabell.
CREATE VIEW Kännetecken_Entitet_view AS
SELECT IDkod AS 'ID', alien_kännetecken AS 'Kännetecken'
FROM Kännetecken_Tillhör_Alien
UNION
SELECT id AS 'ID', kännetecken AS 'Kännetecken'
FROM Kännetecken_Tillhör_Skepp;

-- Här kan en användare med lägre auktorisation se en vy över aliens som inte är hemligstämplade.
-- Det kan vara så att enbart agenter med högre auktoritet som får se aliens med hemligstämplade raser.
-- I annat fall kan det även vara bra för att se vilka aliens som inte är hemligstämplade ännu...
CREATE VIEW Offentliga_Raser_view AS
SELECT IDkod, ras_namn
FROM Alien
WHERE ras_namn <> 'HEMLIGSTÄMPLAT' OR ras_namn IS NULL
GROUP BY ras_namn;

CREATE VIEW Hemliga_Aliens_view AS
SELECT IDkod, ras_namn
FROM Alien
WHERE ras_namn = 'HEMLIGSTÄMPLAT'
GROUP BY ras_namn;

-- Här kan man se vilka agenter som har nått sina begränsningar på procedurer.
CREATE VIEW Nått_Begränsning_view AS
SELECT användare AS 'USER', antal_användningar AS 'ANVÄNDNINGAR', begränsning 'GRÄNS', procedure_namn
FROM Procedure_Begränsning
WHERE antal_användningar = begränsning
ORDER BY användare;

-- Här kan man se agenternas medelvärde på användningarna av procedurer.
CREATE VIEW AVG_Användning_view AS
SELECT procedure_namn, AVG(antal_användningar)
FROM Procedure_Begränsning
GROUP BY procedure_namn;





