--Jednostavni upiti:
--upit koji vra�a sve nastavnike �kole zajedno s njihovim kabinetima
SELECT ime || ' ' || prezime AS "Nastavnik", kabinet
FROM nastavnik
ORDER BY prezime, ime;

--upit koji vra�a sve roditelje, njihov telefon i email
SELECT ime || ' ' || prezime AS "Roditelj", telefon, email
FROM roditelj
ORDER BY prezime, ime;

--upit koji vra�a sve obvezne predmete
SELECT naziv
FROM predmet
WHERE obvezni = 1
ORDER BY naziv;

--upit koji vra�a adrese svih u�enika 1.a razreda 2019./2020.
SELECT ime || ' ' || prezime AS "U�enik", adresa
FROM ucenik
WHERE skolska_godina = '2019/2020' AND razred_br = '1.' AND odjeljenje = 'a'
ORDER BY prezime, ime;

--upit koji vra�a sve razrede 2019./2020. �kolske godine
SELECT razred_br || '' || odjeljenje AS "Razred"
FROM razred
WHERE skolska_godina = '2019/2020'
ORDER BY razred_br, odjeljenje;

-----------------------------------------------------------------------------------
--Upiti nad vi�e tablica:
--upit koji vra�a naziv predmeta koji se predavao 1.12.2019. u u�ionici U2 tijekom 2. �kolskog sata
SELECT p.naziv
FROM predmet p JOIN raspored r USING (predmet_id)
WHERE r.datum = TO_DATE('01/12/2019', 'dd/mm/yyyy') AND r.ucionica = 'U2' AND r.sat = 2;

--upit koji vra�a razrednike prvih razreda �kolske godine 2019./2020.
SELECT r.razred_br || '' || r.odjeljenje AS "razred", n.ime || ' ' || n.prezime AS "razrednik"
FROM nastavnik n JOIN razred r USING (nastavnik_id)
WHERE r.razred_br = '1.' AND r.skolska_godina = '2019/2020';

--upit koji vra�a imena i prezimena roditelja svih u�enika koji imaju bar jednu jedinicu u dnevniku
SELECT r.ime || ' ' || r.prezime AS "Roditelj", u.ime || ' ' || u.prezime AS "U�enik" 
FROM roditelj r JOIN ucenik_roditelj USING (roditelj_id) JOIN ucenik u USING (ucenik_id) JOIN dnevnik d USING (ucenik_id)
WHERE d.ocjena = 1
GROUP BY r.ime, r.prezime, u.ime, u.prezime
ORDER BY u.prezime, u.ime, r.ime;

--upit koji vra�a roditelje u�enika s ukorom
SELECT r.ime || ' ' || r.prezime AS "Roditelj", u.ime || ' ' || u.prezime AS "U�enik"
FROM roditelj r JOIN ucenik_roditelj USING (roditelj_id) 
    JOIN ucenik u USING (ucenik_id) JOIN pedagoska_mjera p USING (ucenik_id)
WHERE mjera = 'ukor';

--upit koji vra�a imena i prezimena u�enika koji su sudjelovali na �kolskom natjecanju iz matematike
SELECT u.ime, u.prezime
FROM ucenik u JOIN natjecanje n USING (ucenik_id) JOIN predmet p USING (predmet_id)
WHERE p.naziv = 'Matematika' AND n.razina = '�kolska'
ORDER BY u.ime, u.prezime;

-------------------------------------------------------------------------------
--Upiti napravljeni koriste�i agregiraju�e funkcije:
--upit koji vra�a broj obveznih i izbornih predmeta
SELECT DECODE(obvezni, 1, 'obvezni', 'izborni'), COUNT(obvezni)
FROM predmet
GROUP BY obvezni;

--upit koji vra�a prosje�nu ocjenu prvih razreda iz matematike 2019./2020.
SELECT AVG(d.ocjena)
FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE p.naziv = 'Matematika' AND razred_br = '1.' AND skolska_godina = '2019/2020';

--upit koji vra�a broj pedago�kih mjera svakog u�enika 2019./2020.
SELECT u.ime, u.prezime, COUNT(mjera_id)
FROM pedagoska_mjera p RIGHT OUTER JOIN ucenik u USING (ucenik_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020'
GROUP BY u.ime, u.prezime;

--upit koji vra�a medijan svih ocjena u dnevniku 2019./2020.
SELECT MEDIAN(d.ocjena)
FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN razred USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020';

--upit koji vra�a u�enike s najvi�e neopravdanih sati 2019./2020.
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
--Podupiti, ugnije��eni upiti, skupovne operacije:

--upit koji vra�a razred (ili razrede) s najve�om prosje�nom ocjenom iz svih predmeta 2019./2020. �kolske godine
SELECT razred_br || odjeljenje AS "Razred"
FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id) JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020'
GROUP BY razred_br, odjeljenje
HAVING AVG(d.ocjena) >= ALL (SELECT AVG(d.ocjena)
                         FROM dnevnik d JOIN ucenik u USING (ucenik_id) JOIN predmet p USING (predmet_id) 
                         JOIN razred USING (skolska_godina, razred_br, odjeljenje)
                         WHERE skolska_godina = '2019/2020'
                         GROUP BY razred_br, odjeljenje);

--upit koji vra�a predmete koje je 1.12.2019. imao 1.a razred, a nije ih imao 1.b
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

--upit koji vra�a u�enike koji imaju ve�u prosje�nu ocjenu iz svih predmeta od prosje�ne ocjene cijele �kole 2019./2020. 
SELECT u.ime || u.prezime AS "U�enik"
FROM ucenik u JOIN dnevnik d USING (ucenik_id)JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020'
GROUP BY u.ime, u.prezime
HAVING AVG(d.ocjena) >= ALL(SELECT AVG(ocjena)
                            FROM dnevnik);
                                                      
--upit koji vra�a u�enike koji nemaju niti jedan neopravdani izostanak
SELECT u.ime ||' '|| u.prezime AS "U�enik"
FROM ucenik u LEFT OUTER JOIN izostanak i USING (ucenik_id) JOIN razred r USING (skolska_godina, razred_br, odjeljenje)
WHERE skolska_godina = '2019/2020' AND ucenik_id NOT IN (SELECT ucenik_id
                                                         FROM izostanak
                                                         WHERE opravdan = 0)
ORDER BY u.ime, u.prezime;
           
--upit koji vra�a nastavnika koji je dr�ao nastavu 1.12.2019. prijepodne u u�ionici U2
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
--uvjet koji osigurava da atribut smjena mo�e imati samo vrijednosti 'prijepodnevna' i 'poslijepodnevna' 
ALTER TABLE raspored
ADD CONSTRAINT raspored_smjena_ck
CHECK (smjena IN ('prijepodnevna', 'poslijepodnevna'));

UPDATE raspored
SET smjena = 'jutarnja'
WHERE raspored_id = 1;

--uvjet koji osigurava da atribut obvezni mo�e imati samo vrijednosti 0 i 1 
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
'tablica izostanak sadr�i informaciju s kojeg sata iz rasporeda je u�enik izostao, je li taj izostanak opravdan te bilje�ku razrednika';

COMMENT ON TABLE raspored IS
'tablica raspored sadr�i datum, dan u tjednu, smjenu i �kolski sat odr�avanja predmeta, razred koji ga je slu�ao i u�ionicu u kojoj se odr�ao';

COMMENT ON TABLE natjecanje IS
'tablica natjecanje sadr�i razinu, mjesto odr�avanja i naziv natjecanja na kojemu se u�enik natjecao te mjesto koje je osvojio';

COMMENT ON TABLE dnevnik IS
'tablica dnevnik sadr�i ocjenu koju je u�enik dobio iz odre�enog predmeta, datum i bilje�ku nastavnika u kojoj se opisuje razlog upisivanja ocjene';

COMMENT ON TABLE pedagoska_mjera IS
'tablica pedagoska_mjera sadr�i vrstu pedago�ke mjere koju je u�enik dobio te obrazlo�enje u kojemu se navodi razlog izricanja mjere';

COMMENT ON TABLE raspored IS
'tablica raspored sadr�i datum, dan u tjednu, smjenu i �kolski sat odr�avanja predmeta, razred koji ga je slu�ao i u�ionicu u kojoj se odr�ao';

COMMENT ON TABLE ucenik IS
'tablica ucenik sadr�i ime, prezime, datum ro�enja, spol, adresu i razred u�enika';

COMMENT ON TABLE razred IS
'tablica razred sadr�i �kolsku godinu, redni broj razreda i odjeljenje';

COMMENT ON TABLE predmet IS
'tablica predmet sadr�i naziv predmeta, nastavnika koji ga predaje i informaciju o tome je li obvezan ili ne';

COMMENT ON TABLE nastavnik IS
'tablica nastavnik sadr�i ime, prezime i spol nastavnika te njegov kabinet';

COMMENT ON TABLE roditelj IS
'tablica roditelj sadr�i ime, prezime, spol, adresu, telefon i email roditelja';
-----------------------------------------------------------------------------------
--Indeksi:
--B-tree indeks koji �e ubrzati pretra�ivanje roditelja po prezimenu
CREATE INDEX indeks_roditelj_prezime ON roditelj(prezime);

--bitmap indeks koji �e ubrzati pretra�ivanje natjecanja po razini
CREATE BITMAP INDEX indeks_natjecanje_razina ON natjecanje(razina);

--bitmap indeks koji �e ubrzati pretra�ivanje pedago�kih mjera po vrsti mjere
CREATE BITMAP INDEX indeks_pedagoska_mjera_mjera ON pedagoska_mjera(mjera);
-----------------------------------------------------------------------------------
--Procedure:
--procedura koja ispisuje sve ocjene nekog u�enika iz odre�enog predmeta
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

--procedura koja �e a�urirati nastavnika koji predaje odre�eni predmet
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

CALL update_predmet_nastavnik('Matematika', 'Petra', 'Peri�');

CALL update_predmet_nastavnik('Matematika', 'Ana', 'Ani�', 'Z', 'k9');

SELECT *
FROM nastavnik;

SELECT *
FROM predmet
WHERE naziv = 'Matematika';
-----------------------------------------------------------------------------------
--Okida�i:
--okida� koji �e upozoriti prije nego se unese ocjena manja od 1 ili ve�a od 5
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

--okida� koji �e upozoriti prije nego se upi�e �etvrta ocjena u�eniku na isti datum
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
        DBMS_OUTPUT.PUT_LINE('U�enik je danas ocijenjen ve� tri puta.');
    END IF;
END before_dnevnik_insert;

INSERT INTO dnevnik
VALUES (12, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Doma�a zada�a', 9, 2);

INSERT INTO dnevnik
VALUES (13, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 9, 2);

INSERT INTO dnevnik
VALUES (14, 6, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Usmeni ispit', 9, 3);