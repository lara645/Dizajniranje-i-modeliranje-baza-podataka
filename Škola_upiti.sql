--Jednostavni upiti:
--upit koji vraæa sve nastavnike škole zajedno s njihovim kabinetima
SELECT ime || ' ' || prezime AS "Nastavnik", kabinet
FROM nastavnik
ORDER BY prezime, ime;

--upit koji vraæa sve roditelje, njihov telefon i email
SELECT ime || ' ' || prezime AS "Roditelj", telefon, email
FROM roditelj
ORDER BY prezime, ime;

--upit koji vraæa sve obvezne predmete
SELECT naziv
FROM predmet
WHERE obvezni = 1
ORDER BY naziv;

--upit koji vraæa adrese svih uèenika 1.a razreda 2019./2020.
SELECT ime || ' ' || prezime AS "Uèenik", adresa
FROM ucenik
WHERE skolska_godina = '2019/2020' AND razred_br = '1.' AND odjeljenje = 'a'
ORDER BY prezime, ime;

--upit koji vraæa sve razrede 2019./2020. školske godine
SELECT razred_br || '' || odjeljenje AS "Razred"
FROM razred
WHERE skolska_godina = '2019/2020'
ORDER BY razred_br, odjeljenje;

-----------------------------------------------------------------------------------
--Upiti nad više tablica:
--upit koji vraæa naziv predmeta koji se predavao 1.12.2019. u uèionici U2 tijekom 2. školskog sata
SELECT p.naziv
FROM predmet p JOIN raspored r USING (predmet_id)
WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') AND r.ucionica = 'U2' AND r.sat = 2;

--upit koji vraæa razrednike prvih razreda školske godine 2019./2020.
SELECT r.razred_br || '' || r.odjeljenje AS "razred", n.ime || ' ' || n.prezime AS "razrednik"
FROM nastavnik n JOIN razred r USING (nastavnik_id)
WHERE r.razred_br = '1.' AND r.skolska_godina = '2019/2020';

--upit koji vraæa imena i prezimena roditelja svih uèenika koji imaju bar jednu jedinicu u dnevniku
SELECT r.ime || ' ' || r.prezime AS "Roditelj", u.ime || ' ' || u.prezime AS "Uèenik" 
FROM roditelj r JOIN ucenik_roditelj USING (roditelj_id) JOIN ucenik u USING (ucenik_id) JOIN dnevnik d USING (ucenik_id)
WHERE d.ocjena = 1
GROUP BY r.ime, r.prezime, u.ime, u.prezime
ORDER BY u.prezime, u.ime, r.ime;

--upit koji vraæa roditelje uèenika s ukorom
SELECT r.ime || ' ' || r.prezime AS "Roditelj", u.ime || ' ' || u.prezime AS "Uèenik"
FROM roditelj r JOIN ucenik_roditelj USING (roditelj_id) 
    JOIN ucenik u USING (ucenik_id) JOIN pedagoska_mjera p USING (ucenik_id)
WHERE mjera = 'ukor';

--upit koji vraæa imena i prezimena uèenika koji su sudjelovali na školskom natjecanju iz matematike
SELECT u.ime, u.prezime
FROM ucenik u JOIN natjecanje n USING (ucenik_id) JOIN predmet p USING (predmet_id)
WHERE p.naziv = 'Matematika' AND n.razina = 'školska'
ORDER BY u.ime, u.prezime;

-------------------------------------------------------------------------------
--Upiti napravljeni koristeæi agregirajuæe funkcije:
--upit koji vraæa broj obveznih i izbornih predmeta
SELECT DECODE(obvezni, 1, 'obvezni', 'izborni'), COUNT(obvezni)
FROM predmet
GROUP BY obvezni;

--upit koji vraæa prosjeènu ocjenu prvih razreda iz matematike 2019./2020.
SELECT AVG(d.ocjena)
FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE p.naziv = 'Matematika' AND razred_br = '1.' AND skolska_godina = '2019/2020';

--upit koji vraæa broj pedagoških mjera svakog uèenika 2019./2020.
SELECT u.ime, u.prezime, COUNT(mjera_id)
FROM pedagoska_mjera p RIGHT OUTER JOIN ucenik u USING (ucenik_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020'
GROUP BY u.ime, u.prezime;

--upit koji vraæa medijan svih ocjena u dnevniku 2019./2020.
SELECT MEDIAN(d.ocjena)
FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020';

--upit koji vraæa uèenike s najviše neopravdanih sati 2019./2020.
SELECT u.ime, u.prezime, COUNT(izostanak_id) AS "Broj neopravdanih sati"
FROM izostanak i JOIN ucenik u USING (ucenik_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE opravdan = 0 AND skolska_godina = '2019/2020'
GROUP BY u.ime, u.prezime
HAVING COUNT(izostanak_id) >= ALL 
(SELECT COUNT(izostanak_id)
FROM izostanak i JOIN ucenik u USING (ucenik_id)
WHERE opravdan = 0
GROUP BY u.ime, u.prezime);

----------------------------------------------------------------------------------
--Podupiti, ugniježðeni upiti, skupovne operacije:

--upit koji vraæa razred (ili razrede) s najveæom prosjeènom ocjenom iz svih predmeta 2019./2020. školske godine
SELECT razred_br || odjeljenje AS "Razred"
FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id) JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020'
GROUP BY razred_br, odjeljenje
HAVING AVG(d.ocjena) >= ALL (SELECT AVG(d.ocjena)
                         FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id) 
                         JOIN razred USING (skolska_godina, razred_br, odjeljenje)
                         WHERE skolska_godina = '2019/2020'
                         GROUP BY razred_br, odjeljenje);

--upit koji vraæa predmete koje je 1.12.2019. imao 1.a razred, a nije ih imao 1.b
SELECT p.naziv
FROM predmet p JOIN raspored r USING (predmet_id) JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') 
AND p.naziv IN (SELECT p.naziv
                FROM  predmet p JOIN raspored r USING (predmet_id) JOIN razred r 
                USING (skolska_godina, razred_br, odjeljenje)
                WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') AND razred_br = '1.' 
                      AND odjeljenje = 'a'
                MINUS
                SELECT p.naziv
                FROM  predmet p JOIN raspored r USING (predmet_id) JOIN razred r 
                USING (skolska_godina, razred_br, odjeljenje)
                WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') AND razred_br = '1.' 
                      AND odjeljenje = 'b');

--upit koji vraæa uèenike koji imaju veæu prosjeènu ocjenu iz svih predmeta od prosjeène ocjene cijele škole 2019./2020. 
SELECT u.ime || u.prezime AS "Uèenik"
FROM ucenik u JOIN dnevnik d USING (ucenik_id)JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020'
GROUP BY u.ime, u.prezime
HAVING AVG(d.ocjena) >= ALL(SELECT AVG(ocjena)
                            FROM dnevnik);
                                                      
--upit koji vraæa uèenike koji nemaju niti jedan neopravdani izostanak
SELECT u.ime ||' '|| u.prezime AS "Uèenik"
FROM ucenik u LEFT OUTER JOIN izostanak i USING (ucenik_id) JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020' AND ucenik_id NOT IN (SELECT ucenik_id
                                                         FROM izostanak
                                                         WHERE opravdan = 0)
ORDER BY u.ime, u.prezime;
           
--upit koji vraæa nastavnika koji je držao nastavu 1.12.2019. prijepodne u uèionici U2
SELECT DISTINCT n.ime, n.prezime
FROM nastavnik n JOIN predmet p USING (nastavnik_id) JOIN raspored USING (predmet_id) 
WHERE nastavnik_id IN (SELECT nastavnik_id
                       FROM nastavnik n JOIN predmet p USING (nastavnik_id) JOIN raspored r USING (predmet_id)
                       WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') AND r.smjena = 'prijepodnevna'
                       INTERSECT
                       SELECT nastavnik_id
                       FROM nastavnik n JOIN predmet p USING (nastavnik_id) JOIN raspored r USING (predmet_id)
                       WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') AND r.ucionica = 'U2');
----------------------------------------------------------------------------------
--Uvjeti:
--uvjet koji osigurava da atribut smjena može imati samo vrijednosti 'prijepodnevna' i 'poslijepodnevna' 
ALTER TABLE raspored
ADD CONSTRAINT raspored_smjena_ck
CHECK (smjena IN ('prijepodnevna', 'poslijepodnevna'));

UPDATE raspored
SET smjena = 'jutarnja'
WHERE raspored_id = 1;

--uvjet koji osigurava da atribut obvezni može imati samo vrijednosti 0 i 1 
ALTER TABLE predmet
ADD CONSTRAINT predmet_obvezni_ck
CHECK (obvezni IN (0, 1));

UPDATE predmet
SET obvezni = 2
WHERE predmet_id = 1;

--uvjet koji osigurava da dva nastavnika ne mogu imati isti kabinet
ALTER TABLE nastavnik
ADD CONSTRAINT nastavnik_kabinet_uq UNIQUE (kabinet);

UPDATE nastavnik
SET kabinet = 'k1'
WHERE nastavnik_id = 2;
-----------------------------------------------------------------------------------
--Komentari na tablice:
COMMENT ON TABLE izostanak IS
'tablica izostanak sadrži informaciju s kojeg sata iz rasporeda je uèenik izostao, je li taj izostanak opravdan te bilješku razrednika';

COMMENT ON TABLE raspored IS
'tablica raspored sadrži datum, dan u tjednu, smjenu i školski sat održavanja predmeta, razred koji ga je slušao i uèionicu u kojoj se održao';

COMMENT ON TABLE natjecanje IS
'tablica natjecanje sadrži razinu, mjesto održavanja i naziv natjecanja na kojemu se uèenik natjecao te mjesto koje je osvojio';

COMMENT ON TABLE dnevnik IS
'tablica dnevnik sadrži ocjenu koju je uèenik dobio iz odreðenog predmeta, datum i bilješku nastavnika u kojoj se opisuje razlog upisivanja ocjene';

COMMENT ON TABLE pedagoska_mjera IS
'tablica pedagoska_mjera sadrži vrstu pedagoške mjere koju je uèenik dobio te obrazloženje u kojemu se navodi razlog izricanja mjere';

COMMENT ON TABLE raspored IS
'tablica raspored sadrži datum, dan u tjednu, smjenu i školski sat održavanja predmeta, razred koji ga je slušao i uèionicu u kojoj se održao';

COMMENT ON TABLE ucenik IS
'tablica ucenik sadrži ime, prezime, datum roðenja, spol, adresu i razred uèenika';

COMMENT ON TABLE razred IS
'tablica razred sadrži školsku godinu, redni broj razreda i odjeljenje';

COMMENT ON TABLE predmet IS
'tablica predmet sadrži naziv predmeta, nastavnika koji ga predaje i informaciju o tome je li obvezan ili ne';

COMMENT ON TABLE nastavnik IS
'tablica nastavnik sadrži ime, prezime i spol nastavnika te njegov kabinet';

COMMENT ON TABLE roditelj IS
'tablica roditelj sadrži ime, prezime, spol, adresu, telefon i email roditelja';
-----------------------------------------------------------------------------------
--Indeksi:
--B-tree indeks koji æe ubrzati pretraživanje roditelja po prezimenu
CREATE INDEX indeks_roditelj_prezime ON roditelj(prezime);

--bitmap indeks koji æe ubrzati pretraživanje natjecanja po razini
CREATE BITMAP INDEX indeks_natjecanje_razina ON natjecanje(razina);

--bitmap indeks koji æe ubrzati pretraživanje pedagoških mjera po vrsti mjere
CREATE BITMAP INDEX indeks_pedagoska_mjera_mjera ON pedagoska_mjera(mjera);
-----------------------------------------------------------------------------------
--Procedure:
--procedura koja ispisuje sve ocjene nekog uèenika iz odreðenog predmeta
CREATE OR REPLACE PROCEDURE ispis_ocjena(
p_ime IN ucenik.ime%TYPE,
p_prezime IN ucenik.prezime%TYPE,
p_naziv IN predmet.naziv%TYPE
) AS
v_ocjena dnevnik.ocjena%TYPE;
CURSOR kursor IS
    SELECT d.ocjena
    FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id)
    WHERE u.ime = p_ime AND u.prezime = p_prezime AND p.naziv = p_naziv;
BEGIN
    OPEN kursor;
    LOOP
        FETCH kursor
        INTO v_ocjena;
        EXIT WHEN kursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_ocjena);
    END LOOP;
    CLOSE kursor;

    EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
END ispis_ocjena;

SET SERVEROUTPUT ON;
CALL ispis_ocjena('Mia', 'Horvat', 'Matematika');

--procedura koja æe ažurirati nastavnika koji predaje odreðeni predmet
CREATE OR REPLACE PROCEDURE update_predmet_nastavnik(
p_naziv IN predmet.naziv%TYPE,
p_ime IN nastavnik.ime%TYPE,
p_prezime IN nastavnik.prezime%TYPE,
p_spol IN nastavnik.spol%TYPE DEFAULT NULL,
p_kabinet IN nastavnik.kabinet%TYPE DEFAULT NULL
) AS
v_brojac INTEGER;
v_nastavnik_id nastavnik.nastavnik_id%TYPE;
BEGIN
            SELECT COUNT(*)
            INTO v_brojac
            FROM nastavnik
            WHERE ime = p_ime AND prezime = p_prezime;
            
            IF v_brojac = 1 THEN
            
            SELECT nastavnik_id
            INTO v_nastavnik_id
            FROM nastavnik
            WHERE ime = p_ime AND prezime = p_prezime; 
             
            UPDATE predmet
            SET nastavnik_id = v_nastavnik_id
            WHERE naziv = p_naziv;
            
            COMMIT;
            
            ELSIF v_brojac = 0 THEN
            
            SELECT MAX(nastavnik_id)+1
            INTO v_nastavnik_id
            FROM nastavnik;
            
            INSERT INTO nastavnik
            VALUES (v_nastavnik_id, p_ime, p_prezime, p_spol, p_kabinet);
            
            UPDATE predmet
            SET nastavnik_id = v_nastavnik_id
            WHERE naziv = p_naziv;
            
            COMMIT;
            
            END IF;
        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
END update_predmet_nastavnik;

CALL update_predmet_nastavnik('Matematika', 'Petra', 'Periæ');

CALL update_predmet_nastavnik('Matematika', 'Ana', 'Aniæ', 'Z', 'k9');

SELECT *
FROM nastavnik;

SELECT *
FROM predmet
WHERE naziv = 'Matematika';
-----------------------------------------------------------------------------------
--Okidaèi:
--okidaè koji æe upozoriti prije nego se unese ocjena manja od 1 ili veæa od 5
CREATE OR REPLACE TRIGGER before_dnevnik_insert
BEFORE INSERT
ON dnevnik
FOR EACH ROW WHEN
(new.ocjena < 1 OR new.ocjena > 5)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Ocjena nije dobro unesena.');
END before_dnevnik_insert;

INSERT INTO dnevnik
VALUES (12, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Usmeni ispit', 3, 2);

--okidaè koji æe upozoriti prije nego se upiše èetvrta ocjena uèeniku na isti datum
CREATE OR REPLACE TRIGGER before_dnevnik_insert
BEFORE INSERT
ON dnevnik
FOR EACH ROW 
DECLARE
v_br_ocjena INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_br_ocjena
    FROM dnevnik
    WHERE datum = :NEW.datum  AND ucenik_id = :NEW.ucenik_id;
    
    IF v_br_ocjena >= 3 THEN
        DBMS_OUTPUT.PUT_LINE('Uèenik je danas ocijenjen veæ tri puta.');
    END IF;
END before_dnevnik_insert;

INSERT INTO dnevnik
VALUES (12, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Domaæa zadaæa', 9, 2);

INSERT INTO dnevnik
VALUES (13, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 9, 2);

INSERT INTO dnevnik
VALUES (14, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Usmeni ispit', 9, 3);