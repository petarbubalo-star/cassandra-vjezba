# Cassandra Vježba — Distribuirana Wide-Column Baza Podataka

Repozitorij za vježbu iz kolegija **Upravljanje Podacima** (FPMOZ).  
Tema: Apache Cassandra, CQL, distribuirana arhitektura.

---

## Sadržaj repozitorija

| Datoteka / Mapa | Opis |
|---|---|
| `docker-compose.yml` | Konfiguracija Cassandra instance u Dockeru |
| `queries.cql` | Svi CQL upiti iz vježbe s komentarima |
| `ODGOVORI.md` | Pisani odgovori na teorijska pitanja iz Zadataka 1, 2, 4, 5 i Završnog zadatka |
| `screenshots/` | Screenshotovi rezultata iz cqlsh konzole |

---

## Kako pokrenuti okruženje

### Preduvjeti

- Instaliran [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Pokretanje

```bash
# 1. Klonirati repozitorij
git clone <URL_repozitorija>
cd cassandra-vjezba

# 2. Pokrenuti Cassandra kontejner u pozadini
docker compose up -d

# 3. Pričekati ~30 sekundi da se Cassandra inicijalizira
# Pratiti log:
docker compose logs cassandra -f
# Čekati poruku: "Starting listening for CQL clients"

# 4. Provjeriti ime kontejnera
docker ps --format '{{.Names}}'

# 5. Spojiti se na cqlsh konzolu
docker exec -it cassandra-cassandra-1 cqlsh
```

### Pristup cqlsh konzoli

Nakon pokretanja, spojiti se naredbom:
```bash
docker exec -it cassandra-cassandra-1 cqlsh
```

Pri uspješnom spajanju vidjet ćete prompt `cqlsh>`.

---

## Pokretanje upita

Upiti su organizirani u datoteci `queries.cql` po koracima i zadacima.  
Kopirati upit u cqlsh konzolu i pritisnuti **Enter** za izvršavanje.

**Važna napomena:** Upiti koji sadrže `<uuid-...>` ili `<kopirani-timestamp>` zahtijevaju da se vrijednost ručno kopira iz prethodnog SELECT upita.

Preporučeni redoslijed:
1. Korak 1 — provjera okruženja (`SELECT now()`)
2. Korak 2 — keyspace i tablice
3. Korak 3 — unos podataka
4. Korak 4 — SELECT upiti i TTL
5. Korak 5 — UPDATE, DELETE, LWT
6. Korak 6 — Secondary Index, Materialized View, agregacije
7. Korak 7 — schema validacija
8. Završni zadatak — platforma za online tečajeve

---

## Zaustavljanje okruženja

```bash
docker compose down
```

Za brisanje podataka:
```bash
docker compose down -v
```
