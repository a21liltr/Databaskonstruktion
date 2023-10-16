USE a21liltr;

INSERT INTO Farlighet(grad)
VALUES ('Harmlös'),
       ('Halvt harmlös'),
       ('Ofarlig'),
       ('Neutral'),
       ('Svagt farlig'),
       ('Farlig'),
       ('Extremt farlig'),
       ('Spring för livet');

INSERT INTO Kännetecken (attribut) VALUES ('Liten'),
                                          ('Grön'),
                                          ('Söt'),
                                          ('Aggressiv'),
                                          ('Hemlig'),
                                          ('Stor'),
                                          ('Ful'),
                                          ('Lång');

INSERT INTO Oregistrerad_Alien (alien_id, namn) VALUES (1111, 'Åsa'),
                                                       (7777, 'Karo'),
                                                       (8888, 'Will'),
                                                       (9999, 'Gunilla');

INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet)
    VALUES (2222, 'Torbjörn', 'MWDXACJA');
INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet)
    VALUES (3333, 'Bert', 'Ixion');
INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet)
    VALUES (4444, 'Märta', 'Mars');
INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet)
    VALUES (1010, 'Duplication', 'Ixion');

SELECT * FROM Alien;
SELECT COUNT(DISTINCT ras_namn) FROM Alien;
SELECT ras_id FROM Alien WHERE ras_namn = 'I2OJNLW9ian' LIMIT 1;
SELECT * FROM Alien;
DELETE FROM Alien WHERE ras_id IS NOT NULL;
DELETE FROM Registrerad_Alien;

DROP trigger addera_registrerad;


INSERT INTO Alien_Relation (alien_idA, alien_idB, relation) VALUES (1111, 4444, 'Gifta'),
                                                             (1111, 2222, 'Syskon'),
                                                             (7777, 3333, 'Kollegor'),
                                                             (7777, 4444, 'Fiender');

INSERT INTO Skepp (skepp_id, sittplatser) VALUES (1212, 4),
                                                 (5656, 8);

INSERT INTO Skepp_Alien_Relation (skepp_id, alien_id) VALUES (1212, 2222);

INSERT INTO Kännetecken_Tillhör_Alien (alien_id, kännetecken)
    VALUES (1111, 'Hemlig'),
           (2222, 'Grön'),
           (3333, 'Stor'),
           (3333, 'Grön'),
           (4444, 'Söt');

INSERT INTO Kännetecken_Tillhör_Skepp (skepp_id, kännetecken) VALUES (5656, 'Stor');

INSERT INTO Vapen (vapen_id, tillverkat, farlighet, alien_id)
VALUES (1, NOW(), 2, 9999);

INSERT INTO Vapen_Ägare (vapen_id, alien_id)
VALUES (1, 9999);

SELECT * FROM Alien_Personnummer_view;



