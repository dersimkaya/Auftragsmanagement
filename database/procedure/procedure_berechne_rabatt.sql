CREATE OR REPLACE PROCEDURE berechne_rabatt(
    IN p_rechnung_id INT,
    IN p_persist_rabatt BOOLEAN DEFAULT TRUE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_positionssumme NUMERIC(14,2);
    v_rabatt_prozent INT := 0;
    v_rabatt_betrag NUMERIC(14,2);
    v_endbetrag NUMERIC(14,2);
BEGIN
    -- Positionssumme berechnen (benutze vorhandene betrag oder menge * einzelpreis)
    SELECT COALESCE(SUM(rp.menge * a.einzelpreis),0)::NUMERIC(14,2)
	INTO v_positionssumme
	FROM rechnung_position rp
	JOIN artikel a ON a.artikel_id = rp.artikel_id
	WHERE rp.rechnung_id = p_rechnung_id;

    -- Rabattregel: 10% nur wenn > 249
    IF v_positionssumme > 249 THEN
        v_rabatt_prozent := 10;
    ELSE
        v_rabatt_prozent := 0;
    END IF;

    v_rabatt_betrag := ROUND(v_positionssumme * (v_rabatt_prozent/100.0), 2);
    v_endbetrag := ROUND(v_positionssumme - v_rabatt_betrag, 2);

    IF p_persist_rabatt THEN
        UPDATE rechnung
        SET rabatt_prozent = v_rabatt_prozent,
            aenderungsdatum = CURRENT_TIMESTAMP
        WHERE rechnung_id = p_rechnung_id;
    END IF;

    RAISE NOTICE 'Rechnung %: positionssumme=%, rabatt_prozent=%, rabatt_betrag=%, endbetrag=%',
        p_rechnung_id, v_positionssumme, v_rabatt_prozent, v_rabatt_betrag, v_endbetrag;
END;
$$;

/* TEST*/
-- adresse
INSERT INTO adresse (adresse_id, strasse, haus_nr, plz, ort, aenderungsdatum)
VALUES (1001, 'Teststrasse', '1', '60311', 'Frankfurt', CURRENT_TIMESTAMP);

-- kunde
INSERT INTO kunde (kunde_id, vorname, nachname, rechnung_adresse_id, liefer_adresse_id, aenderungsdatum)
VALUES (2001, 'Max', 'Mustermann', 1001, 1001, CURRENT_TIMESTAMP);

-- artikel
INSERT INTO artikel (artikel_id, bezeichnung, einzelpreis, aenderungsdatum)
VALUES 
  (3001, 'Widget', 9.99, CURRENT_TIMESTAMP),
  (3002, 'Gadget', 149.50, CURRENT_TIMESTAMP);

-- rechnung
INSERT INTO rechnung (rechnung_id, kunde_id, adresse_id, datum, status, aenderungsdatum)
VALUES (8001, 2001, 1001, CURRENT_DATE, 'offen', CURRENT_TIMESTAMP);

-- rechnung_position
INSERT INTO rechnung_position (rechnung_id, position_nr, artikel_id, menge, aenderungsdatum)
VALUES
  (8001, 1, 3001, 10, CURRENT_TIMESTAMP),  
  (8001, 2, 3002, 2, CURRENT_TIMESTAMP);   


CALL berechne_rabatt(8001)
