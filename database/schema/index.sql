-- Essentielle Indizes für das Schema (Fremdschlüssel und häufige Joins/Filter)

-- bestellung
CREATE INDEX IF NOT EXISTS idx_bestellung_kunde_id   ON bestellung(kunde_id);
CREATE INDEX IF NOT EXISTS idx_bestellung_adresse_id ON bestellung(adresse_id);
CREATE INDEX IF NOT EXISTS idx_bestellung_status     ON bestellung(status);
CREATE INDEX IF NOT EXISTS idx_bestellung_datum      ON bestellung(datum);

-- rechnung
CREATE INDEX IF NOT EXISTS idx_rechnung_kunde_id     ON rechnung(kunde_id);
CREATE INDEX IF NOT EXISTS idx_rechnung_adresse_id   ON rechnung(adresse_id);
CREATE INDEX IF NOT EXISTS idx_rechnung_status       ON rechnung(status);
CREATE INDEX IF NOT EXISTS idx_rechnung_datum        ON rechnung(datum);

-- rechnung_position
CREATE INDEX IF NOT EXISTS idx_rechnung_position_rechnung_id  ON rechnung_position(rechnung_id);
CREATE INDEX IF NOT EXISTS idx_rechnung_position_artikel_id   ON rechnung_position(artikel_id);

-- bestellung_position
CREATE INDEX IF NOT EXISTS idx_bestellung_position_bestellung_id ON bestellung_position(bestellung_id);
CREATE INDEX IF NOT EXISTS idx_bestellung_position_artikel_id    ON bestellung_position(artikel_id);

-- lager
CREATE INDEX IF NOT EXISTS idx_lagerbestand_lagerort_id ON lagerbestand(lagerort_id);
CREATE INDEX IF NOT EXISTS idx_lagerort_adresse_id      ON lagerort(adresse_id);

-- warengruppe
CREATE INDEX IF NOT EXISTS idx_warengruppe_artikel_warengruppe_id ON warengruppe_artikel(warengruppe_id);

-- lieferant
CREATE INDEX IF NOT EXISTS idx_lieferant_adresse_id        ON lieferant(adresse_id);
CREATE INDEX IF NOT EXISTS idx_lieferant_artikel_artikel_id ON lieferant_artikel(artikel_id);