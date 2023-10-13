DROP DATABASE IF EXISTS a21liltr;
CREATE DATABASE IF NOT EXISTS a21liltr;
USE a21liltr;

CREATE TABLE Farlighet(
    grad        VARCHAR(16) UNIQUE,
    id          TINYINT UNSIGNED,
    PRIMARY KEY (id)
);

INSERT INTO Farlighet(grad, id)
VALUES ('Harmlös', 1);
INSERT INTO Farlighet(grad, id)
VALUES ('Halvt harmlös', 2);
INSERT INTO Farlighet(grad, id)
VALUES ('Ofarlig', 3);
INSERT INTO Farlighet(grad, id)
VALUES ('Neutral', 4);
INSERT INTO Farlighet(grad, id)
VALUES ('Svagt farlig', 5);
INSERT INTO Farlighet(grad, id)
VALUES ('Farlig', 6);
INSERT INTO Farlighet(grad, id)
VALUES ('Extremt farlig', 7);
INSERT INTO Farlighet(grad, id)
VALUES ('Spring för livet', 8);

CREATE TABLE Kännetecken(
    attribut    VARCHAR(30),
    PRIMARY KEY (attribut)
);

INSERT INTO Kännetecken (attribut) VALUES ('Hemligt');
INSERT INTO Kännetecken (attribut) VALUES ('Grön');
INSERT INTO Kännetecken (attribut) VALUES ('Gul');
INSERT INTO Kännetecken (attribut) VALUES ('Blå');
INSERT INTO Kännetecken (attribut) VALUES ('Liten');
INSERT INTO Kännetecken (attribut) VALUES ('Söt');
INSERT INTO Kännetecken (attribut) VALUES ('Aggressiv');

SELECT * FROM Kännetecken;

CREATE TABLE Ras(
    rasID      SMALLINT AUTO_INCREMENT,
    namn        VARCHAR(30) UNIQUE,
    PRIMARY KEY (rasID)
);

INSERT INTO Ras (namn) VALUES ('Hemligstämplat');
INSERT INTO Ras (namn) VALUES ('Chihuahua');
INSERT INTO Ras (namn) VALUES ('Tax');

CREATE TABLE Kännetecken_Tillhör_Ras(
    rasID       SMALLINT,
    kännetecken VARCHAR(30),
    PRIMARY KEY (rasID, kännetecken),
    FOREIGN KEY (rasID) REFERENCES Ras(rasID)
);

INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES (1, 'Hemligt');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES (3, 'Liten');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES (3, 'Söt');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES (2, 'Liten');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES (2, 'Aggressiv');

SELECT * FROM Kännetecken_Tillhör_Ras;

CREATE TABLE Ras_Logg(
    id          SMALLINT NOT NULL AUTO_INCREMENT,
    logg_tid    DATETIME NOT NULL DEFAULT NOW(),
    rasID       SMALLINT NOT NULL,
    namn        VARCHAR(30),
    kännetecken VARCHAR(255) NOT NULL,
    kommentar   VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE Alien(
    IDkod       CHAR(25),
    farlighet   TINYINT UNSIGNED DEFAULT 4,
    rasID       SMALLINT,
    PRIMARY KEY (IDkod),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id),
    FOREIGN KEY (rasID) REFERENCES Ras (rasID)
);

CREATE TABLE Alien_Farlighet(
    IDkod       CHAR(25),
    farlighet   TINYINT UNSIGNED DEFAULT 4,
    rasID       SMALLINT,
    PRIMARY KEY (IDkod),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id),
    FOREIGN KEY (rasID) REFERENCES Ras (rasID)
);

CREATE TABLE Oregistrerad_Alien(
    namn        VARCHAR (30),
    IDkod       CHAR(25),
    införelsedatum CHAR(15),
    PRIMARY KEY (IDkod),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_införelsedatum_format
    CHECK ( regexp_like(införelsedatum, '^[0-9]{8}-[0-9]{4}$') )
);

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
    pnr         CHAR(13),
    PRIMARY KEY (IDkod, pnr),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_pnr_format
    CHECK ( regexp_like(pnr, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TABLE Registrerad_Alien_Hemplanet(
    namn        VARCHAR(30),
    IDkod       CHAR(25),
    pnr         CHAR(13),
    hemplanet   VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDkod, pnr),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_pnr_format
    CHECK ( regexp_like(pnr, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TRIGGER sätt_datum_reg_alien
    BEFORE INSERT ON Registrerad_Alien
    FOR EACH ROW
    BEGIN
        IF NEW.pnr IS NULL OR NEW.pnr = '' THEN
            SET NEW.pnr = CONCAT(
                        DATE_FORMAT(NOW(), '%Y%m%d'),               -- dagens datum i formatet YYYYmmDD
                        '-',                                        -- ett bindesstreck för att separera datumet från de sista 4 siffrorna
                        LPAD(CAST((SELECT MAX(RIGHT(pnr, 4) + 1)    -- 4 siffror som ökar för varje rad insert
                                   FROM Registrerad_Alien) AS UNSIGNED), 4, '0'));
        END IF;
    END;

CREATE TRIGGER registrera_alien_utan_planet
    AFTER INSERT ON Registrerad_Alien_Hemplanet
    FOR EACH ROW
    BEGIN
        INSERT INTO Registrerad_Alien(namn, IDkod, pnr) VALUES (NEW.namn, NEW.IDkod, NEW.pnr);
    END;

-- Relation mellan 2 aliens, vare sig de är reg eller oreg
-- Kan inte ha foreign keys på grund av vertikal split
CREATE TABLE Alien_Relation(
    IDkodA   CHAR(25),
    IDkodB  CHAR(25),
    relation    VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDkodA, IDkodB),
    FOREIGN KEY (IDkodA) REFERENCES Alien(IDkod),
    FOREIGN KEY (IDkodB) REFERENCES Alien(IDkod)
);

CREATE TABLE Alien_Hemligstämplade_Logg(
    sekretessid SMALLINT NOT NULL AUTO_INCREMENT,
    logg_datum   DATETIME DEFAULT NOW(),
    IDkod       CHAR(25),
    rasID       SMALLINT,
    PRIMARY KEY (sekretessid)
);

CREATE TABLE Kännetecken_Tillhör_Alien (
    IDkod       VARCHAR(25),
    kännetecken VARCHAR(255) NOT NULL,
    PRIMARY KEY (IDkod, kännetecken),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod)
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
    DECLARE planet VARCHAR(30);
    DECLARE alien_existerar CHAR (25);

    -- Det finns för lite information för att veta var ett skepp är tillverkat,
    -- därför sätts tillverkningsplaneten som OKÄNT i det fall då fältet är tomt.
    IF NEW.tillverkningsplanet IS NULL OR '' THEN
        SET NEW.tillverkningsplanet = 'OKÄNT';
    END IF;

    -- CONSTRAINTS som ser till att sittplatser är mellan 1-5000.
    CASE
        WHEN NEW.sittplatser IS NULL OR NEW.sittplatser = '' THEN
            SET NEW.sittplatser = FLOOR(1 + RAND() * 5000);
        WHEN NEW.sittplatser > 5000 OR NEW.sittplatser < 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'SITTPLATSER must be between 1 and 5000.';
    END CASE;
END;

CREATE TABLE Kännetecken_Tillhör_Skepp (
    id          INT NOT NULL,
    kännetecken VARCHAR(30) NOT NULL,
    PRIMARY KEY (id, kännetecken),
    FOREIGN KEY (id) REFERENCES Skepp (id)
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

    -- CHECK som kollar att så att ett fält är tomt. --
    CONSTRAINT chk_vapen_alienid_skeppid
    CHECK ( alien_IDkod IS NULL OR skepp_id IS NULL ),

    -- CHECK som kollar att ett fält INTE är tomt. --
    CONSTRAINT chk_vapen_har_alienid_skeppid
    CHECK ( alien_IDkod IS NOT NULL OR skepp_id IS NOT NULL )
);

CREATE TABLE Vapen_Inköpsplatser(
    vapen_IDnr  INT,
    inköpsplats VARCHAR(30),
    PRIMARY KEY (vapen_IDnr, inköpsplats),
    FOREIGN KEY (vapen_IDnr) REFERENCES Vapen(vapen_IDnr)
);

CREATE TABLE Procedure_Begränsning (
    användare       VARCHAR(50) NOT NULL,
    procedure_namn  VARCHAR(50) NOT NULL,
    antal_användningar  TINYINT UNSIGNED NULL DEFAULT 0,
    begränsning     TINYINT UNSIGNED DEFAULT 3,
    PRIMARY KEY (användare, procedure_namn)
);

-- Räknar samtliga rader i Vapen OCH relationstabellen Skepp_Alien som en given Alien IDkod förekommer --
CREATE FUNCTION count_Kopplingar(IDkod VARCHAR(25)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT COUNT(*) INTO count
    FROM Skepp_Alien
    JOIN Vapen ON Skepp_Alien.alien_IDkod = Vapen.alien_IDkod
    WHERE Skepp_Alien.alien_IDkod = IDkod;
    RETURN count;
END;

-- Säkerställer så att Alien inte kan har 15 eller fler kopplingar innan addering av ny rad --
CREATE TRIGGER chk_kopplingar_skepp
BEFORE INSERT ON Skepp_Alien
FOR EACH ROW
BEGIN
    DECLARE count INT;
    SET count = count_Kopplingar(NEW.alien_IDkod);
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
    SET count = count_Kopplingar(NEW.alien_IDkod);
    IF count >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alien har redan 15 kopplingar till vapen och/eller rymdkskepp.';
    END IF;
END;

-- Hemligstämplar alla aliens rasfält samt rasen självt på rasID. --
CREATE PROCEDURE hemligstämpla_ras_med_id(IN param_rasID SMALLINT)
    BEGIN
        DECLARE existerar SMALLINT;

        -- Kollar om 'Hemligstämplat redan existerar. --
        SELECT COUNT(*) INTO existerar
        FROM Ras
        WHERE namn = 'HEMLIGSTÄMPLAT';

        IF existerar = 0 THEN
            -- Skapar 'HEMLIGSTÄMPLAT' om den inte redan finns. --
            INSERT INTO Ras (namn)
            VALUES ('HEMLIGSTÄMPLAT');
        END IF;

        -- Loggför aliens med rasen som hemligstämplas. --
        INSERT INTO Alien_Hemligstämplade_Logg(IDkod, rasID)
        SELECT IDkod, rasID FROM Alien
        WHERE rasID = param_rasID;

        -- Sparar information om rasen för återskapande senare. --
        INSERT INTO Ras_Logg(rasID, kännetecken)
        SELECT rasID, kännetecken FROM Kännetecken_Tillhör_Ras
        WHERE rasID = param_rasID;

        -- Uppdaterar aliens med rasen till 'HEMLIGSTÄMPLAT'. --
        UPDATE
            Alien,
            Ras
        SET
            Alien.rasID = Ras.rasID
        WHERE Ras.rasID = param_rasID;

        DELETE FROM Ras WHERE rasID = param_rasID;
    END;

-- Avklassificerar både ras och alien med rasID --
CREATE PROCEDURE avklassificera(IN param_rasID SMALLINT)
    BEGIN
        -- Insertar så länge rasen inte redan finns med --
        INSERT IGNORE INTO Ras (rasID, namn)
        SELECT rasID, namn FROM Ras_Logg
        WHERE Ras_Logg.rasID = param_rasID;

        -- Återskapar eventuella kännetecken för rasen --
        INSERT IGNORE INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
        SELECT rasID, kännetecken FROM Ras_Logg
        WHERE rasID = param_rasID;

        -- Återger rasen till alla Aliens med samma ras innan hemligstämplande --
        UPDATE
            Alien,
            Alien_Hemligstämplade_Logg
        SET
            Alien.rasID = param_rasID
        WHERE
            Alien.IDkod = Alien_Hemligstämplade_Logg.IDkod
            AND Alien_Hemligstämplade_Logg.rasID = param_rasID;

    END;

-- Avklassificerar en specifik Alien --
CREATE PROCEDURE avklassificera_Alien(IN param_alien_idkod CHAR(25))
    BEGIN
        DECLARE matchning TINYINT;

        -- CHECK så att idkoden är hemligstämplat till att börja med. --
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
    FROM procedure_begränsning
    WHERE användare = @nuvarande_användare
    AND procedure_namn = 'radera_alien';

    -- En USER kan ha en specialbegränsning som är annorlunda från standarden av 3.
    SELECT begränsning
    INTO stopp
    FROM procedure_begränsning
    WHERE användare = @nuvarande_användare
    AND procedure_namn = 'radera_alien';

    IF användningar >= stopp THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Du har nått din begränsning för att radera.';

    ELSE
        UPDATE procedure_begränsning
        SET antal_användningar = antal_användningar + 1
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_aien';


        -- Raderar alla tillhörande kopplingar, raderingen loggas INTE. --
        START TRANSACTION;

        DELETE FROM Alien_Hemligstämplade_Logg WHERE IDkod = param_idkod;

        DELETE FROM Kännetecken_Tillhör_Alien WHERE IDkod = param_idkod;

        DELETE FROM Vapen WHERE alien_idkod = param_idkod;

        DELETE FROM Skepp_Alien WHERE alien_idkod = param_idkod;

        DELETE FROM Oregistrerad_Alien WHERE IDkod = param_idkod;
        DELETE FROM Registrerad_Alien WHERE IDkod = param_idkod;

        DELETE FROM Alien_Relation
               WHERE IDkodA = param_idkod
                  OR IDkodB = param_idkod;

        -- Raderar den faktiska alien vars IDkod man har fyllt i. --
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
        FROM procedure_begränsning
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_skepp';

        -- En USER kan ha en specialbegränsning som är annorlunda från standarden av 3.
        SELECT begränsning
        INTO stopp
        FROM procedure_begränsning
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_skepp';

        IF användningar >= stopp THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Du har nått din begränsning för att radera rymdskepp.';

        ELSE
            UPDATE procedure_begränsning
            SET antal_användningar = antal_användningar + 1
            WHERE användare = @nuvarande_användare
            AND procedure_namn = 'radera_aien';


            -- Raderar alla tillhörande kopplingar, raderingen loggas INTE. --
            START TRANSACTION;

            DELETE FROM Kännetecken_Tillhör_Skepp WHERE id = rymdskepp_id;

            DELETE FROM Vapen WHERE skepp_id = rymdskepp_id;

            DELETE FROM Skepp_Alien WHERE skepp_id = rymdskepp_id;

            -- Raderar det faktiska skeppet vars id man har fyllt i. --
            DELETE FROM Skepp WHERE id = rymdskepp_id;

            COMMIT;
        END IF;
    END;

CREATE PROCEDURE nollställ_begränsning (IN agent VARCHAR(50), IN kommando VARCHAR(50))
    BEGIN
        UPDATE procedure_begränsning
        SET antal_användningar = 0
        WHERE användare = agent
        AND procedure_namn = kommando;
    END;

CREATE PROCEDURE ändra_begränsning (IN agent VARCHAR(50), IN kommando VARCHAR(50), IN gräns TINYINT)
    BEGIN
        UPDATE procedure_begränsning
        SET begränsning = gräns
        WHERE användare = agent
        AND procedure_namn = kommando;
    END;

-- Skapar olika USERS för databasen med specifika rättigheter beroende på USER typ.
CREATE USER IF NOT EXISTS 'a21liltr_agent'@'%' IDENTIFIED BY 'foo';
GRANT SELECT ON a21liltr.Ras TO 'a21liltr_agent'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.radera_alien TO 'a21liltr_agent'@'%';

CREATE USER IF NOT EXISTS 'a21liltr_administratör'@'%' IDENTIFIED BY 'bar';
GRANT SELECT ON mysql.user TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.nollställ_begränsning TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.ändra_begränsning TO 'a21liltr_administratör'@'%';







