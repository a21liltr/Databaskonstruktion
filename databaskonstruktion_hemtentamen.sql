CREATE TABLE material (
    id          INT PRIMARY KEY,
    material    VARCHAR(50),
    komponent   VARCHAR(50)
);

CREATE TABLE hus (
    adress      VARCHAR(50),
    plats       VARCHAR(50),
    kategori    VARCHAR(50),
    längd       INT,
    bredd       INT,
    materialid  INT,
    kostnad     INT,
    FOREIGN KEY (materialid) REFERENCES material(id)
);

CREATE TABLE tillverkare (
    id          INT PRIMARY KEY,
    företag     VARCHAR(50)
);

CREATE TABLE takmaterial (
    idnr        INT PRIMARY KEY,
    namn        VARCHAR(50),
    tyngd       INT,
    tillverkare INT,
    material    INT,
    FOREIGN KEY (material) REFERENCES material (id),
    FOREIGN KEY (tillverkare) REFERENCES tillverkare (id)
);

CREATE TABLE logg_ny_takmaterial (
    idnr         INT PRIMARY KEY,
    namn         VARCHAR(50),
    tyngd        INT,
    tillverkare  INT,
    material     INT,
    skapad_datum DATE default NOW(),
    kommentar    VARCHAR(255),
    FOREIGN KEY (material) REFERENCES material (id),
    FOREIGN KEY (tillverkare) REFERENCES tillverkare (id)
);

CREATE PROCEDURE logga_ny_takmaterial(IN namn_param VARCHAR(50),
                                     IN tyngd_param INT,
                                     IN tillverkare_param INT,
                                     IN material_param INT,
                                     IN skapad_datum_param DATE,
                                     IN kommentar_param VARCHAR(255))
BEGIN
    DECLARE material_id INT;
    DECLARE tillverkare_id INT;

    -- Insert new 'material' entry if not already present
    INSERT IGNORE INTO material (material, komponent) VALUES ('Default Material', 'Default Komponent');
    SET material_id = LAST_INSERT_ID();

    -- Insert new 'tillverkare' entry if not already present
    INSERT IGNORE INTO tillverkare (företag) VALUES ('Default Företag');
    SET tillverkare_id = LAST_INSERT_ID();

    -- Insert new 'takmaterial' entry
    INSERT INTO logg_ny_takmaterial (namn, tyngd, tillverkare, material, skapad_datum, kommentar)
    VALUES (namn_param, tyngd_param, tillverkare_param, material_param, skapad_datum_param, kommentar_param);
    SELECT 'New takmaterial logged successfully!' AS Message;
END;