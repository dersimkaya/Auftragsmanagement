/* 
Vorbereitung mit Basisdaten 
*/

-- Kunden und Adressen
INSERT INTO adresse (strasse, haus_nr, plz, ort, aenderungsdatum)
VALUES ('Teststrasse', '1', '60311', 'Frankfurt', CURRENT_TIMESTAMP);

INSERT INTO kunde (vorname, nachname, rechnung_adresse_id, liefer_adresse_id, aenderungsdatum)
VALUES ('Max', 'Mustermann', 1, 1, CURRENT_TIMESTAMP);

-- Artikel, Warengruppe, Lieferant
INSERT INTO artikel (bezeichnung, einzelpreis, aenderungsdatum)
VALUES ('Widget', 9.99, CURRENT_TIMESTAMP);

INSERT INTO warengruppe (bezeichnung, aenderungsdatum)
VALUES ('Zubehör', CURRENT_TIMESTAMP);

INSERT INTO warengruppe_artikel (artikel_id, warengruppe_id, aenderungsdatum)
VALUES (1, 1, CURRENT_TIMESTAMP);

INSERT INTO lieferant (vorname, nachname, firmenname, adresse_id, aenderungsdatum)
VALUES ('Erika', 'Beispiel', 'Beispiel GmbH', 1001, CURRENT_TIMESTAMP);

INSERT INTO lieferant_artikel (lieferant_id, artikel_id, aenderungsdatum)
VALUES (1, 1, CURRENT_TIMESTAMP);

-- Lagerort und Lagerbestand
INSERT INTO lagerort (lagerort_id, name, adresse_id, aenderungsdatum)
VALUES (1, 'Hauptlager Frankfurt', 1, CURRENT_TIMESTAMP);

INSERT INTO lagerbestand (artikel_id, lagerort_id, bestand, aenderungsdatum)
VALUES (3001, 6001, 50, CURRENT_TIMESTAMP);

-- Bestellung und Rechnung
INSERT INTO bestellung (kunde_id, adresse_id, status, datum, aenderungsdatum)
VALUES (1, 1, 'offen', CURRENT_DATE, CURRENT_TIMESTAMP);

INSERT INTO rechnung (kunde_id, adresse_id, status, datum, aenderungsdatum)
VALUES (1, 1, 'offen', CURRENT_DATE, CURRENT_TIMESTAMP);


/* 
Tests für Constraints 
*/


/* 
Fremdschlüssel testen (Erfolg und Fehler) 
*/

-- Erfolgreiche Positionszeile (FKs existieren)
INSERT INTO bestellung_position(bestellung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (1, 2, 1, 3, CURRENT_TIMESTAMP);


-- Fehler: FK-Verletzung auf bestellung_id
INSERT INTO bestellung_position (bestellung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (7001, 2, 3999, 1, CURRENT_TIMESTAMP);

-- Fehler: rechnung_id existiert nicht
INSERT INTO rechnung_position (rechnung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (8999, 1, 3001, 2, CURRENT_TIMESTAMP);


/* 
Primärschlüssel testen (inkl. zusammengesetzt) 
*/

-- Erfolgreiche erste Position
INSERT INTO rechnung_position (rechnung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (2, 1, 1, 2, CURRENT_TIMESTAMP);

-- Fehler: gleicher zusammengesetzter PK (rechnung_id, position_nr)
INSERT INTO rechnung_position (rechnung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (2, 1, 1, 5, CURRENT_TIMESTAMP);


/* 
NOT NULL testen 
*/

INSERT INTO bestellung (bestellung_id, kunde_id, adresse_id, status, datum, aenderungsdatum)
VALUES (2, 1, 1, NULL, CURRENT_DATE, CURRENT_TIMESTAMP);


/* 
ON DELETE-Regeln testen (CASCADE vs.) 
*/

-- CASCADE: Lösche Rechnung, verknüpfte Positionen sollten mitgelöscht werden
INSERT INTO rechnung_position (rechnung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (2, 2, 1, 1, CURRENT_TIMESTAMP);

DELETE FROM rechnung WHERE rechnung_id = 2;

-- Prüfen: keine Positionen zur gelöschten Rechnung vorhanden
-- (SELECT sollte 0 Zeilen liefern)
SELECT COUNT(*) AS anzahl_pos
FROM rechnung_position
WHERE rechnung_id = 2;

-- RESTRICT: Löschen eines Artikels, der referenziert wird, sollte fehlschlagen
DELETE FROM artikel WHERE artikel_id = 1;


/*
Sinnvolle CHECK-Constraints hinzufügen und testen
*/

-- Beispiel-Checks 
ALTER TABLE bestellung_position
ADD CONSTRAINT chk_bestpos_menge_pos
CHECK (menge > 0);

ALTER TABLE lagerbestand
ADD CONSTRAINT chk_lagerbestand_bestand_nonneg
CHECK (bestand >= 0);

-- Test: Verletzung der Checks
-- Erwartet: CHECK-Verletzung (menge > 0)
INSERT INTO bestellung_position (bestellung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES (7001, 4, 3001, 0, CURRENT_TIMESTAMP);

-- Erwartet: UPDATE 0 (bestand >= 0)
UPDATE lagerbestand SET bestand = -1 WHERE artikel_id = 1 AND lagerort_id = 1;


/* 
Leere alle Tabellen
*/
TRUNCATE TABLE
    rechnung_position,
    bestellung_position,
    lagerbestand,
    warengruppe_artikel,
    lieferant_artikel,
    rechnung,
    bestellung,
    artikel,
    warengruppe,
    lieferant,
    lagerort,
    kunde,
    adresse
RESTART IDENTITY CASCADE;
