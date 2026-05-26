-- ============================================================
-- Vježba: Apache Cassandra – Distribuirana Wide-Column Baza
-- Upravljanje Podacima | FPMOZ
-- ============================================================


-- ============================================================
-- KORAK 1 — Pokretanje okruženja
-- ============================================================

-- Zadatak 1 — Provjera okruženja
SELECT now() FROM system.local;


-- ============================================================
-- KORAK 2 — Keyspace i tablice
-- ============================================================

-- Kreiranje keyspace-a
CREATE KEYSPACE IF NOT EXISTS vjezba
  WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
  };

USE vjezba;

-- Kreiranje tablice narudžbi
CREATE TABLE narudzbe (
  korisnik_id UUID,
  created_at  TIMESTAMP,
  narudzba_id UUID,
  ukupno      DECIMAL,
  status      TEXT,
  grad        TEXT,
  PRIMARY KEY (korisnik_id, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);

-- Kreiranje tablice proizvoda
CREATE TABLE proizvodi (
  id          UUID PRIMARY KEY,
  naziv       TEXT,
  cijena      DECIMAL,
  kategorija  TEXT,
  dostupnost  BOOLEAN
);

-- Kreiranje tablice recenzija
CREATE TABLE recenzije (
  proizvod_id UUID,
  korisnik_id UUID,
  ocjena      INT,
  komentar    TEXT,
  created_at  TIMESTAMP,
  PRIMARY KEY (proizvod_id, korisnik_id)
);

-- Zadatak 2 — Vlastita tablica: praćenje pregleda proizvoda
CREATE TABLE pregledi_proizvoda (
  proizvod_id  UUID,
  korisnik_id  UUID,
  pregledano   TIMESTAMP,
  trajanje_sec INT,
  PRIMARY KEY (proizvod_id, korisnik_id, pregledano)
) WITH CLUSTERING ORDER BY (korisnik_id ASC, pregledano DESC);

-- Provjera kreiranih tablica
DESCRIBE TABLES;
DESCRIBE TABLE narudzbe;


-- ============================================================
-- KORAK 3 — Unos podataka
-- ============================================================

-- Unos proizvoda
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Laptop Pro 15', 1299.99, 'elektronika', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Bežične slušalice', 149.99, 'elektronika', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Ergonomska stolica', 349.00, 'namještaj', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Mehanička tipkovnica', 89.99, 'elektronika', false);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Monitor 27"', 499.00, 'elektronika', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Radni stol', 279.00, 'namještaj', true);

-- Provjera proizvoda (kopiraj UUID-ove za recenzije)
SELECT * FROM proizvodi;

-- Narudžbe korisnika A
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 1449.98, 'isporuceno', 'Zagreb');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 349.00, 'u_obradi', 'Zagreb');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 89.99, 'isporuceno', 'Zagreb');

-- Narudžbe korisnika B
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (22222222-2222-2222-2222-222222222222, toTimestamp(now()), uuid(), 499.00, 'isporuceno', 'Split');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (22222222-2222-2222-2222-222222222222, toTimestamp(now()), uuid(), 279.00, 'otkazano', 'Split');

-- Zadatak 3 — Vlastite narudžbe za korisnika C (3 narudžbe, različiti gradovi)
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 149.99, 'isporuceno', 'Mostar');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 89.99, 'u_obradi', 'Sarajevo');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 499.00, 'isporuceno', 'Banja Luka');

-- Provjera narudžbi (mora biti minimalno 8 redova)
SELECT * FROM narudzbe;
SELECT COUNT(*) FROM narudzbe;

-- Test UPSERT semantike: isti primary key, drugačiji iznos
-- UPUTA: kopiraj korisnik_id i created_at iz SELECT * FROM narudzbe; za korisnika A
-- INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
-- VALUES (11111111-1111-1111-1111-111111111111, <kopirani-timestamp>, uuid(), 9999.99, 'test_upsert', 'Zagreb');
-- SELECT * FROM narudzbe WHERE korisnik_id = 11111111-1111-1111-1111-111111111111;

-- Unos recenzija
-- UPUTA: kopiraj UUID-ove laptopa i stolice iz SELECT * FROM proizvodi;
-- INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at)
-- VALUES (<uuid-laptop>, 11111111-1111-1111-1111-111111111111, 5, 'Odličan laptop, brz i tih.', toTimestamp(now()));
-- INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at)
-- VALUES (<uuid-laptop>, 22222222-2222-2222-2222-222222222222, 4, 'Dobra kupnja, baterija mogla bolja.', toTimestamp(now()));
-- INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at)
-- VALUES (<uuid-stolica>, 11111111-1111-1111-1111-111111111111, 5, 'Spasila mi je leđa!', toTimestamp(now()));


-- ============================================================
-- KORAK 4 — SELECT upiti
-- ============================================================

-- Sve narudžbe korisnika A
SELECT korisnik_id, created_at, ukupno, status
FROM narudzbe
WHERE korisnik_id = 11111111-1111-1111-1111-111111111111;

-- Narudžbe korisnika A od određenog datuma
SELECT * FROM narudzbe
WHERE korisnik_id = 11111111-1111-1111-1111-111111111111
  AND created_at >= '2024-01-01 00:00:00+0000';

-- Paginacija — prvih 2 narudžbe
SELECT * FROM narudzbe
WHERE korisnik_id = 11111111-1111-1111-1111-111111111111
LIMIT 2;

-- Svi proizvodi
SELECT naziv, cijena, kategorija, dostupnost FROM proizvodi;

-- ALLOW FILTERING — filtriranje po kategoriji
SELECT naziv, cijena FROM proizvodi
WHERE kategorija = 'elektronika' ALLOW FILTERING;

-- ALLOW FILTERING — dostupni proizvodi
SELECT naziv, cijena FROM proizvodi
WHERE dostupnost = true ALLOW FILTERING;

-- TTL test — zapis koji nestaje za 60 sekundi
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 9.99, 'test', 'Mostar')
USING TTL 60;

-- Provjera TTL-a
SELECT TTL(status), TTL(ukupno), status, grad
FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

-- Zadatak 4 — Sve narudžbe korisnika C sortirane od najstarije
-- (koristimo paginaciju jer je CLUSTERING ORDER DESC — trebamo obrnuti)
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333
ORDER BY created_at ASC;

-- Zadatak 4 — Sve narudžbe sa statusom 'isporuceno' (ALLOW FILTERING)
SELECT * FROM narudzbe
WHERE status = 'isporuceno' ALLOW FILTERING;

-- Zadatak 4 — TTL test s 30 sekundi
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (44444444-4444-4444-4444-444444444444, toTimestamp(now()), uuid(), 19.99, 'ttl_test', 'Zenica')
USING TTL 30;

SELECT TTL(status), status, grad
FROM narudzbe
WHERE korisnik_id = 44444444-4444-4444-4444-444444444444;

-- Nakon 35 sekundi — provjera da zapis ne postoji
SELECT * FROM narudzbe
WHERE korisnik_id = 44444444-4444-4444-4444-444444444444;


-- ============================================================
-- KORAK 5 — UPDATE, DELETE i Lightweight Transactions
-- ============================================================

-- UPDATE statusa narudžbe korisnika B
-- UPUTA: kopiraj točan timestamp iz SELECT * FROM narudzbe WHERE korisnik_id = 22222222-...;
-- UPDATE narudzbe SET status = 'isporuceno'
-- WHERE korisnik_id = 22222222-2222-2222-2222-222222222222
--   AND created_at = <kopirani-timestamp>;

-- Provjera UPDATE-a
SELECT * FROM narudzbe
WHERE korisnik_id = 22222222-2222-2222-2222-222222222222;

-- Zadatak 5 — UPDATE narudžbe korisnika C iz 'u_obradi' u 'isporuceno'
-- UPUTA: kopiraj timestamp narudžbe sa statusom 'u_obradi' za korisnika C
-- UPDATE narudzbe SET status = 'isporuceno'
-- WHERE korisnik_id = 33333333-3333-3333-3333-333333333333
--   AND created_at = <kopirani-timestamp>;

-- Potvrda promjene
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

-- LWT — INSERT IF NOT EXISTS s postojećim UUID-om
-- UPUTA: kopiraj UUID nekog proizvoda iz SELECT * FROM proizvodi;
-- INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
-- VALUES (<postojeci-uuid>, 'Duplikat test', 9.99, 'test', true)
-- IF NOT EXISTS;
-- Rezultat: [applied] = false

-- DELETE jedne narudžbe
-- UPUTA: kopiraj timestamp narudžbe za brisanje
-- DELETE FROM narudzbe
-- WHERE korisnik_id = 33333333-3333-3333-3333-333333333333
--   AND created_at = <kopirani-timestamp>;

-- Potvrda brisanja
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

-- BATCH — grupiranje pisanja
-- UPUTA: kopiraj UUID monitora iz SELECT * FROM proizvodi;
-- BEGIN BATCH
--   INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at)
--   VALUES (<uuid-monitora>, 22222222-2222-2222-2222-222222222222, 5, 'Odlična rezolucija.', toTimestamp(now()));
--   UPDATE recenzije SET ocjena = 5
--   WHERE proizvod_id = <uuid-monitora>
--     AND korisnik_id = 22222222-2222-2222-2222-222222222222;
-- APPLY BATCH;


-- ============================================================
-- KORAK 6 — Secondary Index, Materialized View i agregacije
-- ============================================================

-- Secondary Index na kategorija
CREATE INDEX idx_kategorija ON proizvodi (kategorija);

-- Query bez ALLOW FILTERING
SELECT naziv, cijena FROM proizvodi
WHERE kategorija = 'elektronika';

DESCRIBE INDEX idx_kategorija;

-- Zadatak 6 — Secondary Index na dostupnost
CREATE INDEX idx_dostupnost ON proizvodi (dostupnost);

SELECT naziv, cijena FROM proizvodi
WHERE dostupnost = true;

-- Materialized View — narudzbe po gradu
CREATE MATERIALIZED VIEW narudzbe_po_gradu AS
  SELECT *
  FROM narudzbe
  WHERE grad IS NOT NULL
    AND korisnik_id IS NOT NULL
    AND created_at IS NOT NULL
  PRIMARY KEY (grad, korisnik_id, created_at)
  WITH CLUSTERING ORDER BY (korisnik_id ASC, created_at DESC);

-- Query po gradu
SELECT * FROM narudzbe_po_gradu WHERE grad = 'Zagreb';

-- Zadatak 6 — Materialized View narudzbe_po_statusu
CREATE MATERIALIZED VIEW narudzbe_po_statusu AS
  SELECT *
  FROM narudzbe
  WHERE status IS NOT NULL
    AND korisnik_id IS NOT NULL
    AND created_at IS NOT NULL
  PRIMARY KEY (status, korisnik_id, created_at)
  WITH CLUSTERING ORDER BY (korisnik_id ASC, created_at DESC);

-- Query po statusu
SELECT * FROM narudzbe_po_statusu WHERE status = 'isporuceno';

-- Agregacije
SELECT COUNT(*) AS broj_narudzbi
FROM narudzbe
WHERE korisnik_id = 11111111-1111-1111-1111-111111111111;

SELECT SUM(ukupno) AS ukupna_potrosnja
FROM narudzbe
WHERE korisnik_id = 11111111-1111-1111-1111-111111111111;

-- Zadatak 6 — SUM i AVG za korisnika C
SELECT SUM(ukupno) AS ukupna_potrosnja, AVG(ukupno) AS prosjecni_iznos
FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

-- Prosječna ocjena za laptop
-- UPUTA: kopiraj UUID laptopa
-- SELECT AVG(ocjena) AS prosjecna_ocjena, COUNT(*) AS broj_recenzija
-- FROM recenzije
-- WHERE proizvod_id = <uuid-laptopa>;


-- ============================================================
-- KORAK 7 — Schema validacija i pregled
-- ============================================================

-- Pregled keyspace-a
DESCRIBE KEYSPACE vjezba;

-- Pregled tablica
DESCRIBE TABLE narudzbe;
DESCRIBE TABLE narudzbe_po_gradu;

-- Svi indeksi
SELECT * FROM system_schema.indexes WHERE keyspace_name = 'vjezba';


-- ============================================================
-- ZAVRŠNI ZADATAK — Platforma za online tečajeve
-- ============================================================

-- Kreiranje tablica
CREATE TABLE tecajevi (
  tecaj_id      UUID,
  naziv         TEXT,
  instruktor    TEXT,
  kategorija    TEXT,
  cijena        DECIMAL,
  trajanje_sati INT,
  PRIMARY KEY (tecaj_id)
);

CREATE TABLE upisi (
  student_id   UUID,
  tecaj_id     UUID,
  datum_upisa  TIMESTAMP,
  napredak     INT,
  status       TEXT,
  PRIMARY KEY (student_id, tecaj_id)
);

CREATE TABLE lekcije (
  tecaj_id     UUID,
  redni_broj   INT,
  naslov       TEXT,
  trajanje_min INT,
  sadrzaj_url  TEXT,
  PRIMARY KEY (tecaj_id, redni_broj)
) WITH CLUSTERING ORDER BY (redni_broj ASC);

-- Provjera tablica
DESCRIBE TABLES;

-- Unos tečajeva (5+)
INSERT INTO tecajevi (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, 'Python za početnike', 'Ana Kovač', 'programiranje', 49.99, 20);

INSERT INTO tecajevi (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, 'Web razvoj s React', 'Ivan Marić', 'web', 79.99, 35);

INSERT INTO tecajevi (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (cccccccc-cccc-cccc-cccc-cccccccccccc, 'Baze podataka', 'Maja Horvat', 'baze_podataka', 59.99, 25);

INSERT INTO tecajevi (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (dddddddd-dddd-dddd-dddd-dddddddddddd, 'Machine Learning osnove', 'Petar Novak', 'ai_ml', 99.99, 40);

INSERT INTO tecajevi (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee, 'Docker i Kubernetes', 'Luka Babić', 'devops', 69.99, 30);

INSERT INTO tecajevi (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (ffffffff-ffff-ffff-ffff-ffffffffffff, 'UI/UX Dizajn', 'Sara Pušić', 'dizajn', 44.99, 18);

-- Provjera tečajeva
SELECT * FROM tecajevi;

-- Unos upisa (10+ za minimalno 3 studenta)
INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (55555555-5555-5555-5555-555555555555, aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, toTimestamp(now()), 100, 'završen');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (55555555-5555-5555-5555-555555555555, bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, toTimestamp(now()), 60, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (55555555-5555-5555-5555-555555555555, cccccccc-cccc-cccc-cccc-cccccccccccc, toTimestamp(now()), 30, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (55555555-5555-5555-5555-555555555555, dddddddd-dddd-dddd-dddd-dddddddddddd, toTimestamp(now()), 0, 'upisan');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (66666666-6666-6666-6666-666666666666, aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, toTimestamp(now()), 75, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (66666666-6666-6666-6666-666666666666, cccccccc-cccc-cccc-cccc-cccccccccccc, toTimestamp(now()), 50, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (66666666-6666-6666-6666-666666666666, eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee, toTimestamp(now()), 90, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (77777777-7777-7777-7777-777777777777, bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, toTimestamp(now()), 20, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (77777777-7777-7777-7777-777777777777, dddddddd-dddd-dddd-dddd-dddddddddddd, toTimestamp(now()), 45, 'u_tijeku');

INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (77777777-7777-7777-7777-777777777777, ffffffff-ffff-ffff-ffff-ffffffffffff, toTimestamp(now()), 100, 'završen');

-- Provjera upisa
SELECT * FROM upisi;

-- Unos lekcija (15+)
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, 1, 'Uvod u Python', 15, 'https://tecaj.hr/python/1');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, 2, 'Varijable i tipovi podataka', 20, 'https://tecaj.hr/python/2');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, 3, 'Petlje i uvjeti', 25, 'https://tecaj.hr/python/3');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, 4, 'Funkcije', 30, 'https://tecaj.hr/python/4');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa, 5, 'Moduli i paketi', 20, 'https://tecaj.hr/python/5');

INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, 1, 'Uvod u React', 20, 'https://tecaj.hr/react/1');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, 2, 'Komponente i props', 25, 'https://tecaj.hr/react/2');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, 3, 'State i hooks', 30, 'https://tecaj.hr/react/3');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, 4, 'Routing', 20, 'https://tecaj.hr/react/4');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb, 5, 'API pozivi', 25, 'https://tecaj.hr/react/5');

INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (cccccccc-cccc-cccc-cccc-cccccccccccc, 1, 'Relacijski model', 20, 'https://tecaj.hr/baze/1');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (cccccccc-cccc-cccc-cccc-cccccccccccc, 2, 'SQL osnove', 25, 'https://tecaj.hr/baze/2');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (cccccccc-cccc-cccc-cccc-cccccccccccc, 3, 'NoSQL baze', 30, 'https://tecaj.hr/baze/3');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (dddddddd-dddd-dddd-dddd-dddddddddddd, 1, 'Uvod u ML', 20, 'https://tecaj.hr/ml/1');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (dddddddd-dddd-dddd-dddd-dddddddddddd, 2, 'Linearna regresija', 35, 'https://tecaj.hr/ml/2');
INSERT INTO lekcije (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (dddddddd-dddd-dddd-dddd-dddddddddddd, 3, 'Klasifikacija', 30, 'https://tecaj.hr/ml/3');

-- Provjera lekcija
SELECT * FROM lekcije;

-- SELECT — sve lekcije tečaja Python sortirane po rednom broju
SELECT redni_broj, naslov, trajanje_min
FROM lekcije
WHERE tecaj_id = aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
ORDER BY redni_broj ASC;

-- SELECT — svi tečajevi na koje je upisan student 1
SELECT * FROM upisi
WHERE student_id = 55555555-5555-5555-5555-555555555555;

-- UPDATE — ažuriranje napretka studenta
UPDATE upisi SET napredak = 80
WHERE student_id = 55555555-5555-5555-5555-555555555555
  AND tecaj_id = bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb;

-- Provjera UPDATE-a
SELECT * FROM upisi
WHERE student_id = 55555555-5555-5555-5555-555555555555;

-- TTL — probni pristup tečaju koji ističe za 7 dana
INSERT INTO upisi (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (88888888-8888-8888-8888-888888888888, eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee, toTimestamp(now()), 0, 'probni')
USING TTL 604800;

-- Provjera TTL-a
SELECT TTL(status), TTL(napredak), student_id, status
FROM upisi
WHERE student_id = 88888888-8888-8888-8888-888888888888;

-- Materialized View — tečajevi po kategoriji
CREATE MATERIALIZED VIEW tecajevi_po_kategoriji AS
  SELECT *
  FROM tecajevi
  WHERE kategorija IS NOT NULL
    AND tecaj_id IS NOT NULL
  PRIMARY KEY (kategorija, tecaj_id);

-- Query po kategoriji
SELECT * FROM tecajevi_po_kategoriji WHERE kategorija = 'programiranje';
SELECT * FROM tecajevi_po_kategoriji WHERE kategorija = 'web';

-- COUNT upisa po tečaju
SELECT COUNT(*) AS broj_upisa
FROM upisi
WHERE student_id = 55555555-5555-5555-5555-555555555555;

-- AVG napretka po studentu
SELECT AVG(napredak) AS prosjecni_napredak
FROM upisi
WHERE student_id = 55555555-5555-5555-5555-555555555555;

SELECT AVG(napredak) AS prosjecni_napredak
FROM upisi
WHERE student_id = 66666666-6666-6666-6666-666666666666;
