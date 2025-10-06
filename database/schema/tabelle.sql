-- adresse
CREATE TABLE adresse (
    adresse_id SERIAL PRIMARY KEY,  
    strasse VARCHAR(100) NOT NULL,  
    haus_nr VARCHAR(10) NOT NULL,   
    plz VARCHAR(10) NOT NULL,      
    ort VARCHAR(100) NOT NULL,   
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- kunde
CREATE TABLE kunde (
    kunde_id SERIAL PRIMARY KEY,
    vorname VARCHAR(100) NOT NULL,
    nachname VARCHAR(100) NOT NULL,
    rechnung_adresse_id INT NOT NULL,
    liefer_adresse_id INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kunde_rechnung_adresse FOREIGN KEY (rechnung_adresse_id)
        REFERENCES adresse(adresse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_kunde_liefer_adresse FOREIGN KEY (liefer_adresse_id)
        REFERENCES adresse(adresse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- bestellung
CREATE TABLE bestellung (
    bestellung_id SERIAL PRIMARY KEY,
    kunde_id INT NOT NULL,
    adresse_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    datum DATE NOT NULL DEFAULT CURRENT_DATE,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bestellung_kunde FOREIGN KEY (kunde_id)
        REFERENCES kunde(kunde_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_bestellung_adresse FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- rechnung
CREATE TABLE rechnung (
    rechnung_id SERIAL PRIMARY KEY,
    kunde_id INT NOT NULL,
    adresse_id INT NOT NULL,
	datum DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) NOT NULL,
	rabatt_prozent NUMERIC(5,2) DEFAULT 0,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rechnung_kunde FOREIGN KEY (kunde_id)
        REFERENCES kunde(kunde_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_rechnung_adresse FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

--artikel
CREATE TABLE artikel (
    artikel_id SERIAL PRIMARY KEY,
    bezeichnung VARCHAR(200) NOT NULL,
    einzelpreis NUMERIC(10,2) NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- rechnung_position
CREATE TABLE rechnung_position (
    rechnung_id INT NOT NULL,
    position_nr INT NOT NULL,
    artikel_id INT NOT NULL,
    menge INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_rechnung_position PRIMARY KEY (rechnung_id, position_nr),
    CONSTRAINT fk_rechnung_position_rechnung FOREIGN KEY (rechnung_id)
        REFERENCES rechnung(rechnung_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_rechnung_position_artikel FOREIGN KEY (artikel_id)
        REFERENCES artikel(artikel_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- lagerort
CREATE TABLE lagerort (
    lagerort_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    adresse_id INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lagerort_adresse FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- lagerbestand
CREATE TABLE lagerbestand (
    artikel_id INT NOT NULL,
    lagerort_id INT NOT NULL,
    bestand INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_lagerbestand PRIMARY KEY (artikel_id, lagerort_id),
    CONSTRAINT fk_lagerbestand_artikel FOREIGN KEY (artikel_id)
        REFERENCES artikel(artikel_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_lagerbestand_lagerort FOREIGN KEY (lagerort_id)
        REFERENCES lagerort(lagerort_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- bestellung_position
CREATE TABLE bestellung_position (
    bestellung_id INT NOT NULL,
    position_nr INT NOT NULL,
    artikel_id INT NOT NULL,
	menge INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_bestellung_position PRIMARY KEY (bestellung_id, position_nr),
    CONSTRAINT fk_bestellung_position_bestellung FOREIGN KEY (bestellung_id)
        REFERENCES bestellung(bestellung_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_bestellung_position_artikel FOREIGN KEY (artikel_id)
        REFERENCES artikel(artikel_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- warengruppe
CREATE TABLE warengruppe (
    warengruppe_id SERIAL PRIMARY KEY,
    bezeichnung VARCHAR(200) NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- warengruppe_artikel
CREATE TABLE warengruppe_artikel (
    artikel_id INT NOT NULL,
    warengruppe_id INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_warengruppe_artikel PRIMARY KEY (artikel_id, warengruppe_id),
    CONSTRAINT fk_warengruppe_artikel_artikel FOREIGN KEY (artikel_id)
        REFERENCES artikel(artikel_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_warengruppe_artikel_warengruppe FOREIGN KEY (warengruppe_id)
        REFERENCES warengruppe(warengruppe_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- lieferant
CREATE TABLE lieferant (
    lieferant_id SERIAL PRIMARY KEY,
    vorname VARCHAR(100),
    nachname VARCHAR(100),
    firmenname VARCHAR(200) NOT NULL,
    adresse_id INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lieferant_adresse FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- lieferant_artikel
CREATE TABLE lieferant_artikel (
    artikel_id INT NOT NULL,
	lieferant_id INT NOT NULL,
    aenderungsdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_lieferant_artikel PRIMARY KEY (lieferant_id, artikel_id),
	CONSTRAINT fk_lieferant_artikel_artikel FOREIGN KEY (artikel_id)
        REFERENCES artikel(artikel_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_lieferant_artikel_lieferant FOREIGN KEY (lieferant_id)
        REFERENCES lieferant(lieferant_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);