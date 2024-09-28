--select feladatok from buvesz :*
--1
--List�zza ki az �gyfelek azonos�t�j�t, teljes nev�t, valamint a megrendel�seik azonos�t�j�t! Azok az �gyfelek is szerepeljenek az eredm�nyben,
--akik soha nem adtak le megrendel�seket. A lista legyen vezet�kn�v, azon bel�l megrendel�s azonos�t�ja szerint rendezve
SELECT u.ugyfel_id, u.vezeteknev, u.keresztnev, m.megrendeles_id
FROM hajo.s_ugyfel u
LEFT JOIN hajo.s_megrendeles m
    ON u.ugyfel_id=m.ugyfel
ORDER BY u.vezeteknev, u.ugyfel_id;

--2.
--List�zza ki a haj�t�pusok azonos�t�j�t �s nev�t, valamint az adott t�pus� haj�k azonos�t�j�t �s nev�t! A haj�t�pusok nev�t tartalmaz� oszlop
--'t�pusn�v', a haj�k nev�t tartalmaz� oszlop pedig 'haj�n�v' legyen! Azok a haj�t�pusok is jelenjenek meg, amelyhez egyetlen haj� sem tartzoik.
--A lista legyen a haj�t�pus neve, azon bel�l a haj� neve alapj�n rendezve.
SELECT ht.hajo_tipus_id, ht.nev T�pusn�v, h.nev Haj�n�v, h.nev
FROM hajo.s_hajo_tipus ht
LEFT JOIN hajo.s_hajo h
    ON ht.hajo_tipus_id=h.hajo_tipus
ORDER BY T�pusn�v, Haj�n�v;

select * from hajo.s_hozzarendel;
--5.
--List�zza ki Magyarorsz�g�n�l kisebb lakoss�ggal rendelkez? orsz�gok nev�t, lakoss�g�t, valamint a f?v�rosuk nev�t. Azokat az orsz�gokat is
--list�zza, amelyeknek nem ismerj�k a f?v�ros�t. Ezen orsz�gok eset�ben a f?v�ros hely�n "nem ismert" sztring szerepeljen. Rendezze az orsz�gokat
--a lakoss�g szerint cs�kken? sorrendben.
SELECT o.orszag, o.lakossag, NVL(h.helysegnev, 'nem ismert') Fovaros
FROM hajo.s_orszag o
LEFT JOIN hajo.s_helyseg h
    ON o.fovaros=h.helyseg_id
WHERE o.lakossag < (
    SELECT lakossag
    FROM hajo.s_orszag
    WHERE orszag LIKE 'Magyarorsz�g'
)
ORDER BY o.lakossag DESC;

--6 
--List�zza ki azoknak az �gyfeleknek az azonos�t�j�t �s teljes nev�t,
--akik adtak m�r fel olasz- orsz�gi kik�t?b?l indul� sz�ll�t�sra vonatkoz� megrendel�st! 
--Egy �gyf�l csak egyszer szere- peljen az eredm�nyben!
SELECT DISTINCT u.ugyfel_id, u.vezeteknev || ' ' || u.keresztnev Ugyfel_nev
FROM hajo.s_ugyfel u
INNER JOIN hajo.s_megrendeles m
ON u.ugyfel_id=m.ugyfel
INNER JOIN hajo.s_kikoto k
    ON m.indulasi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
WHERE h.orszag LIKE 'Olaszorsz�g';

--7
--List�zza ki azoknak a haj�knak az azonos�t�j�t �s nev�t, amelyek egyetlen �t c�l�llom�sak�nt sem k�t�ttek ki francia kik�t?kben
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
WHERE h.orszag LIKE 'Franciaorsz�g'
);


--8.
--List�zza ki azoknak a helys�geknek az azonos�t�j�t, orsz�g�t �s nev�t, amelyeknek valamelyik kik�t?j�b?l
--indult m�r �tra az SC Bella nev? haj�! Egy helys�g csak egyszer szerepeljen
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
--List�zza ki azokat a mmegrendel�seket (azonos�t�) amelyek�rt t�bbet fizettek, mint a 2021. �prilis�ban leadott megrendel�sek
--B�rmelyik��rt. A fizetett �sszeget is t�ntesse fel!
SELECT megrendeleS_id, fizetett_osszeg
FROM hajo.s_megrendeles
WHERE fizetett_osszeg > (
    SELECT MAX(fizetett_osszeg)
    FROM hajo.s_megrendeles
    WHERE TO_CHAR(megrendeles_datuma, 'yyyy.mm') LIKE '2021.04'
);

--10.
--List�zza ki azokat a megrendel�seknek az azonosit�j�t amelyekben ugyanannyi kont�ner ig�nyeltek, mint valamelyik 2021 feb. leadott megrendel�sben! 
--A megrendel�sek azonosit�juk mellet t�ntesse fel az ig�nyelt kont�nerek sz�m�t is.
SELECT megrendeles_id, igenyelt_kontenerszam
FROM hajo.s_megrendeles
WHERE igenyelt_kontenerszam IN (
    SELECT igenyelt_kontenerszam
    FROM hajo.s_megrendeles
    WHERE TO_CHAR(megrendeles_datuma, 'yyyy.mm') LIKE '2021.02'
);


--11
--List�zza ki azoknak a haj�knak a nev�t, a maxim�lis s�lyterhel�s�t, valamint a tipus�nak a nev�t, amely egyetlen utat sem teljes�tett.
--A haj� nev�t megad� oszlop neve a 'haj�n�v' a tipusnev�t a 'tipusn�v'.
SELECT h.nev Haj�n�v, h.max_sulyterheles, ht.nev T�pusn�v
FROM hajo.s_hajo h
INNER JOIN hajo.s_hajo_tipus ht
    ON h.hajo_tipus=ht.hajo_tipus_id
WHERE h.hajo_id NOT IN (
    SELECT DISTINCT hajo
    FROM hajo.s_ut
);

--12.
--List�zza ki azoknak az �gyfeleknek a teljes nev�t �s sz�rmaz�si orsz�g�t, akiknek nincs 1milli�n�l nagyobb �rt�k? rendel�se!
--Azok is szerepeljenek, akiknek nem ismerj�k a sz�rmaz�s�t. Rendezze az eredm�nyt vezet�kn�v, azon bel�l keresztn�v szerint
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
--List�zza ki �b�c�rendben azoknak a kik�t?knek az azonos�t�j�t, amelyekbe vagy teljes�tett egy utat az It_Cat azonos�t�j� kik�t?b?l, vagy c�lpontja egy, az It_Cat
--azonos�t�j? kik�t?j? megrendel�snek!
SELECT indulasi_kikoto
FROM hajo.s_ut
WHERE erkezesi_kikoto LIKE 'It_Cat'
UNION
SELECT erkezesi_kikoto
FROM hajo.s_ut
WHERE indulasi_kikoto LIKE 'It_Cat'
ORDER BY indulasi_kikoto;

--14.
--List�zza ki �b�c�rendben azoknak a kik�t?knek az azonos�t�j�t, melyekbe legal�bb egy haj� teljes�tett utat
--Az 'It_Cat' azonos�t�j� kik�t?b?l �s c�lpontja legal�bb egy, az 'It_Cat' kik�t?b?l indul� megrendel�snek. A kik�t? csak egyszer
--Szerepeljen a lek�rdez�sben.
SELECT indulasi_kikoto
FROM hajo.s_ut
WHERE erkezesi_kikoto LIKE 'It_Cat'
INTERSECT
SELECT erkezesi_kikoto
FROM hajo.s_ut
WHERE indulasi_kikoto LIKE 'It_Cat'
ORDER BY indulasi_kikoto;

--15. 
--List�zza ki �b�c�rendben azoknak a helys�geknek az azonos�t�j�t, orsz�g�t �s nev�t, ahonnan sz�rmaznak �gyfeleink, vagy ahol vannak kik�t?k!
--Egy helys�g csak egyszer szerepeljen az eredm�nyben! A lista legyen orsz�gn�v, azon bel�l helys�gn�v szerint rendezett.
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
--List�zza ki �b�c�rendben azoknak a kik�t?vel rendelkez? helys�geknek az azonos�t�j�t,
--orsz�g�t �s nev�t, ahonnan legal�bb egy �gyfel�nk is sz�rmazik! 
--Egy helys�g csak egyszer szerepeljen az eredm�nyben! 
--A lista legyen orsz�gn�v, azon bel�l helys�gn�v szerint rendezve!
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
--List�zza ki n�vekv? sorrendben azoknak a megrendel�seknek az azonos�t�j�t, amelyek�rt legal�bb k�tmilli�t fizetett
--Egy Yiorgos keresztnev? �gyf�l, �s m�g nem t�rt�nt meg a sz�ll�t�suk
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
--List�zza ki azoknak a helys�geknek az azonos�t�j�t, 
--orsz�g�t �s nev�t, amelyek lakoss�ga meghaladja az egymilli� f?t, �s azok�t is, 
--ahonnan sz�rmazik 50 �vesn�l id?sebb �gyfel�nk! 
--Egy helys�g csak egyszer szerepeljen az eredm�nyben! A lista legyen orsz�gn�v, azon bel�l helys�gn�v szerint rendezve!
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
--Melyik h�rom orsz�g kik�t?j�b?l indul� sz�ll�t�sokra adt�k le a legt�bb megrendel�st?
--Az orsz�gnevek mellett t�ntesse fel az onnan indul� megrendel�sek sz�m�t is
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
--Adja meg  a k�t legkevesebb utat teljse�t? olyan haj� nev�t ,amelyik legal�bb egy utat teljes�tett, �s legjeljebb 10 kont�nert tud egyszerre sz�ll�tani.
--A haj�k neve mellet t�ntesse fel az �ltaluk teljes�tett utak sz�m�t is.
SELECT h.nev, COUNT(u.ut_id) Utak_szama
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
WHERE h.max_kontener_dbszam <= 10
GROUP BY h.nev
ORDER BY COUNT(u.ut_id) ASC
FETCH FIRST 2 ROWS ONLY;

--25
--List�zza ki a t�z legt�bb ig�nyelt kont�nert tartalmaz� megrendel�st lead� �gyf�l teljes nev�t, 
--a megrendel�s azonos�t�j�t �s az ig�nyelt kont�nerek sz�m�t!
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
--Adja meg az SC Nina nev? haj�val megtett 3 leghosszabb ideig tart� �t indul�si �s �rkez�si kik�t?j�nek az azonos�t�j�t.
SELECT u.indulasi_kikoto, u.erkezesi_kikoto
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
WHERE h.nev LIKE 'SC Nina'
ORDER BY u.erkezesi_ido-u.indulasi_ido DESC
FETCH FIRST 3 ROWS ONLY;

--27
--Adja meg a h�rom legt�bb utat teljes�t? haj� nev�t! A haj�k neve mellett t�ntesse fel az �ltaluk teljes�tett utak sz�m�t is
SELECT h.nev, COUNT(u.ut_id) Ut_db
FROM hajo.s_hajo h
INNER JOIN hajo.s_ut u
    ON u.hajo=h.hajo_id
WHERE u.erkezesi_ido IS NOT NULL
GROUP BY h.nev
ORDER BY COUNT(u.ut_id) DESC
FETCH FIRST 3 ROWS ONLY;

--28
-- Az 'It Cat' azonos�t�j� kik�t?b?l indul� utak k�z�l melyik n�gyen sz�ll�tott�k a legkevesebb kont�nert?
--Csak azokat az utakat vegye figyelembe, amelyeken legal�bb egy kont�nert sz�ll�tottak!
--Az utakat az azonos�t�jukkal adja meg, �s t�ntesse fel a sz�ll�tott kont�nerek sz�m�t is!!
SELECT u.ut_id, COUNT(s.kontener) Kontener_db
FROM hajo.s_ut u
INNER JOIN hajo.s_szallit s
    ON u.ut_id=s.ut
WHERE u.indulasi_kikoto LIKE 'It_Cat'
GROUP BY u.ut_id
ORDER BY COUNT(s.kontener) ASC
FETCH FIRST 4 ROWS ONLY;

--29
--Adja meg a n�gy legt�bb rendel�st lead� teljes nev�t �s a megrendel�sek sz�m�t
SELECT u.vezeteknev || ' ' || u.keresztnev Ugyfel_neve, COUNT(m.megrendeles_id) Megrendeles_db
FROM hajo.s_ugyfel u
INNER JOIN hajo.s_megrendeles m
    ON m.ugyfel=u.ugyfel_id
GROUP BY u.vezeteknev || ' ' || u.keresztnev
ORDER BY COUNT(m.megrendeles_id) DESC
FETCH FIRST 4 ROWS ONLY;

--31.
--Hozzon l�tre egy s_szemelyzet nevu tablat, amelyben a haj�kon dolgoz� szem�lyzet adatai tal�lhat�ak. Minden szerel?nek van azonos�t�ja
--Pontosan 10 karakteres sztring. Ez az els?dleges kulcs is. Vezet�k �s keresztneve mindkett? 50-50 karakteres sztring. Sz�let�si d�tuma, egy telefonsz�ma
--(20 jegy? eg�sz sz�m). �s hogy melyik haj� szem�lyzet�hez tartozik (max 10 karakteres sztring), �s ezt egy hivatkoz�ssal az s_haj� t�bl�ra hozzuk l�tre.
--A telefonsz�mot legyen k�telez? megadni. Minden megszor�t�st nevezzen el
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
--Hozzon l�tre egy s_szem�lyzet nev? t�bl�t, amelyben a haj�kon dolgoz� szem�lyzet adatai tal�lhat�ak!
--Minden szerel?nek van azonos�t�ja, maximum �t jegy? eg�sz sz�m, ez az els?dleges kulcs
--vezet�k �s keresztneve, mindkett? maximum negyven karakteres sztring
    --sz�let�si d�tuma
    --e-mail c�me (maximum 200 karakteres string)
    --hogy melyik haj� szem�lyzet�hez tartozik (maximum 10 karakteres sztring), hivatkoz�ssal az s_haj� t�bl�ra
CREATE TABLE s_szem�lyzet(
    azon NUMBER(5),
    vezeteknev VARCHAR2(40),
    keresztnev VARCHAR2(40),
    szuletesi_datum DATE,
    email VARCHAR2(200),
    hajo VARCHAR2(10),
    CONSTRAINT s_szem�lyzet_pk PRIMARY KEY(azon),
    CONSTRAINT s_szem�lyzet_fk FOREIGN KEY(hajo) REFERENCES s_hajo(nev)
);

--33
--Hozzon l�tre egy 's_kikoto_email' nev? t�bl�t, amelyben a kik�t?k e-mail c�m�t t�roljuk! Legyen benne egy kikoto_id nev? oszlop
--(maximum 10 karakteres string), amely hivatkozik az s_kikoto t�bl�ra.
--Valamint egy email c�m, ami egy maximum 200 karakteres string!
--Egy kik�t?nek t�bb email c�me lehet, ez�rt a t�bla els?dleges kulcs�t a k�t oszlop egy�ttesen alkossa!
--Minden megszor�t�st nevezzen el!
CREATE TABLE s_kikoto_email(
    kikoto_id VARCHAR2(10),
    email VARCHAR2(200),
    CONSTRAINT s_kikoto_email_pk PRIMARY KEY(kikoto_id, email),
    CONSTRAINT s_kikoto_email_fk FOREIGN KEY (kikoto_id) REFERENCES s_kikoto(kikoto_id)
);

--35.
--Hozzon l�tre egy s_hajo_javitas t�bl�t, ami a haj�k jav�t�si adatait tartalmazza! Legyen benne a jav�tott haj� azonos�t�ja, amely az s_haj� t�bl�ra hivatkozik, legfeljebb
--10 karakter hossz� sztring �s ne legyen null. Jav�t�s kezdete �s v�ge_ d�rumok. Jav�t�s �ra: egy legfeljebb 10 jegy? val�s sz�m, k�t tizedesjeggyel, valamint a hiba
--le�r�sa, 200 karakteres sztring (legfeljebb).
--A t�bla els?dleges kulcsa �s a jav�t�s kezd?d�tuma els?dlegesen alkossa. Tov�bbi megk�t�s, hogy a jav�t�s v�ge csak a jav�t�s kezdete
--n�l k�s?bbi d�tum lehet.
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
--T�r�lje az s_hajo �s az s_hajo tipus t�bl�kat! Vegye figyelembe az egyes t�bl�kra hivatkoz� k�ls? kulcsokat.
DROP TABLE s_hajo CASCADE CONSTRAINTS;
DROP TABLE s_hajo_tipus CASCADE CONSTRAINTS;

--42
-- A helys�gek lakoss�gi adata nem fontos sz�munkra.
--T�r�lje az 's_helyseg' t�bla 'lakossag' oszlop�t! 
ALTER TABLE s_helyseg DROP COLUMN lakossag;

--44
--T�r�lje az 's_kikoto_telefon' t�bla els?dleges kulcs megszor�t�s�t!
ALTER TABLE s_kikoto_telefon DROP CONSTRAINT s_kikoto_telefon_pk;

--49.
--az s_kik�t? telefon t�bl�t egy email nev?, amx 200 karakter hossz� sztringel, melyben alap�rtelmezetten a 'nem ismert' sztring legyen
ALTER TABLE s_kikoto_telefon ADD email VARCHAR2(200) DEFAULT 'nem ismert';

--50.
--M�dos�tsa az s_ugyfel t�bla email oszlop�nak maxim�lis hossz�t 50 karakterre, az utca_hsz oszlop hossz�t pedig 100 karakterre!
ALTER TABLE s_ugyfel MODIFY email VARCHAR2(50);
ALTER TABLE s_ugyfel MODIFY utca_hsz VARCHAR2(100);

--53
--Sz�rja be a haj� s�m�b�l a saj�t s�m�j�nak s_ugyfel t�bl�j�ba az olaszorsz�gi �gyfeleket!
INSERT INTO s_ugyfel
SELECT *
FROM hajo.s_ugyfel
WHERE ugyfel_id IN (
    SELECT ugyfel_id
    FROM hajo.s_ugyfel u
    LEFT JOIN hajo.s_helyseg h
        ON u.helyseg=h.helyseg_id
    WHERE h.orszag LIKE 'Olaszorsz�g'
);

--54
--Sz�rja be a gaj� s�m�b�l a saj�t s�m�j�nak s:haj� t�bl�j�ba a small feeder tipus� haj�k k�z�l azokat,
--amelyeknek nett� s�lya legal�bb 250 tonna
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
--Sz�rja be a 'haj�' s�m�b�l a saj�t s�m�j�nak s_hajo t�bl�j�ba azokat a 'Small Feeder"' t�pus� hja�kat, amelyek legfeljebb 10 kont�nert
--tudnak sz�ll�tani egyszerre;
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
--T�r�lje a sz�razdokkal rendelkez? olaszorsz�gi �s ib�riai kik�t?ket! Azok a kik�t?k rendelkeznek sz�razdokkal, amelyeknek a le�r�s�ban
--szerepel a sz�razdokk sz�.
DELETE FROM s_kikoto
WHERE kikoto_id IN (
    SELECT k.kikoto_id
    FROM hajo.s_kikoto k
    INNER JOIN hajo.s_helyseg h
        ON k.helyseg=h.helyseg_id
    WHERE leiras LIKE '%sz�razdokk%' AND h.orszag IN ('Olaszorsz�g','Spanyolorsz�g','Portug�lia')
);

--59.
--T�r�lje azokata 2021 j�n. indul� utakat,amelyek 20 n�l kevesebb kont�nert sz�ll�tott a haj�.
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
--M�dos�tsa a nagy termin�lter�lettel rendelkez? kik�t?k le�r�s�t �gy, 
--hogy az az elej�n tar- talmazza a kik�t? helys�g�t is, 
--amelyet egy vessz?vel �s egy sz?k�zzel v�lasszon el a le�r�s jelenlegi tartalm�t�l! 
--A nagy termin�lter�lettel rendelkez? kik�t?k le�r�s�ban szerepel a 'termin�lter�let: nagy, sztring. 
--(Figyeljen a vessz?re, a nagyon nagy" ter�let? kik�t?ket nem szeretn�nk m�dos�tani!) 
UPDATE s_kikoto k
SET leiras = (
    SELECT h.helysegnev || ', ' || k.leiras
    FROM hajo.s_helyseg h
    WHERE k.helyseg=h.helyseg_id
)
WHERE leiras LIKE  '%termin�lter�let: nagy,%';

--62
--Alak�tsa csuba nagybet?ss� azon �gyfelek vezet�knev�t, akik eddig a legt�bbet fizett�k �sszesen a megrendel�seik�rt
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
--A francia kereskedelmi jogszab�lyoknak nemr�g bevezetett v�ltoz�sok jelent?s k�lts�gn�veked�st okoztak a c�g�nk sz�m�ra a francia 
--megrendel�sek lesz�ll�t�s�t illet?en. N�velje meg 15%-al a franciaorsz�gb�l sz�rmaz� �gyfeleink utols� megrendel�sei�rt fizetett �sszeget
UPDATE s_megrendeles
SET fizetett_osszeg = fizetett_osszeg *1.15
WHERE megrendeles_id IN (
    SELECT max(megrendeles_id)
    FROM hajo.s_megrendeles m
    INNER JOIN hajo.s_ugyfel u
        ON m.ugyfel=u.ugyfel_id
    INNER JOIN hajo.s_helyseg h
        ON u.helyseg=h.helyseg_id
    WHERE h.orszag LIKE 'Franciaorsz�g'
    GROUP BY ugyfel_id
);

--68
--A n�pess�gi adataink elavultak. 
--A friss�t�s�k egyik l�p�sek�nt n�velje meg 5%-kal az �zsiai orsz�gok telep�l�seinek lakoss�g�t! 
UPDATE s_helyseg
SET lakossag = lakossag * 1.05
WHERE helyseg_id IN (
    SELECT helyseg_id
    FROM hajo.s_orszag o
    INNER JOIN hajo.s_helyseg h
        ON h.orszag=o.orszag
    WHERE o.foldresz LIKE '�zsia'
);

--69
--Egy puszt�t� v�rus szedte �ldozatait Afrika nagyv�rosaiban. Felezze meg azon afrikai telep�l�sek lakoss�g�t, amelyeknek aktu�lis
--lakoss�ga meghaladja a f�lmilli� f?t!
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
--C�g�nk adminisztr�tora elk�vetett egy nagy hib�t. A 2021 j�lius�ban Algeciras kik�t?j�b?l indul� utakat t�vesen
--Vitte be az adatb�zisba, mintha azok Valenci�b�l indultak volna. Val�ban Valenci�b�l egyetlen �t sem indult a k�rd�ses id?pontban
--Korrig�lja az adminisztr�tor hib�j�t! Az egyszer?s�g kedv��rt felt�telezz�k, hogy 1-1 ilyen v�ros l�tezik, egy kik�t?vel
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
--Hozzon l�tre n�zetet, amely list�zza az utak minden attrib�tum�t, kieg�sz�tve az indul�si �s �rkez�si kik�t? helys�g �s orsz�gnev�vel.
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

--74. Hozzon l�tre n�zetet, amely list�zza a megrendel�sek �sszes attrib�tum�t, kieg�sz�tve az indul�si �s �rkez�si kik�t?
--helys�gnev�vel �s orsz�g�val
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
--Hozzon l�tre n�zetet, amely list�zza, hogy az egyes haj�t�pusokhoz tartoz� haj�k �sszesen h�ny utat teljes�tettek! 
--A list�ban szerepeljen a haj�t�pusok azonos�t�ja, neve �s a teljes�tett utak sz�ma! 
--Azokat a haj�t�pusokat is t�ntesse fel az eredm�nyben, amelyekhez egyetlen haj� sem tartozik, 
--�s azokat is, amelyekhez tartoz� haj�k egyetlen utat sem teljes�tettek! 
--A lista legyen a haj�t�pus neve szerint rendezett!
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
--Hozzon l�tre n�zetet, amely list�zza, hogy az egyes kik�t?knek h�ny telefonsz�ma van. A lista tartalmazza a kik�t?k azonos�t�j�t,
--a helys�g nev�t �s osz�g�t �s a telefonok sz�m�t. Azokat is t�ntess�k fel, aminek nincs telefonsz�ma
CREATE VIEW kikototelefon AS
SELECT k.kikoto_id, h.helysegnev, h.orszag, COUNT(kt.telefon) Telefon_db
FROM hajo.s_kikoto k
LEFT JOIN hajo.s_kikoto_telefon kt
    ON kt.kikoto_id=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
GROUP BY k.kikoto_id, h.helysegnev, h.orszag;

--78.
--Hozzon l�tre n�zetet, amely list�zza, hogy az egyes kik�t?kre h�ny �t vezetett: kik�t?k azonos�t�ja, helys�g�k neve, orsz�ga, utak sz�ma
--Azokat is t�ntess�k fel, ahova egyetlen �t sem vezetett!
CREATE VIEW utakszama AS
SELECT k.kikoto_id, h.helysegnev, COUNT(u.ut_id) Ut_db
FROM hajo.s_kikoto k
LEFT JOIN hajo.s_ut u
    ON u.erkezesi_kikoto=k.kikoto_id
INNER JOIN hajo.s_helyseg h
    ON k.helyseg=h.helyseg_id
GROUP BY k.kikoto_id, h.helysegnev;

--80
--Egy n�zetet, amely kilist�zza, hogy az egyes kik�t?k h�ny megrendel�sben szerepeltek c�lpontk�nt! A lista tartalmazza kik�t?k id-j�t, helys�gek
--nev�t �s orsz�g�t �s a megrendel�sek sz�m�t
CREATE VIEW megrendelescelpont AS
SELECT k.kikoto_id, h.helysegnev, h.orszag, COUNT(m.megrendeles_id) Megrendeles_db
FROM hajo.s_kikoto k
LEFT JOIN hajo.s_megrendeles m
    ON k.kikoto_id=m.erkezesi_kikoto
INNER JOIN hajo.s_helyseg h
    ON h.helyseg_id=k.helyseg
GROUP BY k.kikoto_id, h.helysegnev, h.orszag;

--81. 
--Hozzon l�tre n�zetet, amely megadja a legnagyobb forgalm� kik�t?(k) azonos�t�j�t, helys�gnev�t �s orsz�g�t! A legnagyobb
--forgalm� kik�t? az, amelyik a legt�bb �t indul�si vagy �rkez�si kik�t?je volt.
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
--Hozzon l�tre n�zetet, amely megadja annak a haj�nak az azonos�t�j�t �s nev�t, 
--amelyik a legnagyobb �sszs�lyt sz�ll�totta a 2021 m�jus�ban indul� utakon! 
--Ha t�bb ilyen haj� is van, akkor mindegyiket list�zza!
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
--Hozzon l�tre n�zetet, ami megadja a kik�t? azonos�t�j�t, helys�gnev�t, orsz�g�t, amelykb?l kiindul� utakon
--sz�ll�tott kont�nerek �sszes�lya  a legnagyobb. Ha t�bb ilyen van, akkor mindegyiket list�zza
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
--Hozzon l�tre n�zetet, amely megadja annak a kik�t?nek az azonos�t�j�t, helys�gnev�t, �s orsz�g�t, ameylikbe tart� utakon
--sz�ll�tott kont�nerek �sszs�lya a legnagyobb. 
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
--Hozzon l�tre n�zetet amely megadja azoknak az utaknak az adatait, amelyeken a rakom�ny s�lya (a sz�ll�tott kont�nerek �s a
--rakom�nyaik �sszs�lya) meghaladja  a haj� maxim�lis s�lyterhel�s�t! Az �t adatai mellett t�ntesse fel a haj� nev�t �s maxim�lis s�lyterhel�s�t
--Valamint a rakom�ny s�ly�t is
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
--Hozzon l�tre n�zetet amely megadja azoknak az utaknak az adatait, amelyeken a rakom�ny s�lya (a sz�ll�tott kont�nerek �s a
--rakom�nyaik �sszs�lya) nem haladja meg a haj� maxim�lis s�lyterhel�s�nek a fel�t! Az �t adatai mellett t�ntesse fel a haj� nev�t �s maxim�lis s�lyterhel�s�t
--Valamint a rakom�ny s�ly�t is
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
--Hozzon l�tre n�zetet, amely megadja annak a megrendel�snek az adatait, amelynek a teljes�t�s�hez a legt�bb �tra volt sz�ks�g! Ha t�bb
--Ilyen megrendel�s is van, akkor mindegyiket list�zza!
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
--Adjon hivatkoz�si jogosults�got panovicsnak az �n s_ut t�bl�j�nak indulasi_ido �s hajo oszlopaiba
GRANT REFERENCES(indulasi_ido, hajo) ON s_ut TO panovics;

--94
--Adjon m�dos�t�si jogosults�got a 'panovics' felhaszn�l�nak az �n s_ugyfel t�bl�j�nak vezet�k �s keresztn�v oszlopaira
GRANT UPDATE(vezeteknev, keresztnev) ON s_ugyfel TO panovics;

--95
--Adjon besz�r�si jogosults�got minden felhaszn�l�nak 
--az �n 's_kikoto' t�bl�j�nak a 'kikoto_id' �s 'helyseg' oszlopaira!
GRANT INSERT(kikoto_id, helyseg) ON s_kikoto TO PUBLIC;

--96
--Vonja vissza a lek�rdez�si jogosults�got a 'panovics' felhaszn�l�t�l az �n s_ut t�bl�j�b�l
REVOKE SELECT ON s_ut FROM panovics;

--98
--Vonja vissza a t�rl�si �s m�dos�t�si jogosults�got a 'panovics' nev? felhaszn�l�t�l az �n s_kikoto t�bl�j�r�l
REVOKE DELETE, UPDATE ON s_kikoto FROM panovics;

--99
--Vonja vissza a t�rl�si jogot 'panovics' felhaszn�l�t�l az �n s_orszag t�bl�j�r�l
REVOKE DELETE ON s_orszag FROM panovics;

--100
--Vonja vissza a besz�r�si jogosults�got minden felhaszn�l�t�l az �n s_megrendel�s t�bl�j�r�l
REVOKE INSERT on s_megrendeles FROM public;