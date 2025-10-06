/*
Stored Procedure zur Überprüfung der Verfügbarkeit und
Eintragung eines Auftrags
*/

CREATE OR REPLACE PROCEDURE erstelle_bestellung(
    IN p_kunde_id INT,
    IN p_adresse_id INT,
    IN p_artikel_id INT,
    IN p_menge INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_bestand INT;
    v_bestellung_id INT;
BEGIN
    -- Verfügbarkeit prüfen
    SELECT SUM(bestand) INTO v_bestand
    FROM lagerbestand
    WHERE artikel_id = p_artikel_id;

    IF v_bestand IS NULL OR v_bestand < p_menge THEN
        RAISE EXCEPTION 'Artikel % nicht in ausreichender Menge verfügbar (Bestand: %, benötigt: %)',
            p_artikel_id, COALESCE(v_bestand,0), p_menge;
    END IF;

    -- Bestellung anlegen
    INSERT INTO bestellung (kunde_id, adresse_id, status, datum, aenderungsdatum)
    VALUES (p_kunde_id, p_adresse_id, 'offen', CURRENT_DATE, CURRENT_TIMESTAMP)
    RETURNING bestellung_id INTO v_bestellung_id;

    -- Position einfügen
    INSERT INTO bestellung_position (bestellung_id, position_nr, artikel_id, menge, aenderungsdatum)
    VALUES (v_bestellung_id, 1, p_artikel_id, p_menge, CURRENT_TIMESTAMP);

    -- Lagerbestand reduzieren
    UPDATE lagerbestand
    SET bestand = bestand - p_menge,
        aenderungsdatum = CURRENT_TIMESTAMP
    WHERE artikel_id = p_artikel_id
    AND lagerort_id = (
        SELECT lagerort_id
        FROM lagerbestand
        WHERE artikel_id = p_artikel_id
        ORDER BY bestand DESC
        LIMIT 1
    );

    -- aktuellen Bestand
    SELECT SUM(bestand) INTO v_bestand
    FROM lagerbestand
    WHERE artikel_id = p_artikel_id;

    RAISE NOTICE 'Bestellung % erfolgreich angelegt. Neuer Bestand von Artikel %: % Stück',
        v_bestellung_id, p_artikel_id, v_bestand;
END;
$$;


-- Setup‑Skript für den Test
-- Adresse
INSERT INTO adresse (adresse_id, strasse, haus_nr, plz, ort, aenderungsdatum)
VALUES (1001, 'Teststrasse', '1', '60311', 'Frankfurt', CURRENT_TIMESTAMP)
ON CONFLICT (adresse_id) DO NOTHING;

-- Kunde
INSERT INTO kunde (kunde_id, vorname, nachname, rechnung_adresse_id, liefer_adresse_id, aenderungsdatum)
VALUES (2001, 'Max', 'Mustermann', 1001, 1001, CURRENT_TIMESTAMP)
ON CONFLICT (kunde_id) DO NOTHING;

-- Artikel
INSERT INTO artikel (artikel_id, bezeichnung, einzelpreis, aenderungsdatum)
VALUES (3001, 'Widget', 9.99, CURRENT_TIMESTAMP)
ON CONFLICT (artikel_id) DO NOTHING;

-- Lagerort
INSERT INTO lagerort (lagerort_id, name, adresse_id, aenderungsdatum)
VALUES (6001, 'Hauptlager Frankfurt', 1001, CURRENT_TIMESTAMP)
ON CONFLICT (lagerort_id) DO NOTHING;

-- Lagerbestand für Artikel
INSERT INTO lagerbestand (artikel_id, lagerort_id, bestand, aenderungsdatum)
VALUES (3001, 6001, 100, CURRENT_TIMESTAMP)
ON CONFLICT (artikel_id, lagerort_id) DO UPDATE
SET bestand = EXCLUDED.bestand;


SELECT * FROM lagerbestand;
CALL erstelle_bestellung(2001, 1001, 3001, 5);
SELECT * FROM lagerbestand;
SELECT * FROM bestellung;
SELECT * FROM bestellung_position;


