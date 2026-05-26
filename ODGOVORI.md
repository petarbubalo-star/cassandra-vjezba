# ODGOVORI.md — Vježba: Apache Cassandra

---

## Zadatak 1 — Port i razlika od Neo4j

Cassandra eksponira **port 9042** — to je CQL native transport port koji koriste cqlsh konzola i svi aplikacijski driveri (Python, Java, Node.js) za komunikaciju s bazom putem binarnog protokola.

Cassandra nema web browser sučelje poput Neo4j Browsera iz nekoliko razloga. Neo4j Browser je specifičan alat dizajniran za vizualizaciju grafa i interaktivno pisanje Cypher upita — graf model se prirodno vizualizira kao mreža čvorova i veza. Cassandra koristi tabličnu wide-column strukturu koja se ne vizualizira na isti način, pa nema iste potrebe za grafičkim sučeljem. Uz to, Cassandra je dizajnirana za visokopropusno upravljanje podacima u distribuiranom okruženju, a primarna interakcija s njom odvija se kroz cqlsh konzolu ili aplikacijske drivere, ne kroz web sučelje.

---

## Zadatak 2 — Partition key i hot partition problem

Partition key je dio primary key-a koji određuje na koji čvor u klasteru se pohrani određeni podatak — Cassandra izračunava hash partition key-a i prema tome raspoređuje podatke po čvorovima. Izbor partition key-a je kritičan jer direktno određuje na koji čvor idu podaci: loš izbor može dovesti do neravnomjerne raspodjele opterećenja, dok dobar izbor osigurava da se podaci raspoređuju ravnomjerno.

Ako svi zapisi imaju isti partition key, nastaje tzv. **hot partition problem** — svi podaci završe na jednom čvoru u klasteru dok ostali čvorovi stoje neiskorišteni. Taj jedan čvor prima sve upite za čitanje i pisanje, postaje usko grlo sustava i može se preopteretiti, čime se gubi glavna prednost distribuirane arhitekture. U tablici narudzbe, korisnik_id kao partition key je dobar izbor jer se narudžbe raspoređuju po korisnicima — problem bi nastao samo ako jedan korisnik ima milijune narudžbi.

---

## Zadatak 4 — Zašto je ALLOW FILTERING problematičan

ALLOW FILTERING na stupcu status zahtijeva **full table scan** — Cassandra mora kontaktirati sve čvorove u klasteru i skenirati sve particije u tablici da pronađe redove koji zadovoljavaju uvjet. U produkciji s milijunima narudžbi i desecima čvorova, ovakav upit može zagušiti cijeli klaster jer troši resurse (CPU, I/O, mrežu) proporcionalno ukupnoj veličini podataka, a ne veličini rezultata. Efikasno rješenje je kreiranje Secondary Indexa na status stupcu ili Materialized Viewa s drugačijim partition key-em.

### Razlika između partition key i clustering column u WHERE upitima

Partition key u WHERE klauzuli govori Cassandri točno na koji čvor treba ići po podatke — upit je O(1) neovisno o veličini klastera. U tablici narudzbe, uvjet `WHERE korisnik_id = ...` koristi partition key i Cassandra odmah zna na kojem čvoru su sve narudžbe tog korisnika. Clustering column (created_at) se može koristiti u WHERE samo uz partition key — omogućuje range upite unutar jedne particije, npr. `AND created_at >= '2024-01-01'` za filtriranje narudžbi po datumu. Bez partition key-a u WHERE, Cassandra ne zna gdje su podaci i mora skenirati sve čvorove.

---

## Zadatak 5 — Tombstone i Compaction

Kada se izvrši DELETE u Cassandri, podatak se ne briše odmah već se zapisuje **tombstone** — poseban marker s timestamp-om koji označava da je određeni podatak obrisan. Razlog je distribuirana arhitektura: u trenutku brisanja neki čvorovi možda nisu dostupni, pa bi bez tombstone-a mogli "oživjeti" stare podatke kad se vrate online. Tombstone osigurava da svi čvorovi, čak i oni koji su bili offline, saznaju za brisanje kad se sinkroniziraju. Cassandra čisti tombstone-ove kroz proces **Compaction** — periodičan proces koji spaja SSTables datoteke i pri tome odbacuje sve zapise s tombstone-om koji su stariji od `gc_grace_seconds` (zadano 10 dana), čime se osigurava da su svi čvorovi imali dovoljno vremena za sinkronizaciju.

---

## Zadatak 6 — Secondary Index vs Materialized View

**Secondary Index** je prikladniji za stupce s niskim brojem različitih vrijednosti (low-cardinality), kao što su kategorija ili status, gdje upit vraća relativno mali broj rezultata. Index je distribuiran po čvorovima i query mora kontaktirati sve čvorove, ali to je prihvatljivo za rijetke upite u razvoju ili admin sučeljima. **Materialized View** je bolji za stabilne pristupne obrasce koji se često koriste u produkciji — MV kreira drugu fizičku tablicu s drugačijim partition key-em, pa query direktno ide na pravi čvor bez skeniranja cijelog klastera. Tradeoff je write amplifikacija: svaki INSERT u originalnu tablicu automatski ažurira i MV. Primjer iz vježbe: za česte upite "sve narudžbe iz Zagreba" MV narudzbe_po_gradu je pravo rješenje jer grad postaje partition key, dok bi Secondary Index na gradu bio sporiji jer mora kontaktirati sve čvorove.

---

## Završni zadatak — Cassandra vs PostgreSQL za platformu tečajeva

Za platformu online tečajeva, Cassandra bi bila opravdana kada platforma dostigne visokovolumni rast i globalni doseg. Konkretno, Cassandra bi bila bolja za upravljanje logovima aktivnosti studenata — svaki put kad student otvori lekciju, pauzira video ili položi kviz, generira se zapis. Uz milijune studenata na globalnoj platformi, to može biti tisuće zapisa po sekundi, što je točno profil za koji je Cassandra dizajnirana: visoki write throughput bez žrtvovanja latencije čitanja.

TTL mehanizam je specifičan problem koji bi u PostgreSQL-u zahtijevao složeni cron job ili background worker za brisanje isteklih probnih pristupa, dok Cassandra to rješava nativno jednim parametrom pri insertu. Probni pristup koji automatski ističe za 7 dana je jednolinijski CQL upit.

Globalna distribucija je treći razlog — Cassandra s NetworkTopologyStrategy može imati replike u više datacenter regija (Europa, Amerika, Azija) i pisanje uvijek ide na najbliži čvor, što je presudno za platformu s globalnim korisnicima. PostgreSQL nema nativnu multi-region write distribuciju.

S druge strane, PostgreSQL bi i dalje bio bolji za transakcijsku stranu platforme: naplate, fakture, povrate novca i upravljanje korisničkim računima gdje su ACID transakcije i JOIN upiti neophodnost.
