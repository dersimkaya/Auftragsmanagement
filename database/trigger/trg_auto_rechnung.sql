-- trg_auto_rechnung_from_bestellung
CREATE OR REPLACE FUNCTION trg_auto_rechnung_from_bestellung()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_rechnung_id INT;
BEGIN
    -- Nur reagieren, wenn Status neu 'zugestellt' ist
    IF NEW.status = 'zugestellt' AND (OLD.status IS DISTINCT FROM 'zugestellt') THEN

        -- 1) Rechnung anlegen (ohne gesamtbetrag)
        INSERT INTO rechnung (kunde_id, adresse_id, datum, status, aenderungsdatum)
        VALUES (NEW.kunde_id, NEW.adresse_id, CURRENT_DATE, 'offen', CURRENT_TIMESTAMP)
        RETURNING rechnung_id INTO v_rechnung_id;

        -- 2) Positionen aus Bestellung übernehmen
        INSERT INTO rechnung_position (rechnung_id, position_nr, artikel_id, menge, aenderungsdatum)
        SELECT
            v_rechnung_id,
            bp.position_nr,
            bp.artikel_id,
            bp.menge,
            CURRENT_TIMESTAMP
        FROM bestellung_position bp
        WHERE bp.bestellung_id = NEW.bestellung_id;

        -- 3) Rabatt-Procedure aufrufen (setzt rabatt_prozent in rechnung)
        CALL berechne_rabatt(v_rechnung_id);

        -- 4) Rechnungstatus aktualisieren
        UPDATE rechnung
        SET status = 'erstellt',
            aenderungsdatum = CURRENT_TIMESTAMP
        WHERE rechnung_id = v_rechnung_id;

        RAISE NOTICE 'Rechnung % erstellt aus Bestellung % (Trigger).', v_rechnung_id, NEW.bestellung_id;
    END IF;

    RETURN NEW;
END;
$$;


-- Trigger an Tabelle bestellung hängen
CREATE OR REPLACE TRIGGER trg_auto_rechnung_from_bestellung
AFTER UPDATE OF status ON bestellung
FOR EACH ROW
WHEN (NEW.status = 'zugestellt' AND OLD.status IS DISTINCT FROM 'zugestellt')
EXECUTE FUNCTION trg_auto_rechnung_from_bestellung();

/* Testskript */

-- 1) Basisdaten einfügen
INSERT INTO adresse (strasse, haus_nr, plz, ort) VALUES ('Teststrasse','1','60311','Frankfurt') RETURNING adresse_id;

INSERT INTO kunde (vorname, nachname, rechnung_adresse_id, liefer_adresse_id)
VALUES ('Max','Mustermann',1,1) RETURNING kunde_id;

INSERT INTO artikel (bezeichnung, einzelpreis) VALUES ('Widget', 9.99), ('Gadget', 149.50);

-- 2) Bestellung und Positionen anlegen
INSERT INTO bestellung (kunde_id, adresse_id, status) VALUES (1,1,'offen') RETURNING bestellung_id;

INSERT INTO bestellung_position (bestellung_id, position_nr, artikel_id, menge)
VALUES (1,1,1,10), (1,2,2,2);

-- 3) Trigger auslösen: Statuswechsel auf 'zugestellt'
UPDATE bestellung
SET status = 'zugestellt', aenderungsdatum = CURRENT_TIMESTAMP
WHERE bestellung_id = 1;

-- 4) Kontrolle: erzeugte Rechnung und Positionen prüfen
SELECT * FROM rechnung WHERE rechnung_id = (SELECT MAX(rechnung_id) FROM rechnung);
