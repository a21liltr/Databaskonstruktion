DROP DATABASE a21liltr;
CREATE DATABASE IF NOT EXISTS a21liltr;
USE a21liltr;

CREATE TABLE Kännetecken(
    attribut    VARCHAR(255),
    kategori    TINYINT(1),
    PRIMARY KEY (attribut)
);

INSERT INTO Kännetecken(attribut, kategori)VALUES ('Hemlighetsstämplat', 1);

CREATE TABLE Farlighet(
    grad        VARCHAR(16),
    id          TINYINT UNIQUE,
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

CREATE TABLE Ras(
    namn        VARCHAR (30),
    kännetecken VARCHAR(255) NOT NULL,
    PRIMARY KEY (namn),
    FOREIGN KEY (kännetecken) REFERENCES Kännetecken (attribut)
);

CREATE TABLE Ras_Logg(
    id  SMALLINT NOT NULL AUTO_INCREMENT,
    logg_tid   DATETIME NOT NULL DEFAULT NOW(),
    namn       VARCHAR(30) NOT NULL,
    kännetecken VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO Ras(namn, kännetecken)
VALUES ('Gröngöling', 'Hemlighetsstämplat');

CREATE TABLE Alien(
    idkod       CHAR(25),
    farlighet   TINYINT DEFAULT 4,
    ras         VARCHAR(30),
    PRIMARY KEY (idkod),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id),
    FOREIGN KEY (ras) REFERENCES Ras (namn)
);

INSERT INTO Alien (idkod, ras)
VALUES (123456789012345,'Gröngöling');

CREATE TABLE Kännetecken_Tillhör_Alien (
    idkod       VARCHAR(25),
    namn        VARCHAR(30),
    attribut    VARCHAR(255) NOT NULL,
    PRIMARY KEY (idkod, attribut),
    FOREIGN KEY (idkod) REFERENCES Alien (idkod)
);

CREATE TABLE Skepp(
    id          INT,
    tillverkningsplanet VARCHAR(30),
    sittplatser INT,
    tillverkat  DATE,
    PRIMARY KEY (id)
);

CREATE TABLE Kännetecken_Tillhör_Skepp (
    id          INT NOT NULL,
    attribut    VARCHAR(255) NOT NULL,
    PRIMARY KEY (attribut),
    FOREIGN KEY (id) REFERENCES Skepp (id)
);

CREATE TABLE Oregistrerad_Alien(
    namn        VARCHAR(30) NOT NULL,
    idkod       CHAR(25) NOT NULL,
    databaskod  CHAR(14) NOT NULL,
    PRIMARY KEY (databaskod),
    FOREIGN KEY (idkod) REFERENCES Alien (idkod),
    CONSTRAINT chk_databaskod_format CHECK ( regexp_like(databaskod, '^[0-9]{8}-[0-9]{6}$') )
);

CREATE TABLE Registrerad_Alien(
    namn        VARCHAR(30) NOT NULL,
    pnr         CHAR(12) NOT NULL,
    idkod       CHAR(25) NOT NULL,
    databaskod  CHAR(14) NOT NULL,
    hemplanet   VARCHAR(30) NOT NULL,
    ras         VARCHAR(30) NOT NULL,
    PRIMARY KEY (pnr),
    FOREIGN KEY (idkod) REFERENCES Alien (idkod),
    FOREIGN KEY (databaskod) REFERENCES Oregistrerad_Alien(databaskod),
    FOREIGN KEY (ras) REFERENCES Ras(namn),
    CONSTRAINT chk_pnr_format CHECK ( regexp_like(pnr, '^[0-9]{8}-[0-9]{4}$') )
);

CREATE TABLE RegAlien_OregAlien_Relation(
    pnr         CHAR(12),
    databaskod  CHAR(14),
    relation    VARCHAR(30) NOT NULL,
    PRIMARY KEY (pnr),
    FOREIGN KEY (pnr) REFERENCES Registrerad_Alien(pnr),
    FOREIGN KEY (databaskod) REFERENCES Oregistrerad_Alien(databaskod)
);

CREATE TABLE Skepp_Alien(
    skepp_id    INT,
    alien_idkod VARCHAR(25),
    PRIMARY KEY (skepp_id, alien_idkod),
    FOREIGN KEY (skepp_id) REFERENCES Skepp(id),
    FOREIGN KEY (alien_idkod) REFERENCES Alien(idkod)
);

CREATE TABLE Vapen(
    idnr        INT,
    tillverkat  DATE,
    farlighet   TINYINT DEFAULT 4,
    PRIMARY KEY (idnr),
    FOREIGN KEY (farlighet) REFERENCES Farlighet (id)
);

CREATE TABLE Vapen_Tillhör(
    vapen_idnr   INT,
    alien_idkod  VARCHAR(25),
    skepp_id     INT,
    PRIMARY KEY (vapen_idnr),
    CONSTRAINT FOREIGN KEY (skepp_id) REFERENCES Skepp (id),
    CONSTRAINT FOREIGN KEY (alien_idkod) REFERENCES Alien (idkod),
    CONSTRAINT chk_vapen_alienid_skeppid CHECK ( alien_idkod IS NULL OR skepp_id IS NULL ),
    CONSTRAINT chk_vapen_har_alienid_skeppid CHECK ( alien_idkod IS NOT NULL OR skepp_id IS NOT NULL )
);

CREATE PROCEDURE Hemlighetsstämpla_ras(IN param_rasnamn VARCHAR(30))
    BEGIN
        INSERT INTO Ras_Logg(namn, kännetecken)
        SELECT * FROM Ras
        WHERE namn = param_rasnamn;

        UPDATE Alien
        SET
            ras = 'Hemlighetsstämplat'
        WHERE
            ras = param_rasnamn;

        DELETE FROM Ras
        WHERE namn = param_rasnamn;

        INSERT IGNORE INTO Ras (namn, kännetecken)
        VALUES ('Hemlighetsstämplat', 'Hemplighetsstämplat');
    END;




