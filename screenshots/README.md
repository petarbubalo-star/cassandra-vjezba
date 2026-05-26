# screenshots/

Screenshotovi iz cqlsh konzole kao dokaz izvršavanja upita.

## Potrebni screenshotovi

- `01_cqlsh_now.png` — Rezultat `SELECT now() FROM system.local;`
- `02_describe_tables.png` — Rezultat `DESCRIBE TABLES;` s 4 tablice
- `03_narudzbe_8_redova.png` — `SELECT * FROM narudzbe;` s minimalno 8 redova
- `04_upsert_test.png` — Dokaz UPSERT semantike
- `05_zadatak4_isporuceno.png` — SELECT s ALLOW FILTERING za status='isporuceno'
- `06_zadatak4_ttl.png` — TTL provjera i nestanak zapisa
- `07_zadatak5_update.png` — UPDATE statusa i SELECT potvrda
- `08_zadatak5_lwt.png` — LWT rezultat [applied] = false
- `09_zadatak5_delete.png` — DELETE i potvrda brisanja
- `10_zadatak6_index.png` — Secondary Index query bez ALLOW FILTERING
- `11_zadatak6_mv_status.png` — Materialized View narudzbe_po_statusu
- `12_zadatak6_agregacije.png` — SUM i AVG za korisnika C
- `13_zavrsni_lekcije.png` — SELECT lekcija sortiranih po rednom broju
- `14_zavrsni_upisi_studenta.png` — SELECT upisa po student_id
- `15_zavrsni_ttl_probni.png` — TTL probnog pristupa
- `16_zavrsni_mv_kategorija.png` — Materialized View tecajevi_po_kategoriji
- `17_zavrsni_agregacije.png` — COUNT i AVG upisa/napretka
