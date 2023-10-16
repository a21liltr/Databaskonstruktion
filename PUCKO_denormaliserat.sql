DROP DATABASE IF EXISTS a21liltr;
CREATE DATABASE IF NOT EXISTS a21liltr;
USE a21liltr;

CREATE TABLE användare (
    id  INT AUTO_INCREMENT,
    användarnamn   VARCHAR(50) NOT NULL,
    lösenord    VARCHAR(100) NOT NULL,
    roll        VARCHAR(32) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Trigger_Logg (
    logg_id INT AUTO_INCREMENT,
    loggtid TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    trigger_typ ENUM ('RADERING', 'INSÄTTNING', 'UPPDATERING'),
    data    VARCHAR(32) NOT NULL,
    användare   VARCHAR(50) NOT NULL,
    PRIMARY KEY (logg_id)
);

CREATE TABLE Hemligstämplat_Logg
(
    loggID      SMALLINT AUTO_INCREMENT,
    logg_datum  TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    alien_id    CHAR(25),
    ras_namn    VARCHAR(30),
    ras_kännetecken VARCHAR(255) NOT NULL,
    PRIMARY KEY (loggID)
);

CREATE INDEX hemlig_logg_index ON Hemligstämplat_Logg (logg_datum ASC) USING BTREE;

CREATE TABLE Hemligstämplat_Logg_Kommentar
(
    loggID      SMALLINT AUTO_INCREMENT,
    kommentar   VARCHAR(255),
    PRIMARY KEY (loggID),
    FOREIGN KEY (loggID) REFERENCES Hemligstämplat_Logg (loggID)
);


CREATE TABLE Farlighet(
    farlighet_id    TINYINT UNSIGNED AUTO_INCREMENT,
    grad            VARCHAR(16) UNIQUE,
    PRIMARY KEY (farlighet_id)
);

CREATE TABLE Kännetecken(
    attribut    VARCHAR(30),
    PRIMARY KEY (attribut)
);

CREATE TABLE Alien(
    alien_id    CHAR(25),
    farlighet   TINYINT UNSIGNED DEFAULT 4,
    ras_namn    VARCHAR(30),
    PRIMARY KEY (alien_id),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (farlighet_id),
    UNIQUE (alien_id, ras_namn)
);

CREATE INDEX alien_rasnamn_index ON Alien (ras_namn ASC) USING BTREE;

CREATE TABLE Oregistrerad_Alien(
    alien_id       CHAR(25),
    namn           VARCHAR (30),
    införelsedatum CHAR(15),
    PRIMARY KEY (alien_id),
    FOREIGN KEY (alien_id) REFERENCES Alien (alien_id),

    CONSTRAINT chk_införelsedatum_format
    CHECK ( regexp_like(införelsedatum, '^[0-9]{8}-[0-9]{6}$') )
);

CREATE PROCEDURE addera_alien(IN new_id CHAR(25))
    BEGIN
        INSERT IGNORE INTO Alien (alien_id) VALUES (new_id);
    END;

CREATE TRIGGER addera_oregistrerad
    BEFORE INSERT
    ON Oregistrerad_Alien
    FOR EACH ROW
    BEGIN
        CALL addera_alien(NEW.alien_id);
    END;

CREATE TRIGGER sätt_datum_oreg_alien
    BEFORE INSERT
    ON Oregistrerad_Alien
    FOR EACH ROW
    BEGIN
        IF NEW.införelsedatum IS NULL OR NEW.införelsedatum = '' THEN
            SET NEW.införelsedatum = CONCAT(DATE_FORMAT(NOW(), '%Y%m%d-'), DATE_FORMAT(NOW(), '%H%i%s'));
        END IF;
    END;

CREATE TABLE Registrerad_Alien(
    alien_id    CHAR(25),
    namn        VARCHAR(30),
    pnr         CHAR(13) UNIQUE,
    hemplanet   VARCHAR(30) NOT NULL,
    PRIMARY KEY (alien_id),
    FOREIGN KEY (alien_id) REFERENCES Alien (alien_id),

    CONSTRAINT chk_pnr_format
    CHECK ( regexp_like(pnr, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TRIGGER addera_registrerad
    BEFORE INSERT
    ON Registrerad_Alien
    FOR EACH ROW
    BEGIN
        DECLARE ny_ras VARCHAR(30);
        DECLARE sparade_raser SMALLINT;

        CALL addera_alien(NEW.alien_id);
        IF NEW.hemplanet IS NOT NULL OR NEW.hemplanet <> '' THEN
            UPDATE Alien
            SET ras_namn = CONCAT(NEW.hemplanet, 'ian')
            WHERE Alien.alien_id = NEW.alien_id;
        END IF;
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
    BEFORE INSERT
    ON Registrerad_Alien
    FOR EACH ROW
    BEGIN
        IF NEW.pnr IS NULL OR NEW.pnr = '' THEN
            SET NEW.pnr = sätt_pnr_reg_alien();
        END IF;
    END;

CREATE TABLE Alien_Relation(
    alien_idA   CHAR(25),
    alien_idB   CHAR(25),
    relation    VARCHAR(30) NOT NULL,
    PRIMARY KEY (alien_idA, alien_idB),
    FOREIGN KEY (alien_idA) REFERENCES Alien(alien_id),
    FOREIGN KEY (alien_idB) REFERENCES Alien(alien_id)
);

CREATE TRIGGER logga_insättning_alien
    BEFORE INSERT
    ON Alien
    FOR EACH ROW
    BEGIN
        INSERT INTO Trigger_Logg (trigger_typ, data, användare)
            VALUES ('INSÄTTNING', CONCAT('Alien: ', NEW.alien_id), CURRENT_USER);
    END;

CREATE TRIGGER logga_raderingar_alien
    BEFORE DELETE
    ON Alien
    FOR EACH ROW
    BEGIN
        INSERT INTO Trigger_Logg (trigger_typ, data, användare)
            VALUES ('RADERING', CONCAT('Alien: ', OLD.alien_id), CURRENT_USER);
    END;

CREATE TABLE Skepp(
    skepp_id    INT,
    sittplatser INT,
    tillverkningsplanet VARCHAR(30),
    tillverkat  DATE,
    PRIMARY KEY (skepp_id)
);

CREATE TRIGGER chk_skepp
BEFORE INSERT
ON Skepp
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

CREATE TABLE Skepp_Alien_Relation(
    skepp_id    INT,
    alien_id    CHAR(25),
    PRIMARY KEY (skepp_id, alien_id),
    FOREIGN KEY (skepp_id) REFERENCES Skepp(skepp_id),
    FOREIGN KEY (alien_id) REFERENCES Alien(alien_id)
);

CREATE TABLE Kännetecken_Tillhör_Ras(
    alien_id    CHAR(25),
    ras_namn    VARCHAR(30),
    kännetecken VARCHAR(32),
    PRIMARY KEY (alien_id, ras_namn, kännetecken),
    FOREIGN KEY (alien_id, ras_namn) REFERENCES Alien (alien_id, ras_namn),
    FOREIGN KEY (kännetecken) REFERENCES Kännetecken(attribut)
);

CREATE TABLE Kännetecken_Tillhör_Alien (
    alien_id    CHAR(25),
    kännetecken VARCHAR(32),
    PRIMARY KEY (alien_id, kännetecken),
    FOREIGN KEY (alien_id) REFERENCES Alien (alien_id),
    FOREIGN KEY (kännetecken) REFERENCES Kännetecken(attribut)
);

CREATE TABLE Kännetecken_Tillhör_Skepp (
    skepp_id    INT,
    kännetecken VARCHAR(30),
    PRIMARY KEY (skepp_id, kännetecken),
    FOREIGN KEY (skepp_id) REFERENCES Skepp (skepp_id),
    FOREIGN KEY (kännetecken) REFERENCES Kännetecken (attribut)
);

CREATE TABLE Vapen(
    vapen_id    INT,
    tillverkat  DATE,
    farlighet   TINYINT UNSIGNED DEFAULT 4,
    alien_id    CHAR(25),
    skepp_id    INT,
    PRIMARY KEY (vapen_id),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (farlighet_id),
    CONSTRAINT FOREIGN KEY (skepp_id) REFERENCES Skepp (skepp_id),
    CONSTRAINT FOREIGN KEY (alien_id) REFERENCES Alien (alien_id),

    -- CHECK som kollar att så att ett fält är tomt.
    CONSTRAINT chk_vapen_null
    CHECK ( alien_id IS NULL OR skepp_id IS NULL ),

    -- CHECK som kollar att ett fält INTE är tomt.
    CONSTRAINT chk_vapen_not_null
    CHECK ( alien_id IS NOT NULL OR skepp_id IS NOT NULL )
);

CREATE TABLE Vapen_Ägare(
    vapen_id    INT,
    alien_id    CHAR(25),
    skepp_id    INT,
    PRIMARY KEY (vapen_id),
    CONSTRAINT FOREIGN KEY (skepp_id) REFERENCES Skepp (skepp_id),
    CONSTRAINT FOREIGN KEY (alien_id) REFERENCES Alien (alien_id),

    -- CHECK som kollar att så att ett fält är tomt.
    CONSTRAINT chk_vapen_ägare_null
    CHECK ( alien_id IS NULL OR skepp_id IS NULL ),

    -- CHECK som kollar att ett fält INTE är tomt.
    CONSTRAINT chk_vapen_ägare_not_null
    CHECK ( alien_id IS NOT NULL OR skepp_id IS NOT NULL )
);

CREATE TABLE Vapen_Inköpsplatser(
    vapen_id  INT,
    inköpsplats VARCHAR(30),
    PRIMARY KEY (vapen_id, inköpsplats),
    FOREIGN KEY (vapen_id) REFERENCES Vapen(vapen_id)
);

CREATE TABLE Procedure_Begränsning (
    användare       VARCHAR(50),
    procedure_namn  VARCHAR(50),
    användningar  TINYINT UNSIGNED NULL DEFAULT 0,
    begränsning     TINYINT UNSIGNED DEFAULT 3,
    PRIMARY KEY (användare, procedure_namn)
);

-- Räknar samtliga rader i Vapen OCH relationstabellen Skepp_Alien som en given alien_id förekommer.
-- Returnerar antalet rader i tabellerna med koppling till given alien_id.
CREATE FUNCTION count_kopplingar(alien_id VARCHAR(25)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count INT;
    SELECT COUNT(*) INTO count
    FROM Skepp_Alien_Relation
    JOIN Vapen ON Skepp_Alien_Relation.alien_id = Vapen.alien_id
    WHERE Skepp_Alien_Relation.alien_id = alien_id;
    RETURN count;
END;

-- Säkerställer så att Alien inte kan har 15 eller fler kopplingar innan addering av ny rad.
CREATE TRIGGER chk_kopplingar_skepp
BEFORE INSERT
ON Skepp_Alien_Relation
FOR EACH ROW
BEGIN
    DECLARE kopplingar INT;
    SET kopplingar = count_kopplingar(NEW.alien_id);
    IF kopplingar >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alien har redan 15 kopplingar till vapen och/eller rymdkskepp.';
    END IF;
END;

-- Samma som föregående --
CREATE TRIGGER chk_kopplingar_vapen
BEFORE INSERT
ON Vapen
FOR EACH ROW
BEGIN
    DECLARE kopplingar INT;
    SET kopplingar = count_kopplingar(NEW.alien_id);
    IF kopplingar >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alien har redan 15 kopplingar till vapen och/eller rymdkskepp.';
    END IF;
END;

CREATE TRIGGER uppdatera_Vapen_Ägare
    AFTER INSERT
    ON Vapen
    FOR EACH ROW
    BEGIN
        INSERT INTO Vapen_Ägare (vapen_id, alien_id, skepp_id) VALUES (NEW.vapen_id, NEW.alien_id, NEW.skepp_id);
    END;

CREATE TRIGGER radering_Vapen_Ägare
    AFTER DELETE
    ON Vapen
    FOR EACH ROW
    BEGIN
        DELETE FROM Vapen_Ägare WHERE Vapen_ägare.vapen_id = OLD.vapen_id;
    END;

CREATE TRIGGER logga_uppdatering_vapen
    AFTER UPDATE
    ON Vapen
    FOR EACH ROW
    BEGIN
        INSERT INTO Trigger_Logg (trigger_typ, data, användare)
            VALUES ('UPPDATERING', CONCAT('Vapen: ', OLD.vapen_id), CURRENT_USER);

        UPDATE Vapen_Ägare
        SET Vapen_Ägare.skepp_id = NEW.skepp_id,
            Vapen_Ägare.alien_id = NEW.alien_id
        WHERE Vapen_Ägare.vapen_id = NEW.vapen_id;
    END;


-- Hemligstämplar alla aliens rasfält som har param_ras_namn samt rasen självt.
CREATE PROCEDURE hemligstämpla_på_ras_namn(IN param_ras_namn SMALLINT)
    BEGIN
        -- Loggför aliens med rasen som hemligstämplas. --
        INSERT INTO Hemligstämplat_Logg(alien_id, ras_namn)
        SELECT alien_id, ras_namn FROM Alien
        WHERE ras_namn = param_ras_namn;

        -- Sparar information om rasen för återskapande senare.
        UPDATE Hemligstämplat_Logg, Kännetecken_Tillhör_Ras
        SET ras_kännetecken = kännetecken
        WHERE ras_namn = param_ras_namn;

        -- Uppdaterar rasen på aliens med param_ras_namn till 'HEMLIGSTÄMPLAT'.
        UPDATE
            Alien
        SET
            ras_namn = 'Hemligstämplat'
        WHERE
            ras_namn = param_ras_namn;
    END;

-- Avklassificerar både ras och alien med ras_namn.
CREATE PROCEDURE avklassificera(IN param_ras_namn SMALLINT)
    BEGIN
        -- Återskapar eventuella kännetecken för rasen.
        INSERT IGNORE INTO Kännetecken_Tillhör_Ras (ras_namn, kännetecken)
        SELECT ras_namn, ras_kännetecken FROM Hemligstämplat_Logg
        WHERE Hemligstämplat_Logg.ras_namn = param_ras_namn;

        -- Återger rasen till alla Aliens med samma ras innan hemligstämplande.
        UPDATE
            Alien,
            Hemligstämplat_Logg
        SET
            Alien.ras_namn = param_ras_namn
        WHERE
            Alien.alien_id = Hemligstämplat_Logg.alien_id
            AND Hemligstämplat_Logg.ras_namn = param_ras_namn;

    END;

-- Avklassificerar en specifik Alien.
CREATE PROCEDURE avklassificera_alien(IN param_alien_id CHAR(25))
    BEGIN
        DECLARE matchning TINYINT;

        -- Kontrollerar att alien_id är hemligstämplat till att börja med.
        SELECT COUNT(*) INTO matchning
        FROM Hemligstämplat_Logg
        WHERE alien_id = param_alien_id;

        -- matchning bör vara antingen 0 ELLER 1, då alien_iden är unik.
        -- resultatet = 0 : alien INTE hemlig.
        -- resultatet = 1 : alien är hemlig.
        IF matchning = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ALIEN_ID existerar inte eller är EJ HEMLIGSTÄMPLAT.';

        ELSE
            UPDATE
                Alien,
                Hemligstämplat_Logg
            SET
                Alien.ras_namn = Hemligstämplat_Logg.ras_namn
            WHERE
                Alien.alien_id = Hemligstämplat_Logg.alien_id
                AND Hemligstämplat_Logg.alien_id = param_alien_id;
        END IF;
    END;

CREATE PROCEDURE radering_kopplingar_alien(IN param_alien_id CHAR(25))
    BEGIN
        -- Raderar alla tillhörande kopplingar, raderingen loggas INTE.
        START TRANSACTION;

        DELETE FROM Hemligstämplat_Logg WHERE alien_id = param_alien_id;

        DELETE FROM Kännetecken_Tillhör_Alien WHERE alien_id = param_alien_id;

        DELETE FROM Vapen WHERE alien_id = param_alien_id;

        DELETE FROM Vapen_Ägare WHERE alien_id = param_alien_id;

        DELETE FROM Skepp_Alien_Relation WHERE alien_id = param_alien_id;

        DELETE FROM Oregistrerad_Alien WHERE alien_id = param_alien_id;
        DELETE FROM Registrerad_Alien WHERE alien_id = param_alien_id;

        DELETE FROM Alien_Relation
               WHERE alien_idA = param_alien_id
                  OR alien_idB = param_alien_id;

        -- Raderar den faktiska alien vars alien_id man har fyllt i.
        DELETE FROM Alien WHERE alien_id = param_alien_id;

        COMMIT;
    END;

CREATE PROCEDURE radera_alien(IN param_alien_id CHAR(25))
BEGIN
    DECLARE användningar TINYINT;
    DECLARE stopp TINYINT;

    SET @nuvarande_användare = CURRENT_USER();

    -- CHECK raderingar --
    SELECT användningar
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
        SET användningar = användningar + 1
        WHERE användare = @nuvarande_användare
        AND procedure_namn = 'radera_alien';

        CALL radering_kopplingar_alien(param_alien_id);

    END IF;
END;

CREATE PROCEDURE radering_kopplingar_skepp(IN rymdskepp_id INT)
    BEGIN
        -- Raderar alla tillhörande kopplingar, raderingen loggas INTE.
            START TRANSACTION;

            DELETE FROM Kännetecken_Tillhör_Skepp WHERE skepp_id = rymdskepp_id;

            DELETE FROM Vapen WHERE skepp_id = rymdskepp_id;

            DELETE FROM Vapen_Ägare WHERE skepp_id = rymdskepp_id;

            DELETE FROM Skepp_Alien_Relation WHERE skepp_id = rymdskepp_id;

            -- Raderar det faktiska skeppet vars id man har fyllt i.
            DELETE FROM Skepp WHERE skepp_id = rymdskepp_id;

            COMMIT;
    END;

CREATE PROCEDURE radera_skepp (IN param_rymdskepp_id INT)
    BEGIN
        DECLARE användningar TINYINT;
        DECLARE stopp TINYINT;

        SET @nuvarande_användare = CURRENT_USER();

        -- CHECK raderingar --
        SELECT användningar
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
            SET användningar = användningar + 1
            WHERE användare = @nuvarande_användare
            AND procedure_namn = 'radera_aien';

            CALL radering_kopplingar_skepp(param_rymdskepp_id);
        END IF;
    END;

CREATE PROCEDURE nollställ_begränsning (IN agent VARCHAR(50), IN kommando VARCHAR(50))
    BEGIN
        UPDATE Procedure_Begränsning
        SET användningar = 0
        WHERE användare = agent
        AND procedure_namn = kommando;
    END;

CREATE PROCEDURE nollställ_alla_maxade (OUT resultat TEXT)
    BEGIN
        -- Hämtar alla som har nått sin maxgräns och sätter in i 'resultat'.
        SELECT GROUP_CONCAT(användare SEPARATOR ', ') INTO resultat
        FROM Procedure_Begränsning
        WHERE användningar >= begränsning;

            -- Det är samma personer som i resultat som kommer att få sina användningar nollställt.
            UPDATE Procedure_Begränsning
            SET användningar = 0
            WHERE användningar >= begränsning;
    END;

CREATE PROCEDURE ändra_begränsning (IN agent VARCHAR(50), IN kommando VARCHAR(50), IN gräns TINYINT)
    BEGIN
        UPDATE Procedure_Begränsning
        SET begränsning = gräns
        WHERE användare = agent
        AND procedure_namn = kommando;
    END;

-- Förenklad vy för att kunna få en överblick över alla 'personnummer' på registrerade aliens,
-- samt införelsedatum i databasen (som även dessa kommer stå under 'personnummer') för oregistrerade aliens,
-- dvs en överblick över alla registrerade och oregistrerade aliens i en tabell.
-- Här ser man även snabbt vilka aliens som är registrerade då de har en kortare personnummer,
-- medan de oregistrerade aliens har ett längre "personnummer".
CREATE VIEW Alien_Personnummer_view AS
SELECT alien_id, namn, pnr AS 'Personnummer', hemplanet
FROM Registrerad_Alien
UNION
SELECT alien_id, namn, införelsedatum AS 'Personnummer', NULL as 'hemplanet'
FROM Oregistrerad_Alien;

-- Här kan man se en vy över alla aliens och skepp som har kännetecken i en och samma tabell.
CREATE VIEW Kännetecken_Entitet_view AS
SELECT alien_id AS 'ID', kännetecken AS 'Kännetecken'
FROM Kännetecken_Tillhör_Alien
UNION
SELECT skepp_id AS 'ID', kännetecken AS 'Kännetecken'
FROM Kännetecken_Tillhör_Skepp ORDER BY ID;

-- Här kan en användare med lägre auktorisation se en vy över aliens som inte är hemligstämplade.
-- Det kan vara så att enbart agenter med högre auktoritet som får se aliens med hemligstämplade raser.
-- I annat fall kan det även vara bra för att se vilka aliens som inte är hemligstämplade ännu...
CREATE VIEW Offentliga_Raser_view AS
SELECT alien_id, ras_namn
FROM Alien
WHERE ras_namn <> 'HEMLIGSTÄMPLAT' OR ras_namn IS NULL
GROUP BY ras_namn;

CREATE VIEW Hemliga_Aliens_view AS
SELECT alien_id, ras_namn
FROM Alien
WHERE ras_namn = 'HEMLIGSTÄMPLAT'
GROUP BY ras_namn;

-- Här kan man se vilka agenter som har nått sina begränsningar på procedurer.
CREATE VIEW Nått_Begränsning_view AS
SELECT användare AS 'USER', användningar AS 'ANVÄNDNINGAR', begränsning 'GRÄNS', procedure_namn
FROM Procedure_Begränsning
WHERE användningar = begränsning
ORDER BY användare;

-- Här kan man se agenternas medelvärde på användningarna av procedurer.
CREATE VIEW AVG_Användning_view AS
SELECT procedure_namn, AVG(användningar)
FROM Procedure_Begränsning
GROUP BY procedure_namn;

-- Skapar olika USERS för databasen med specifika rättigheter beroende på USER typ.
CREATE USER IF NOT EXISTS 'a21liltr_agent'@'%' IDENTIFIED BY 'foo';
CREATE USER IF NOT EXISTS 'a21liltr_administratör'@'%' IDENTIFIED BY 'bar';

INSERT INTO användare (användarnamn, lösenord, roll) VALUES ('agent', 'foo', 'agent'),
                                                         ('administratör', 'bar', 'administratör');

-- Rättigheter till en "vanlig" agent.
GRANT EXECUTE ON PROCEDURE a21liltr.radera_alien TO 'a21liltr_agent'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.radera_skepp TO 'a21liltr_agent'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.avklassificera TO 'a21liltr_agent'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.avklassificera_alien TO 'a21liltr_agent'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.hemligstämpla_på_ras_namn TO 'a21liltr_agent'@'%';
GRANT SELECT ON a21liltr.Alien_Personnummer_view TO 'a21liltr_agent'@'%';
GRANT SELECT ON a21liltr.Offentliga_Raser_view TO 'a21liltr_agent'@'%';
GRANT SELECT ON a21liltr.Hemliga_Aliens_view TO 'a21liltr_agent'@'%';
GRANT SELECT ON a21liltr.Kännetecken_Entitet_view TO 'a21liltr_agent'@'%';


-- Rättigheter till en agent (administratör) med högre auktoritet.
GRANT EXECUTE ON PROCEDURE a21liltr.radera_alien TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.radera_skepp TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.avklassificera TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.avklassificera_alien TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.hemligstämpla_på_ras_namn TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.nollställ_begränsning TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.nollställ_alla_maxade TO 'a21liltr_administratör'@'%';
GRANT EXECUTE ON PROCEDURE a21liltr.ändra_begränsning TO 'a21liltr_administratör'@'%';
GRANT SELECT ON a21liltr.Alien_Personnummer_view TO 'a21liltr_administratör'@'%';
GRANT SELECT ON a21liltr.Offentliga_Raser_view TO 'a21liltr_administratör'@'%';
GRANT SELECT ON a21liltr.Hemliga_Aliens_view TO 'a21liltr_administratör'@'%';
GRANT SELECT ON a21liltr.Kännetecken_Entitet_view TO 'a21liltr_administratör'@'%';
GRANT SELECT ON a21liltr.Nått_Begränsning_view TO 'a21liltr_administratör'@'%';
GRANT SELECT ON a21liltr.AVG_Användning_view TO 'a21liltr_administratör'@'%';

-- Laddar om så att användarna får sina rättigheter.
FLUSH PRIVILEGES;