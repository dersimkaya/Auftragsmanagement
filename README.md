# Auftragsmanagement (PostgreSQL)

Ein relationales Datenbankschema zur Verwaltung von **Kunden, Bestellungen, Rechnungen, Artikeln, Lagerbeständen und Lieferanten**.  

Das Projekt umfasst **SQL-Skripte**, **Constraints**, **Prozeduren**, **Trigger** sowie **Testskripte**, um die Datenintegrität sicherzustellen und typische Geschäftsprozesse abzubilden.


## Überblick

- **Kernfunktionen**
  - Modellierung von Kunden, Adressen, Artikeln, Warengruppen, Lieferanten
  - Verwaltung von Bestellungen und Rechnungen inkl. Positionen
  - Lagerorte und Lagerbestände mit Mengenprüfung
- **Integrität**
  - Primär- und Fremdschlüssel
  - NOT NULL, CHECK, ON DELETE/UPDATE Regeln
- **Automatisierung**
  - Prozeduren zur Berechnung von Rabatten und weiteren Geschäftslogiken
  - Trigger zur automatischen Rechnungserstellung bei Zustellung einer Bestellung
- **Tests**
  - Reproduzierbare Inserts/Deletes zur Überprüfung von Constraints und Triggern
