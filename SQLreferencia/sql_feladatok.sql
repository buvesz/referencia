--select feladatok from buvesz :*
--1
--Listázza ki az ügyfelek azonosítóját, teljes nevét, valamint a megrendeléseik azonosítóját! Azok az ügyfelek is szerepeljenek az eredményben,
--akik soha nem adtak le megrendeléseket. A lista legyen vezetéknév, azon belül megrendelés azonosítója szerint rendezve
SELECT u.ugyfel_id, u.vezeteknev, u.keresztnev, m.megrendeles_id
FROM hajo.s_ugyfel u
LEFT JOIN hajo.s_megrendeles m
    ON u.ugyfel_id=m.ugyfel
ORDER BY u.vezeteknev, u.ugyfel_id;

--2.
--Listázza ki a hajótípusok azonosítóját és nevét, valamint az adott típusú hajók azonosítóját és nevét! A hajótípusok nevét tartalmazó oszlop
--'típusnév', a hajók nevét tartalmazó oszlop pedig 'hajónév' legyen! Azok a hajótípusok is jelenjenek meg, amelyhez egyetlen hajó sem tartzoik.
--A lista legyen a hajótípus neve, azon belül a hajó neve alapján rendezve.
SELECT ht.hajo_tipus_id, ht.nev Típusnév, h.nev Hajónév, h.nev
FROM hajo.s_hajo_tipus ht
LEFT JOIN hajo.s_hajo h
    ON ht.hajo_tipus_id=h.hajo_tipus
ORDER BY Típusnév, Hajónév;

select * from hajo.s_hozzarendel;
--5.
--Listázza ki Magyarországénál kisebb lakossággal rendelkez? országok nevét, lakosságát, valamint a f?városuk nevét. Azokat az országokat is
--listázza, amelyeknek nem ismerjük a f?városát. Ezen országok esetében a f?város helyén "nem ismert" sztring szerepeljen. Rendezze az országokat
--a lakosság szerint csökken? sorrendben.
SELECT o.orszag, o.lakossag, NVL(h.helysegnev, 'nem ismert') Fovaros
FROM hajo.s_orszag o
LEFT JOIN hajo.s_helyseg h
    ON o.fovaros=h.helyseg_id
WHERE o.lakossag < (
    SELECT lakossag
    FROM hajo.s_orszag
    WHERE orszag LIKE 'Magyarország'
)
ORDER BY o.lakossag DESC;

--6 
--Listázza ki azoknak az ügyfeleknek az azonosítóját és teljes nevét,
--akik adtak már fel olasz- országi kiköt?b?l induló szállításra vonatkozó megrendelést! 
--Egy ügyfél csak egyszer szere- peljen az eredményben!
SELECT DISTINCT u.ugyfel_id, u.vezeteknev || ' ' || u.keresztnev Ugyfel_nev
FROM hajo.s_ugyfel u
INNER JOIN hajo.s_megrendeles m
ON u.ugyfel_id=m.ugyfel
INNER JOIN hajo.s_kikoto k
    ON m.indulasi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
WHERE h.orszag LIKE 'Olaszország';

--7
--Listázza ki azoknak a hajóknak az azonosítóját és nevét, amelyek egyetlen út célállomásaként sem kötöttek ki francia kiköt?kben
SELECT nev, hajo_id
FROM hajo.s_hajo
WHERE hajo_id NOT IN(
SELECT h.hajo_id
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON h.hajo_id=u.hajo
INNER JOIN hajo.s_kikoto k
    ON u.erkezesi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
WHERE h.orszag LIKE 'Franciaország'
);


--8.
--Listázza ki azoknak a helységeknek az azonosítóját, országát és nevét, amelyeknek valamelyik kiköt?jéb?l
--indult már útra az SC Bella nev? hajó! Egy helység csak egyszer szerepeljen
SELECT DISTINCT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON h.hajo_id=u.hajo
INNER JOIN hajo.s_kikoto k
    ON u.indulasi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
WHERE h.nev LIKE 'SC Bella';

--9.
--Listázza ki azokat a mmegrendeléseket (azonosító) amelyekért többet fizettek, mint a 2021. áprilisában leadott megrendelések
--Bármelyikéért. A fizetett összeget is tüntesse fel!
SELECT megrendeleS_id, fizetett_osszeg
FROM hajo.s_megrendeles
WHERE fizetett_osszeg > (
    SELECT MAX(fizetett_osszeg)
    FROM hajo.s_megrendeles
    WHERE TO_CHAR(megrendeles_datuma, 'yyyy.mm') LIKE '2021.04'
);

--10.
--Listázza ki azokat a megrendeléseknek az azonositóját amelyekben ugyanannyi konténer igényeltek, mint valamelyik 2021 feb. leadott megrendelésben! 
--A megrendelések azonositójuk mellet tüntesse fel az igényelt konténerek számát is.
SELECT megrendeles_id, igenyelt_kontenerszam
FROM hajo.s_megrendeles
WHERE igenyelt_kontenerszam IN (
    SELECT igenyelt_kontenerszam
    FROM hajo.s_megrendeles
    WHERE TO_CHAR(megrendeles_datuma, 'yyyy.mm') LIKE '2021.02'
);


--11
--Listázza ki azoknak a hajóknak a nevét, a maximális súlyterhelését, valamint a tipusának a nevét, amely egyetlen utat sem teljesített.
--A hajó nevét megadó oszlop neve a 'hajónév' a tipusnevét a 'tipusnév'.
SELECT h.nev Hajónév, h.max_sulyterheles, ht.nev Típusnév
FROM hajo.s_hajo h
INNER JOIN hajo.s_hajo_tipus ht
    ON h.hajo_tipus=ht.hajo_tipus_id
WHERE h.hajo_id NOT IN (
    SELECT DISTINCT hajo
    FROM hajo.s_ut
);

--12.
--Listázza ki azoknak az ügyfeleknek a teljes nevét és származási országát, akiknek nincs 1milliónál nagyobb érték? rendelése!
--Azok is szerepeljenek, akiknek nem ismerjük a származását. Rendezze az eredményt vezetéknév, azon belül keresztnév szerint
SELECT u.vezeteknev || ' ' || u.keresztnev Ugyfel_neve, h.orszag
FROM hajo.s_ugyfel u
LEFT JOIN hajo.s_helyseg h
    ON u.helyseg=h.helyseg_id
WHERE u.ugyfel_id NOT IN (
    SELECT DISTINCT ugyfel
    FROM hajo.s_megrendeles
    WHERE fizetett_osszeg > 1000000
)
ORDER BY u.vezeteknev, u.keresztnev;

--13
--Listázza ki ábécérendben azoknak a kiköt?knek az azonosítóját, amelyekbe vagy teljesített egy utat az It_Cat azonosítójú kiköt?b?l, vagy célpontja egy, az It_Cat
--azonosítój? kiköt?j? megrendelésnek!
SELECT indulasi_kikoto
FROM hajo.s_ut
WHERE erkezesi_kikoto LIKE 'It_Cat'
UNION
SELECT erkezesi_kikoto
FROM hajo.s_ut
WHERE indulasi_kikoto LIKE 'It_Cat'
ORDER BY indulasi_kikoto;

--14.
--Listázza ki ábécérendben azoknak a kiköt?knek az azonosítóját, melyekbe legalább egy hajó teljesített utat
--Az 'It_Cat' azonosítójú kiköt?b?l és célpontja legalább egy, az 'It_Cat' kiköt?b?l induló megrendelésnek. A kiköt? csak egyszer
--Szerepeljen a lekérdezésben.
SELECT indulasi_kikoto
FROM hajo.s_ut
WHERE erkezesi_kikoto LIKE 'It_Cat'
INTERSECT
SELECT erkezesi_kikoto
FROM hajo.s_ut
WHERE indulasi_kikoto LIKE 'It_Cat'
ORDER BY indulasi_kikoto;

--15. 
--Listázza ki ábécérendben azoknak a helységeknek az azonosítóját, országát és nevét, ahonnan származnak ügyfeleink, vagy ahol vannak kiköt?k!
--Egy helység csak egyszer szerepeljen az eredményben! A lista legyen országnév, azon belül helységnév szerint rendezett.
SELECT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_helyseg h
INNER JOIN hajo.s_ugyfel u
    ON u.helyseg=h.helyseg_id
UNION
SELECT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_helyseg h
INNER JOIN hajo.s_kikoto k
    ON h.helyseg_id=k.helyseg
ORDER BY orszag, helysegnev;

--16
--Listázza ki ábécérendben azoknak a kiköt?vel rendelkez? helységeknek az azonosítóját,
--országát és nevét, ahonnan legalább egy ügyfelünk is származik! 
--Egy helység csak egyszer szerepeljen az eredményben! 
--A lista legyen országnév, azon belül helységnév szerint rendezve!
SELECT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_helyseg h
INNER JOIN hajo.s_ugyfel u
    ON u.helyseg=h.helyseg_id
INTERSECT
SELECT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_helyseg h
INNER JOIN hajo.s_kikoto k
    ON h.helyseg_id=k.helyseg
ORDER BY orszag, helysegnev;

--19.
--Listázza ki növekv? sorrendben azoknak a megrendeléseknek az azonosítóját, amelyekért legalább kétmilliót fizetett
--Egy Yiorgos keresztnev? ügyfél, és még nem történt meg a szállításuk
SELECT *
FROM hajo.s_megrendeles m
INNER JOIN hajo.s_hozzarendel h
    ON m.megrendeles_id=h.megrendeles
INNER JOIN hajo.s_szallit s
    ON h.megrendeles=s.megrendeles
INNER JOIN hajo.s_ut u
    ON s.ut=u.ut_id
INNER JOIN hajo.s_ugyfel u
    ON u.ugyfel_id=m.ugyfel
WHERE u.keresztnev LIKE 'Yiorgos' AND u.erkezesi_ido IS NULL AND m.fizetett_osszeg >= 2000000;

--20
--Listázza ki azoknak a helységeknek az azonosítóját, 
--országát és nevét, amelyek lakossága meghaladja az egymillió f?t, és azokét is, 
--ahonnan származik 50 évesnél id?sebb ügyfelünk! 
--Egy helység csak egyszer szerepeljen az eredményben! A lista legyen országnév, azon belül helységnév szerint rendezve!
SELECT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_helyseg h
WHERE h.lakossag>10000000
UNION
SELECT h.helyseg_id, h.orszag, h.helysegnev
FROM hajo.s_helyseg h
INNER JOIN hajo.s_ugyfel u
    ON u.helyseg=h.helyseg_id
WHERE MONTHS_BETWEEN(SYSDATE, u.szul_dat)/12 > 50
ORDER BY orszag, helysegnev;

--22.
--Melyik három ország kiköt?jéb?l induló szállításokra adták le a legtöbb megrendelést?
--Az országnevek mellett tüntesse fel az onnan induló megrendelések számát is
SELECT h.orszag, COUNT(megrendeles_id) Rendeles_db
FROM hajo.s_megrendeles m
INNER JOIN hajo.s_kikoto k
    ON m.indulasi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
GROUP BY h.orszag
ORDER BY COUNT(megrendeles_id) DESC
FETCH FIRST 3 ROWS ONLY;

--24.
--Adja meg  a két legkevesebb utat teljseít? olyan hajó nevét ,amelyik legalább egy utat teljesített, és legjeljebb 10 konténert tud egyszerre szállítani.
--A hajók neve mellet tüntesse fel az általuk teljesített utak számát is.
SELECT h.nev, COUNT(u.ut_id) Utak_szama
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
WHERE h.max_kontener_dbszam <= 10
GROUP BY h.nev
ORDER BY COUNT(u.ut_id) ASC
FETCH FIRST 2 ROWS ONLY;

--25
--Listázza ki a tíz legtöbb igényelt konténert tartalmazó megrendelést leadó ügyfél teljes nevét, 
--a megrendelés azonosítóját és az igényelt konténerek számát!
SELECT u.vezeteknev || ' ' || u.keresztnev Ugyfel_neve, m.megrendeles_id, COUNT(h.kontener) Kontener_db
FROM hajo.s_megrendeles m
INNER JOIN hajo.s_hozzarendel h
    ON h.megrendeles=m.megrendeles_id
INNER JOIN hajo.s_ugyfel u
    ON m.ugyfel=u.ugyfel_id
GROUP BY u.vezeteknev || ' ' || u.keresztnev, m.megrendeles_id
ORDER BY COUNT(h.kontener) DESC
FETCH FIRST 10 ROWS ONLY;

--26
--Adja meg az SC Nina nev? hajóval megtett 3 leghosszabb ideig tartó út indulási és érkezési kiköt?jének az azonosítóját.
SELECT u.indulasi_kikoto, u.erkezesi_kikoto
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
WHERE h.nev LIKE 'SC Nina'
ORDER BY u.erkezesi_ido-u.indulasi_ido DESC
FETCH FIRST 3 ROWS ONLY;

--27
--Adja meg a három legtöbb utat teljesít? hajó nevét! A hajók neve mellett tüntesse fel az általuk teljesített utak számát is
SELECT h.nev, COUNT(u.ut_id) Ut_db
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
WHERE u.erkezesi_ido IS NOT NULL
GROUP BY h.nev
ORDER BY COUNT(u.ut_id) DESC
FETCH FIRST 3 ROWS ONLY;

--28
-- Az 'It Cat' azonosítójú kiköt?b?l induló utak közül melyik négyen szállították a legkevesebb konténert?
--Csak azokat az utakat vegye figyelembe, amelyeken legalább egy konténert szállítottak!
--Az utakat az azonosítójukkal adja meg, és tüntesse fel a szállított konténerek számát is!!
SELECT u.ut_id, COUNT(s.kontener) Kontener_db
FROM hajo.s_ut u
INNER JOIN hajo.s_szallit s
    ON u.ut_id=s.ut
WHERE u.indulasi_kikoto LIKE 'It_Cat'
GROUP BY u.ut_id
ORDER BY COUNT(s.kontener) ASC
FETCH FIRST 4 ROWS ONLY;

--29
--Adja meg a négy legtöbb rendelést leadó teljes nevét és a megrendelések számát
SELECT u.vezeteknev || ' ' || u.keresztnev Ugyfel_neve, COUNT(m.megrendeles_id) Megrendeles_db
FROM hajo.s_ugyfel u
INNER JOIN hajo.s_megrendeles m
    ON m.ugyfel=u.ugyfel_id
GROUP BY u.vezeteknev || ' ' || u.keresztnev
ORDER BY COUNT(m.megrendeles_id) DESC
FETCH FIRST 4 ROWS ONLY;

--31.
--Hozzon létre egy s_szemelyzet nevu tablat, amelyben a hajókon dolgozó személyzet adatai találhatóak. Minden szerel?nek van azonosítója
--Pontosan 10 karakteres sztring. Ez az els?dleges kulcs is. Vezeték és keresztneve mindkett? 50-50 karakteres sztring. Születési dátuma, egy telefonszáma
--(20 jegy? egész szám). És hogy melyik hajó személyzetéhez tartozik (max 10 karakteres sztring), és ezt egy hivatkozással az s_hajó táblára hozzuk létre.
--A telefonszámot legyen kötelez? megadni. Minden megszorítást nevezzen el
CREATE TABLE s_szemelyzet (
    azon CHAR(10),
    vezeteknev VARCHAR2(50),
    keresztnev VARCHAR2(50),
    szuletesi_datum DATE,
    telefonszam NUMBER(20) NOT NULL,
    hajo VARCHAR2(10),
    CONSTRAINT s_szemelyzet_pk PRIMARY KEY(azon),
    CONSTRAINT s_szemelyzet_fk FOREIGN KEY (hajo) REFERENCES s_hajo(nev)
);

--32
--Hozzon létre egy s_személyzet nev? táblát, amelyben a hajókon dolgozó személyzet adatai találhatóak!
--Minden szerel?nek van azonosítója, maximum öt jegy? egész szám, ez az els?dleges kulcs
--vezeték és keresztneve, mindkett? maximum negyven karakteres sztring
    --születési dátuma
    --e-mail címe (maximum 200 karakteres string)
    --hogy melyik hajó személyzetéhez tartozik (maximum 10 karakteres sztring), hivatkozással az s_hajó táblára
CREATE TABLE s_személyzet(
    azon NUMBER(5),
    vezeteknev VARCHAR2(40),
    keresztnev VARCHAR2(40),
    szuletesi_datum DATE,
    email VARCHAR2(200),
    hajo VARCHAR2(10),
    CONSTRAINT s_személyzet_pk PRIMARY KEY(azon),
    CONSTRAINT s_személyzet_fk FOREIGN KEY(hajo) REFERENCES s_hajo(nev)
);

--33
--Hozzon létre egy 's_kikoto_email' nev? táblát, amelyben a kiköt?k e-mail címét tároljuk! Legyen benne egy kikoto_id nev? oszlop
--(maximum 10 karakteres string), amely hivatkozik az s_kikoto táblára.
--Valamint egy email cím, ami egy maximum 200 karakteres string!
--Egy kiköt?nek több email címe lehet, ezért a tábla els?dleges kulcsát a két oszlop együttesen alkossa!
--Minden megszorítást nevezzen el!
CREATE TABLE s_kikoto_email(
    kikoto_id VARCHAR2(10),
    email VARCHAR2(200),
    CONSTRAINT s_kikoto_email_pk PRIMARY KEY(kikoto_id, email),
    CONSTRAINT s_kikoto_email_fk FOREIGN KEY (kikoto_id) REFERENCES s_kikoto(kikoto_id)
);

--35.
--Hozzon létre egy s_hajo_javitas táblát, ami a hajók javítási adatait tartalmazza! Legyen benne a javított hajó azonosítója, amely az s_hajó táblára hivatkozik, legfeljebb
--10 karakter hosszú sztring és ne legyen null. Javítás kezdete és vége_ dárumok. Javítás ára: egy legfeljebb 10 jegy? valós szám, két tizedesjeggyel, valamint a hiba
--leírása, 200 karakteres sztring (legfeljebb).
--A tábla els?dleges kulcsa és a javítás kezd?dátuma els?dlegesen alkossa. További megkötés, hogy a javítás vége csak a javítás kezdete
--nél kés?bbi dátum lehet.
CREATE TABLE s_hajo_javitas(
    hajo VARCHAR2(10) NOT NULL,
    javitas_kezdete DATE,
    javitas_vege DATE,
    javitas_ara NUMBER(10,2),
    hiba_leiras VARCHAR2(200),
    CONSTRAINT s_hajo_javitas_pk PRIMARY KEY (hajo, javitas_kezdete),
    CONSTRAINT s_hajo_javitas_fk FOREIGN KEY (hajo) REFERENCES s_hajo(nev),
    CONSTRAINT s_hajo_javitas_check CHECK (javitas_vege > javitas_kezdete)
);

--43
--Törölje az s_hajo és az s_hajo tipus táblákat! Vegye figyelembe az egyes táblákra hivatkozó küls? kulcsokat.
DROP TABLE s_hajo CASCADE CONSTRAINTS;
DROP TABLE s_hajo_tipus CASCADE CONSTRAINTS;

--42
-- A helységek lakossági adata nem fontos számunkra.
--Törölje az 's_helyseg' tábla 'lakossag' oszlopát! 
ALTER TABLE s_helyseg DROP COLUMN lakossag;

--44
--Törölje az 's_kikoto_telefon' tábla els?dleges kulcs megszorítását!
ALTER TABLE s_kikoto_telefon DROP CONSTRAINT s_kikoto_telefon_pk;

--49.
--az s_kiköt? telefon táblát egy email nev?, amx 200 karakter hosszú sztringel, melyben alapértelmezetten a 'nem ismert' sztring legyen
ALTER TABLE s_kikoto_telefon ADD email VARCHAR2(200) DEFAULT 'nem ismert';

--50.
--Módosítsa az s_ugyfel tábla email oszlopának maximális hosszát 50 karakterre, az utca_hsz oszlop hosszát pedig 100 karakterre!
ALTER TABLE s_ugyfel MODIFY email VARCHAR2(50);
ALTER TABLE s_ugyfel MODIFY utca_hsz VARCHAR2(100);

--53
--Szúrja be a hajó sémából a saját sémájának s_ugyfel táblájába az olaszországi ügyfeleket!
INSERT INTO s_ugyfel
SELECT *
FROM hajo.s_ugyfel
WHERE ugyfel_id IN (
    SELECT ugyfel_id
    FROM hajo.s_ugyfel u
    LEFT JOIN hajo.s_helyseg h
        ON u.helyseg=h.helyseg_id
    WHERE h.orszag LIKE 'Olaszország'
);

--54
--Szúrja be a gajó sémából a saját sémájának s:hajó táblájába a small feeder tipusú hajók közül azokat,
--amelyeknek nettó súlya legalább 250 tonna
INSERT INTO s_hajo
SELECT *
FROM hajo.s_hajo
WHERE hajo_id IN (
    SELECT hajo_id
    FROM hajo.s_hajo h
    INNER JOIN hajo.s_hajo_tipus ht
        ON h.hajo_tipus=ht.hajo_tipus_id
        WHERE ht.nev LIKE 'Small feeder'
)
AND netto_suly >= 250;

--55.
--Szúrja be a 'hajó' sémából a saját sémájának s_hajo táblájába azokat a 'Small Feeder"' típusú hjaókat, amelyek legfeljebb 10 konténert
--tudnak szállítani egyszerre;
INSERT INTO s_hajo
SELECT *
FROM hajo.s_hajo
WHERE hajo_id IN (
    SELECT hajo_id
    FROM hajo.s_hajo h
    INNER JOIN hajo.s_hajo_tipus ht
        ON h.hajo_tipus=ht.hajo_tipus_id
        WHERE ht.nev LIKE 'Small feeder'
)
AND max_kontener_dbszam <= 10;

--57
--Törölje a szárazdokkal rendelkez? olaszországi és ibériai kiköt?ket! Azok a kiköt?k rendelkeznek szárazdokkal, amelyeknek a leírásában
--szerepel a szárazdokk szó.
DELETE FROM s_kikoto
WHERE kikoto_id IN (
    SELECT k.kikoto_id
    FROM hajo.s_kikoto k
    INNER JOIN hajo.s_helyseg h
        ON k.helyseg=h.helyseg_id
    WHERE leiras LIKE '%szárazdokk%' AND h.orszag IN ('Olaszország','Spanyolország','Portugália')
);

--59.
--Törölje azokata 2021 jún. induló utakat,amelyek 20 nál kevesebb konténert szállított a hajó.
DELETE FROM s_ut
WHERE ut_id IN (
    SELECT u.ut_id
    FROM hajo.s_ut u
    INNER JOIN hajo.s_szallit s
        ON u.ut_id=s.ut
    WHERE TO_CHAR(u.erkezesi_ido, 'yyyy.mm') LIKE '2021.06'
    HAVING COUNT(s.kontener) < 20
    GROUP BY u.ut_id
);

--61
--Módosítsa a nagy terminálterülettel rendelkez? kiköt?k leírását úgy, 
--hogy az az elején tar- talmazza a kiköt? helységét is, 
--amelyet egy vessz?vel és egy sz?közzel válasszon el a leírás jelenlegi tartalmától! 
--A nagy terminálterülettel rendelkez? kiköt?k leírásában szerepel a 'terminálterület: nagy, sztring. 
--(Figyeljen a vessz?re, a nagyon nagy" terület? kiköt?ket nem szeretnénk módosítani!) 
UPDATE s_kikoto k
SET leiras = (
    SELECT h.helysegnev || ', ' || k.leiras
    FROM hajo.s_helyseg h
    WHERE k.helyseg=h.helyseg_id
)
WHERE leiras LIKE  '%terminálterület: nagy,%';

--62
--Alakítsa csuba nagybet?ssé azon ügyfelek vezetéknevét, akik eddig a legtöbbet fizették összesen a megrendeléseikért
UPDATE s_ugyfel
SET vezeteknev = UPPER(vezeteknev)
WHERE ugyfel_id IN (
    SELECT ugyfel_id
    FROM hajo.s_ugyfel u
    INNER JOIN hajo.s_megrendeles m
        ON u.ugyfel_id=m.ugyfel
    WHERE fizetett_osszeg= (
        SELECT MAX(fizetett_osszeg)
        FROM hajo.s_megrendeles
));

--67.
--A francia kereskedelmi jogszabályoknak nemrég bevezetett változások jelent?s költségnövekedést okoztak a cégünk számára a francia 
--megrendelések leszállítását illet?en. Növelje meg 15%-al a franciaországból származó ügyfeleink utolsó megrendeléseiért fizetett összeget
UPDATE s_megrendeles
SET fizetett_osszeg = fizetett_osszeg *1.15
WHERE megrendeles_id IN (
    SELECT max(megrendeles_id)
    FROM hajo.s_megrendeles m
    INNER JOIN hajo.s_ugyfel u
        ON m.ugyfel=u.ugyfel_id
    INNER JOIN hajo.s_helyseg h
        ON u.helyseg=h.helyseg_id
    WHERE h.orszag LIKE 'Franciaország'
    GROUP BY ugyfel_id
);

--68
--A népességi adataink elavultak. 
--A frissítésük egyik lépéseként növelje meg 5%-kal az ázsiai országok településeinek lakosságát! 
UPDATE s_helyseg
SET lakossag = lakossag * 1.05
WHERE helyseg_id IN (
    SELECT helyseg_id
    FROM hajo.s_orszag o
    INNER JOIN hajo.s_helyseg h
        ON h.orszag=o.orszag
    WHERE o.foldresz LIKE 'Ázsia'
);

--69
--Egy pusztító vírus szedte áldozatait Afrika nagyvárosaiban. Felezze meg azon afrikai települések lakosságát, amelyeknek aktuális
--lakossága meghaladja a félmillió f?t!
UPDATE s_helyseg
SET lakossag = lakossag/2
WHERE helyseg_id IN (
    SELECT helyseg_id
    FROM hajo.s_orszag o
    INNER JOIN hajo.s_helyseg h
        ON h.orszag=o.orszag
    WHERE o.foldresz LIKE 'Afrika' AND h.lakossag > 500000
);

--70.
--Cégünk adminisztrátora elkövetett egy nagy hibát. A 2021 júliusában Algeciras kiköt?jéb?l induló utakat tévesen
--Vitte be az adatbázisba, mintha azok Valenciából indultak volna. Valóban Valenciából egyetlen út sem indult a kérdéses id?pontban
--Korrigálja az adminisztrátor hibáját! Az egyszer?ség kedvéért feltételezzük, hogy 1-1 ilyen város létezik, egy kiköt?vel
UPDATE s_ut
SET indulasi_kikoto = (
    SELECT kikoto_id
    FROM hajo.s_kikoto k
    INNER JOIN hajo.s_helyseg h
        ON k.helyseg=h.helyseg_id
    WHERE h.helysegnev LIKE 'Algeciras')
WHERE ut_id IN (
    SELECT ut_id
    FROM hajo.s_ut u
    INNER JOIN hajo.s_kikoto k
        ON u.indulasi_kikoto=k.kikoto_id
    INNER JOIN hajo.s_helyseg h
        ON k.helyseg=h.helyseg_id
    WHERE TO_CHAR(u.indulasi_ido, 'yyyy.mm') LIKE '2021.07' AND h.helysegnev LIKE 'Valencia'
);

--71.
--Hozzon létre nézetet, amely listázza az utak minden attribútumát, kiegészítve az indulási és érkezési kiköt? helység és országnevével.
CREATE VIEW utvarosorszag AS
SELECT u.ut_id, u.indulasi_ido, u.erkezesi_ido, u.indulasi_kikoto, u.erkezesi_kikoto, u.hajo, 
    h1.helysegnev Indulasi_helyseg, h1.orszag Indulasi_orszag, h2.helysegnev Erkezesi_helyseg, h2.orszag Erkezesi_orszag
FROM hajo.s_ut u
INNER JOIN hajo.s_kikoto k1
    ON u.indulasi_kikoto=k1.kikoto_id
INNER JOIN hajo.s_kikoto k2
    ON u.erkezesi_kikoto=k2.kikoto_id
INNER JOIN hajo.s_helyseg h1
    ON k1.helyseg=h1.helyseg_id
INNER JOIN hajo.s_helyseg h2
    ON k2.helyseg=h2.helyseg_id;

--74. Hozzon létre nézetet, amely listázza a megrendelések összes attribútumát, kiegészítve az indulási és érkezési kiköt?
--helységnevével és országával
CREATE VIEW megrendelesvarosorszag AS
SELECT m.*, h1.helysegnev Indulasi_helyseg, h1.orszag Indulasi_orszag, h2.helysegnev Erkezesi_helyseg, h2.orszag Erkezesi_orszag
FROM hajo.s_megrendeles m
INNER JOIN hajo.s_kikoto k1
    ON m.indulasi_kikoto=k1.kikoto_id
INNER JOIN hajo.s_kikoto k2
    ON m.erkezesi_kikoto=k2.kikoto_id
INNER JOIN hajo.s_helyseg h1
    ON k1.helyseg=h1.helyseg_id
INNER JOIN hajo.s_helyseg h2
    ON k2.helyseg=h2.helyseg_id;

--75
--Hozzon létre nézetet, amely listázza, hogy az egyes hajótípusokhoz tartozó hajók összesen hány utat teljesítettek! 
--A listában szerepeljen a hajótípusok azonosítója, neve és a teljesített utak száma! 
--Azokat a hajótípusokat is tüntesse fel az eredményben, amelyekhez egyetlen hajó sem tartozik, 
--és azokat is, amelyekhez tartozó hajók egyetlen utat sem teljesítettek! 
--A lista legyen a hajótípus neve szerint rendezett!
CREATE VIEW hajotipusutak AS
SELECT ht.hajo_tipus_id, ht.nev, COUNT(u.ut_id) Ut_db
FROM hajo.s_hajo_tipus ht
LEFT JOIN hajo.s_hajo h
    ON ht.hajo_tipus_id=h.hajo_tipus
LEFT JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
GROUP BY ht.hajo_tipus_id, ht.nev
ORDER BY ht.nev;

--76.
--Hozzon létre nézetet, amely listázza, hogy az egyes kiköt?knek hány telefonszáma van. A lista tartalmazza a kiköt?k azonosítóját,
--a helység nevét és oszágát és a telefonok számát. Azokat is tüntessük fel, aminek nincs telefonszáma
CREATE VIEW kikototelefon AS
SELECT k.kikoto_id, h.helysegnev, h.orszag, COUNT(kt.telefon) Telefon_db
FROM hajo.s_kikoto k
LEFT JOIN hajo.s_kikoto_telefon kt
    ON kt.kikoto_id=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
GROUP BY k.kikoto_id, h.helysegnev, h.orszag;

--78.
--Hozzon létre nézetet, amely listázza, hogy az egyes kiköt?kre hány út vezetett: kiköt?k azonosítója, helységük neve, országa, utak száma
--Azokat is tüntessük fel, ahova egyetlen út sem vezetett!
CREATE VIEW utakszama AS
SELECT k.kikoto_id, h.helysegnev, COUNT(u.ut_id) Ut_db
FROM hajo.s_kikoto k
LEFT JOIN hajo.s_ut u
    ON u.erkezesi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
GROUP BY k.kikoto_id, h.helysegnev;

--80
--Egy nézetet, amely kilistázza, hogy az egyes kiköt?k hány megrendelésben szerepeltek célpontként! A lista tartalmazza kiköt?k id-jét, helységek
--nevét és országát és a megrendelések számát
CREATE VIEW megrendelescelpont AS
SELECT k.kikoto_id, h.helysegnev, h.orszag, COUNT(m.megrendeles_id) Megrendeles_db
FROM hajo.s_kikoto k
LEFT JOIN hajo.s_megrendeles m
    ON k.kikoto_id=m.erkezesi_kikoto
INNER JOIN hajo.s_helyseg h
    ON h.helyseg_id=k.helyseg
GROUP BY k.kikoto_id, h.helysegnev, h.orszag;

--81. 
--Hozzon létre nézetet, amely megadja a legnagyobb forgalmú kiköt?(k) azonosítóját, helységnevét és országát! A legnagyobb
--forgalmú kiköt? az, amelyik a legtöbb út indulási vagy érkezési kiköt?je volt.
CREATE VIEW forgalmaskikoto AS
SELECT kikoto_id, h.helysegnev, h.orszag
FROM (
    SELECT u.indulasi_kikoto AS kikoto_id, COUNT(*) AS utak_szama, k.helyseg
    FROM hajo.s_ut u
    INNER JOIN hajo.s_kikoto k
        ON u.indulasi_kikoto=k.kikoto_id
    GROUP BY u.indulasi_kikoto, k.helyseg
    UNION ALL
    SELECT u.erkezesi_kikoto AS kikoto_id, COUNT(*) AS utak_szama, k.helyseg
    FROM hajo.s_ut u
    INNER JOIN hajo.s_kikoto k
        ON u.erkezesi_kikoto=k.kikoto_id
    GROUP BY u.erkezesi_kikoto, k.helyseg
)
INNER JOIN hajo.s_helyseg h
    ON helyseg=h.helyseg_id
GROUP BY kikoto_id, h.helysegnev, h.orszag
ORDER BY SUM(utak_szama) DESC
FETCH FIRST ROW WITH TIES;

--82
--Hozzon létre nézetet, amely megadja annak a hajónak az azonosítóját és nevét, 
--amelyik a legnagyobb összsúlyt szállította a 2021 májusában induló utakon! 
--Ha több ilyen hajó is van, akkor mindegyiket listázza!
CREATE VIEW maxsuly AS
SELECT h.hajo_id, h.nev, sum(ho.rakomanysuly) Osszsuly
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
INNER JOIN hajo.s_szallit s
    ON s.ut=u.ut_id
INNER JOIN hajo.s_hozzarendel ho
    ON ho.megrendeles=s.megrendeles AND ho.kontener=s.kontener
WHERE TO_CHAR(indulasi_ido, 'yyyy.mm') LIKE '2021.05'
GROUP BY h.hajo_id, h.nev
ORDER BY Osszsuly DESC
FETCH FIRST ROW WITH TIES;

--83
--Hozzon létre nézetet, ami megadja a kiköt? azonosítóját, helységnevét, országát, amelykb?l kiinduló utakon
--szállított konténerek összesúlya  a legnagyobb. Ha több ilyen van, akkor mindegyiket listázza
CREATE VIEW maxosszsulyak AS
SELECT k.kikoto_id, h.helysegnev, h.orszag, sum(hr.rakomanysuly) Osszrakomany
FROM hajo.s_kikoto k
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
INNER JOIN hajo.s_ut u
    ON u.indulasi_kikoto=k.kikoto_id
INNER JOIN hajo.s_szallit s
    ON s.ut=u.ut_id
INNER JOIN hajo.s_hozzarendel hr
    ON hr.megrendeles=s.megrendeles AND hr.kontener=s.kontener
GROUP BY k.kikoto_id, h.helysegnev, h.orszag
ORDER BY Osszrakomany DESC
FETCH FIRST 1 ROW WITH TIES;

--84.
--Hozzon létre nézetet, amely megadja annak a kiköt?nek az azonosítóját, helységnevét, és országát, ameylikbe tartó utakon
--szállított konténerek összsúlya a legnagyobb. 
CREATE VIEW maxerkezes AS
SELECT k.kikoto_id, h.helysegnev, h.orszag, sum(hr.rakomanysuly) Osszrakomany
FROM hajo.s_kikoto k
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
INNER JOIN hajo.s_ut u
    ON u.erkezesi_kikoto=k.kikoto_id
INNER JOIN hajo.s_szallit s
    ON s.ut=u.ut_id
INNER JOIN hajo.s_hozzarendel hr
    ON hr.megrendeles=s.megrendeles AND hr.kontener=s.kontener
GROUP BY k.kikoto_id, h.helysegnev, h.orszag
ORDER BY Osszrakomany DESC
FETCH FIRST 1 ROW WITH TIES;

--85.
--Hozzon létre nézetet amely megadja azoknak az utaknak az adatait, amelyeken a rakomány súlya (a szállított konténerek és a
--rakományaik összsúlya) meghaladja  a hajó maximális súlyterhelését! Az út adatai mellett tüntesse fel a hajó nevét és maximális súlyterhelését
--Valamint a rakomány súlyát is
CREATE VIEW tulsuly AS
SELECT u.ut_id, h.hajo_id, h.nev, SUM(hr.rakomanysuly) Osszsuly, h.max_sulyterheles
FROM hajo.s_ut u
INNER JOIN hajo.s_hajo h
    ON u.hajo=h.hajo_id
INNER JOIN hajo.s_szallit s
    ON s.ut=u.ut_id
INNER JOIN hajo.s_hozzarendel hr
    ON hr.megrendeles=s.megrendeles AND hr.kontener=s.kontener
GROUP BY hr.megrendeles,u.ut_id, h.hajo_id, h.nev, h.max_sulyterheles
HAVING SUM(hr.rakomanysuly)>h.max_sulyterheles;

--86. 
--Hozzon létre nézetet amely megadja azoknak az utaknak az adatait, amelyeken a rakomány súlya (a szállított konténerek és a
--rakományaik összsúlya) nem haladja meg a hajó maximális súlyterhelésének a felét! Az út adatai mellett tüntesse fel a hajó nevét és maximális súlyterhelését
--Valamint a rakomány súlyát is
CREATE VIEW kevessuly AS
SELECT u.ut_id, h.hajo_id, h.nev, SUM(hr.rakomanysuly) Osszsuly, h.max_sulyterheles
FROM hajo.s_ut u
INNER JOIN hajo.s_hajo h
    ON u.hajo=h.hajo_id
INNER JOIN hajo.s_szallit s
    ON s.ut=u.ut_id
INNER JOIN hajo.s_hozzarendel hr
    ON hr.megrendeles=s.megrendeles AND hr.kontener=s.kontener
GROUP BY hr.megrendeles,u.ut_id, h.hajo_id, h.nev, h.max_sulyterheles
HAVING SUM(hr.rakomanysuly)<h.max_sulyterheles/2;

--88.
--Hozzon létre nézetet, amely megadja annak a megrendelésnek az adatait, amelynek a teljesítéséhez a legtöbb útra volt szükség! Ha több
--Ilyen megrendelés is van, akkor mindegyiket listázza!
CREATE VIEW hosszuteljesites AS
SELECT DISTINCT m.*
FROM hajo.s_megrendeles m
INNER JOIN hajo.s_szallit s
    ON s.megrendeles=m.megrendeles_id
INNER JOIN hajo.s_ut u
    ON u.ut_id=s.ut
WHERE erkezesi_ido-indulasi_ido = (
    SELECT MAX(erkezesi_ido-indulasi_ido)
    FROM hajo.s_ut
);

--92.
--Adjon hivatkozási jogosultságot panovicsnak az ön s_ut táblájának indulasi_ido és hajo oszlopaiba
GRANT REFERENCES(indulasi_ido, hajo) ON s_ut TO panovics;

--94
--Adjon módosítási jogosultságot a 'panovics' felhasználónak az ön s_ugyfel táblájának vezeték és keresztnév oszlopaira
GRANT UPDATE(vezeteknev, keresztnev) ON s_ugyfel TO panovics;

--95
--Adjon beszúrási jogosultságot minden felhasználónak 
--az ön 's_kikoto' táblájának a 'kikoto_id' és 'helyseg' oszlopaira!
GRANT INSERT(kikoto_id, helyseg) ON s_kikoto TO PUBLIC;

--96
--Vonja vissza a lekérdezési jogosultságot a 'panovics' felhasználótól az ön s_ut táblájából
REVOKE SELECT ON s_ut FROM panovics;

--98
--Vonja vissza a törlési és módosítási jogosultságot a 'panovics' nev? felhasználótól az ön s_kikoto táblájáról
REVOKE DELETE, UPDATE ON s_kikoto FROM panovics;

--99
--Vonja vissza a törlési jogot 'panovics' felhasználótól az ön s_orszag táblájáról
REVOKE DELETE ON s_orszag FROM panovics;

--100
--Vonja vissza a beszúrási jogosultságot minden felhasználótól az ön s_megrendelés táblájáról
REVOKE INSERT on s_megrendeles FROM public;