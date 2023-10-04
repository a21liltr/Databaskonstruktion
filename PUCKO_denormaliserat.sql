DROP DATABASE a21liltr;
CREATE DATABASE IF NOT EXISTS a21liltr;
USE a21liltr;

CREATE TABLE Farlighet(
    grad        VARCHAR(16),
    id          TINYINT UNSIGNED UNIQUE,
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
    namn        VARCHAR(30),
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
    VALUES ('Hemligstämplat', 'Hemligt');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES ('Tax', 'Liten');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES ('Tax', 'Söt');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES ('Chihuahua', 'Liten');
INSERT INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
    VALUES ('Chihuahua', 'Aggressiv');

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
    farlighet   TINYINT DEFAULT 4,
    rasID         SMALLINT,
    PRIMARY KEY (IDkod),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id),
    FOREIGN KEY (rasID) REFERENCES Ras (rasID)
);

CREATE TABLE Oregistrerad_Alien(
    namn        VARCHAR (30),
    IDkod       CHAR(25),
    införelsedatum CHAR(15) DEFAULT CONCAT(
                    DATE_FORMAT(NOW(), '%Y%m%d-'),
                    DATE_FORMAT(NOW(), '%H%i%s')),
    PRIMARY KEY (IDkod),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_pnr_format
    CHECK ( regexp_like(införelsedatum, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TABLE Registrerad_Alien(
    namn        VARCHAR(30),
    IDkod       CHAR(25),
    pnr         CHAR(13) DEFAULT CONCAT(
                    DATE_FORMAT(NOW(), '%Y%m%d'),               -- dagens datum i formatet YYYYmmDD --
                    '-',                                        -- ett bindesstreck för att separera datumet från de sista 4 siffrorna --
                    LPAD(CAST((SELECT MAX(RIGHT(pnr, 4) + 1)    -- 4 siffror som ökar för varje rad insert --
                               FROM Registrerad_Alien) AS UNSIGNED), 4, '0')),
    hemplanet   VARCHAR(30) NOT NULL,
    PRIMARY KEY (IDkod, pnr),
    FOREIGN KEY (IDkod) REFERENCES Alien (IDkod),

    CONSTRAINT chk_pnr_format
    CHECK ( regexp_like(pnr, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TABLE RegAlien_OregAlien_Relation(
    registrerad_IDkod   CHAR(25),
    oregistrerad_IDkod  CHAR(25),
    relation    VARCHAR(30) NOT NULL,
    PRIMARY KEY (registrerad_IDkod, oregistrerad_IDkod),
    FOREIGN KEY (registrerad_IDkod) REFERENCES Registrerad_Alien(IDkod),
    FOREIGN KEY (oregistrerad_IDkod) REFERENCES Oregistrerad_Alien(IDkod)
);

CREATE TABLE RegAlien_RegAlien_Relation(
    registrerad_IDkod_1   CHAR(25),
    registrerad_IDkod_2  CHAR(25),
    relation    VARCHAR(30) NOT NULL,
    PRIMARY KEY (registrerad_IDkod_1, registrerad_IDkod_2),
    FOREIGN KEY (registrerad_IDkod_1) REFERENCES Registrerad_Alien(IDkod),
    FOREIGN KEY (registrerad_IDkod_2) REFERENCES Registrerad_Alien(IDkod)
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
    tillverkningsplanet VARCHAR(30),
    sittplatser INT ,
    tillverkat  DATE,
    PRIMARY KEY (id)
);

CREATE TRIGGER check_int_value
BEFORE INSERT ON Skepp
FOR EACH ROW
BEGIN
    IF NEW.sittplatser < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SITTPLATSER must be at least 1.';
    END IF;
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
    farlighet   TINYINT DEFAULT 4,
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

-- Hemligstämplar alla aliens rasfält samt rasen självt på rasID. --
CREATE PROCEDURE Hemligstämpla_ras_med_id(IN param_rasID SMALLINT)
    BEGIN
        DECLARE existerar SMALLINT;

        -- Kollar om 'Hemligstämplat redan existerar. --
        SELECT COUNT(*) INTO existerar
        FROM Ras
        WHERE namn = 'Hemlighetsstämplat';

        IF existerar = 0 THEN
            -- Skapar 'Hemligstämplat' om den inte redan finns. --
            INSERT INTO Ras (namn)
            VALUES ('Hemlighetsstämplat');
        END IF;

        -- Loggför aliens med rasen som hemligstämplas. --
        INSERT INTO Alien_Hemligstämplade_Logg(IDkod, rasID)
        SELECT IDkod, rasID FROM Alien
        WHERE rasID = param_rasID;

        -- Sparar information om rasen för återskapande senare. --
        INSERT INTO Ras_Logg(rasID, kännetecken)
        SELECT rasID, kännetecken FROM Kännetecken_Tillhör_Ras
        WHERE rasID = param_rasID;

        -- Uppdaterar aliens med rasen till 'Hemligstämplat'. --
        UPDATE
            Alien,
            Ras
        SET
            Alien.rasID = Ras.rasID
        WHERE Ras.rasID = param_rasID;

        DELETE FROM Ras WHERE rasID = param_rasID;
    END;

CREATE PROCEDURE Avklassificera(IN param_rasID SMALLINT)
    BEGIN
        -- Insertar så länge rasen inte redan finns med --
        INSERT IGNORE INTO Ras (rasID, namn)
        SELECT rasID, namn FROM Ras_Logg
        WHERE Ras_Logg.rasID = param_rasID;

        -- Återskapar eventuella kännetecken för rasen --
        INSERT IGNORE INTO Kännetecken_Tillhör_Ras (rasID, kännetecken)
        SELECT rasID, kännetecken FROM Ras_Logg
        WHERE rasID = param_rasID;

        -- Återger alla aliens som hade rasen innan hemligstämplande --
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
CREATE PROCEDURE Avklassificera_Alien(IN param_alien_idkod CHAR(25))
    BEGIN
        DECLARE matchning TINYINT;

        -- CHECK så att idkoden är hemligstämplat till att börja med. --
        SELECT COUNT(*) INTO matchning
        FROM Alien_Hemligstämplade_Logg
        WHERE IDkod = param_alien_idkod;

        -- matchning bör vara antingen 0 ELLER 1, då IDkoden är unik.
        IF matchning = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The IDkod of this Alien does not exist or is NOT Hemligstämplat.';

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

CREATE PROCEDURE Radera_Alien(IN param_idkod CHAR(25))
BEGIN
    -- Raderar alla tillhörande kopplingar, raderingen loggas INTE. --
    START TRANSACTION;

    DELETE FROM Alien_Hemligstämplade_Logg WHERE IDkod = param_idkod;

    DELETE FROM Kännetecken_Tillhör_Alien WHERE IDkod = param_idkod;

    DELETE FROM Vapen WHERE alien_idkod = param_idkod;

    DELETE FROM Skepp_Alien WHERE alien_idkod = param_idkod;

    DELETE FROM Oregistrerad_Alien WHERE IDkod = param_idkod;
    DELETE FROM Registrerad_Alien WHERE IDkod = param_idkod;

    DELETE FROM RegAlien_OregAlien_Relation
           WHERE RegAlien_OregAlien_Relation.registrerad_idkod = param_idkod
              OR RegAlien_OregAlien_Relation.oregistrerad_idkod = param_idkod;

    -- Raderar den faktiska alien vars IDkod man har fyllt i. --
    DELETE FROM Alien WHERE IDkod = param_idkod;

    COMMIT;
END;

CREATE TABLE Användare(
    användar_id SMALLINT NOT NULL AUTO_INCREMENT,
    borttagningar_alien TINYINT NOT NULL DEFAULT 0,
    borttagningar_skepp TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (användar_id)
);

CALL Hemligstämpla_ras_med_id(2);

SELECT * FROM Ras;
SELECT * FROM Alien;

INSERT INTO Alien (IDkod, farlighet, rasID) VALUES (111112222233333444445555, 2, 3);
INSERT INTO Alien (IDkod, farlighet, rasID) VALUES (666662222233333444445555, 6, 1);
INSERT INTO Alien (IDkod, rasID) VALUES (777772222233333444445555, 2);

INSERT INTO Ras (rasID, namn) VALUES (2, 'Chihuahua');

SELECT * FROM Alien;







