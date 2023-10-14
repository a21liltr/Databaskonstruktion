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
                                          ('Ful');

INSERT INTO Oregistrerad_Alien (IDkod, namn) VALUES (7777, 'Karo'),
                                                    (8888, 'Will'),
                                                    (9999, 'Gunilla');

INSERT INTO Registrerad_Alien (IDkod, namn, hemplanet)
    VALUES (2222, 'Torbjörn', 'MWDXACJA'),
           (3333, 'Bert', 'I2OJNLW9'),
           (4444, 'Märta', 'Jorden');

INSERT INTO Kännetecken_Tillhör_Alien (IDkod, alien_kännetecken, ras_kännetecken)
    VALUES (1111, 'Hemlig', 'Söt'),
           (2222, 'Grön'),
           (3333, 'Stor'),
           (3333, 'Grön'),
           (4444, 'Söt');

INSERT INTO Alien_Relation (IDkodA, IDkodB, relation) VALUES (1111, 4444, 'Gifta'),
                                                             (1111, 2222, 'Syskon'),
                                                             (7777, 3333, 'Kollegor'),
                                                             (7777, 4444, 'Fiender');

INSERT INTO Skepp (id, sittplatser) VALUES (1212, 4),
                                           (5656, 8);

SELECT * FROM Alien;