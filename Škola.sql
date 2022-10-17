DROP TABLE izostanak;
DROP TABLE raspored;
DROP TABLE natjecanje;
DROP TABLE dnevnik;
DROP TABLE ucenik_roditelj;
DROP TABLE pedagoska_mjera;
DROP TABLE ucenik;
DROP TABLE razred;
DROP TABLE predmet;
DROP TABLE nastavnik;
DROP TABLE roditelj;
-------------------------------------------------------------------
CREATE TABLE roditelj (
    roditelj_id INTEGER CONSTRAINT roditelj_PK PRIMARY KEY ,
    ime               VARCHAR2(10) NOT NULL ,
    prezime           VARCHAR2(10) NOT NULL ,
    spol              VARCHAR2(1) NOT NULL ,
    adresa            VARCHAR2(100) NOT NULL ,
    telefon           VARCHAR2(20) NOT NULL ,
    email             VARCHAR2(30) NOT NULL
);

CREATE TABLE nastavnik (
    nastavnik_id INTEGER CONSTRAINT nastavnik_PK PRIMARY KEY ,
    ime               VARCHAR2(10) NOT NULL ,
    prezime           VARCHAR2(10) NOT NULL ,
    spol              VARCHAR2(1) NOT NULL ,
    kabinet           VARCHAR2(3) NOT NULL
);

CREATE TABLE predmet (
    predmet_id            INTEGER CONSTRAINT predmet_PK PRIMARY KEY ,
    naziv                 VARCHAR2(100) NOT NULL ,
    obvezni               INTEGER DEFAULT 1,
    nastavnik_id          INTEGER NOT NULL CONSTRAINT predmet_nastavnik_FK REFERENCES nastavnik ( nastavnik_id )
);

CREATE TABLE razred (
    skolska_godina    VARCHAR2(20) NOT NULL ,
    razred_br         VARCHAR2(2) NOT NULL ,
    odjeljenje        VARCHAR2(1) NOT NULL ,
    CONSTRAINT razred_PK PRIMARY KEY ( skolska_godina, razred_br, odjeljenje ) ,
    nastavnik_id      INTEGER NOT NULL CONSTRAINT razred_nastavnik_FK REFERENCES nastavnik ( nastavnik_id )    
);

CREATE TABLE ucenik (
    ucenik_id INTEGER CONSTRAINT ucenik_PK PRIMARY KEY ,
    ime               VARCHAR2(10) NOT NULL ,
    prezime           VARCHAR2(10) NOT NULL ,
    datum_rodj        DATE NOT NULL ,
    spol              VARCHAR2(1) NOT NULL ,
    adresa            VARCHAR2(100) NOT NULL ,
    skolska_godina    VARCHAR2(20) NOT NULL ,
    razred_br         VARCHAR2(2) NOT NULL ,
    odjeljenje        VARCHAR2(1) NOT NULL ,
    CONSTRAINT ucenik_razred_FK FOREIGN KEY ( skolska_godina, razred_br, odjeljenje ) 
    REFERENCES razred ( skolska_godina, razred_br, odjeljenje ) 
);

CREATE TABLE pedagoska_mjera (
    mjera_id             INTEGER CONSTRAINT pedagoska_mjera_PK PRIMARY KEY ,
    mjera                VARCHAR2(15) DEFAULT 'opomena',
    obrazlozenje         VARCHAR2(100) NOT NULL ,
    ucenik_id            INTEGER NOT NULL CONSTRAINT pedagoska_mjera_ucenik_FK REFERENCES ucenik ( ucenik_id )
);

CREATE TABLE ucenik_roditelj (
    ucenik_id            INTEGER NOT NULL CONSTRAINT ucenik_roditelj_ucenik_FK 
    REFERENCES ucenik ( ucenik_id ),
    roditelj_id          INTEGER NOT NULL CONSTRAINT ucenik_roditelj_roditelj_FK 
    REFERENCES roditelj ( roditelj_id ) ,
    CONSTRAINT ucenik_roditelj_PK PRIMARY KEY ( ucenik_id, roditelj_id )
);

CREATE TABLE dnevnik (
    ocjena_id            INTEGER NOT NULL ,
    ocjena               INTEGER NOT NULL ,
    datum                DATE DEFAULT SYSDATE,
    biljeska             VARCHAR2(50) NOT NULL , 
    ucenik_id            INTEGER NOT NULL CONSTRAINT dnevnik_ucenik_FK 
    REFERENCES ucenik ( ucenik_id ) ,
    predmet_id           INTEGER NOT NULL CONSTRAINT dnevnik_predmet_FK 
    REFERENCES predmet ( predmet_id ) ,
    CONSTRAINT dnevnik_PK PRIMARY KEY ( ocjena_id, ucenik_id, predmet_id )
);

CREATE TABLE natjecanje (
    natjecanje_id        INTEGER NOT NULL ,
    razina               VARCHAR2(20) NOT NULL , 
    osvojeno_mjesto      INTEGER NOT NULL ,
    naziv                VARCHAR2(100) NOT NULL ,
    mjesto_održavanja    VARCHAR2(100) NOT NULL ,
    ucenik_id            INTEGER NOT NULL CONSTRAINT natjecanje_ucenik_FK REFERENCES ucenik ( ucenik_id ) ,
    predmet_id           INTEGER NOT NULL CONSTRAINT natjecanje_predmet_FK REFERENCES predmet ( predmet_id ) ,
    CONSTRAINT natjecanje_PK PRIMARY KEY ( natjecanje_id, ucenik_id, predmet_id )
);

CREATE TABLE raspored (
    raspored_id           VARCHAR2(4) CONSTRAINT raspored_PK PRIMARY KEY ,
    datum                 DATE DEFAULT SYSDATE,
    dan_u_tjednu          VARCHAR2(15) NOT NULL ,
    smjena                VARCHAR2(30) NOT NULL ,
    sat                   INTEGER NOT NULL ,
    ucionica              VARCHAR2(3) NOT NULL ,
    predmet_id            INTEGER NOT NULL CONSTRAINT raspored_predmet_FK REFERENCES predmet ( predmet_id ) ,
    skolska_godina        VARCHAR2(20) NOT NULL ,
    razred_br             VARCHAR2(2) NOT NULL ,
    odjeljenje            VARCHAR2(1) NOT NULL ,
    CONSTRAINT raspored_razred_FK FOREIGN KEY ( skolska_godina, razred_br, odjeljenje ) REFERENCES razred ( skolska_godina, razred_br, odjeljenje )
);

CREATE TABLE izostanak (
    izostanak_id         INTEGER NOT NULL ,
    opravdan             INTEGER DEFAULT 1,
    biljeska             VARCHAR2(100) NOT NULL ,
    ucenik_id            INTEGER NOT NULL CONSTRAINT izostanak_ucenik_FK REFERENCES ucenik ( ucenik_id ) ,
    raspored_id          VARCHAR2(4) NOT NULL CONSTRAINT izostanak_raspored_FK REFERENCES raspored ( raspored_id ) ,
    CONSTRAINT izostanak_PK PRIMARY KEY ( izostanak_id, ucenik_id, raspored_id )
);
---------------------------------------------------------------------------------------

INSERT INTO roditelj
VALUES (1, 'Ivan', 'Horvat', 'M', 'Vlaška 7, 10000, Zagreb', '0982638456', 'ihorvat@gmail.com');

INSERT INTO roditelj
VALUES (2, 'Ana', 'Horvat', 'Z', 'Vlaška 7, 10000, Zagreb', '0912219345', 'ahorvat@gmail.com');

INSERT INTO roditelj
VALUES (3, 'Petar', 'Kovaè', 'M', 'A. Hebranga 16, 10000, Zagreb', '0915029893', 'pkovac@gmail.com');

INSERT INTO roditelj
VALUES (4, 'Marija', 'Kovaè', 'Z', 'A. Hebranga 16, 10000, Zagreb', '0913243672', 'mkovac@gmail.com');

INSERT INTO roditelj
VALUES (5, 'Luka', 'Novak', 'M', 'Gajeva 30a, 10000, Zagreb', '0927568179', 'lnovak@gmail.com');

INSERT INTO roditelj
VALUES (6, 'Ivana', 'Novak', 'Z', 'Gajeva 30a, 10000, Zagreb', '0983446318', 'inovak@gmail.com');

INSERT INTO roditelj
VALUES (7, 'Marina', 'Lonèar', 'Z', 'Trg bana J. Jelaèiæa 15, 10000, Zagreb', '0992160620', 'mloncar@gmail.com');

INSERT INTO roditelj
VALUES (8, 'Hrvoje', 'Lonèar', 'M', 'Trg bana J. Jelaèiæa 15, 10000, Zagreb', '0921718051', 'hlonacar@gmail.com');
-------------------------------------------------------------------------------------------------

INSERT INTO nastavnik
VALUES (1, 'Lucija', 'Zovak', 'Z', 'k1');

INSERT INTO nastavnik
VALUES (2, 'Domagoj', 'Juriæ', 'M', 'k2');

INSERT INTO nastavnik
VALUES (3, 'Josip', 'Mariæ', 'M', 'k3');

INSERT INTO nastavnik
VALUES (4, 'Ivan', 'Vukoviæ', 'M', 'k4');

INSERT INTO nastavnik
VALUES (5, 'Eva', 'Kraljeviæ', 'Z', 'k5');

INSERT INTO nastavnik
VALUES (6, 'Petra', 'Periæ', 'Z', 'k6');

INSERT INTO nastavnik
VALUES (7, 'Nikola', 'Mandiæ', 'M', 'k7');

INSERT INTO nastavnik
VALUES (8, 'Lucija', 'Babiæ', 'Z', 'k8');
---------------------------------------------------------------------------------

INSERT INTO predmet
VALUES (1, 'Matematika', 1, 1);

INSERT INTO predmet
VALUES (2, 'Hrvatski jezik', 1, 2);

INSERT INTO predmet
VALUES (3, 'Engleski jezik', 0, 3);

INSERT INTO predmet
VALUES (4, 'Likovna kultura', 1, 4);

INSERT INTO predmet
VALUES (5, 'Fizika', 1, 5);

INSERT INTO predmet
VALUES (6, 'Geografija', 1, 6);

INSERT INTO predmet
VALUES (7, 'Glazbena kultura', 1, 7);

INSERT INTO predmet
VALUES (8, 'Njemaèki jezik', 0, 8);
----------------------------------------------------------------------------------

INSERT INTO razred
VALUES ('2019/2020', '1.', 'a', 1);

INSERT INTO razred
VALUES ('2019/2020', '1.', 'b', 2);

INSERT INTO razred
VALUES ('2019/2020', '2.', 'a', 3);

INSERT INTO razred
VALUES ('2019/2020', '2.', 'b', 4);

INSERT INTO razred
VALUES ('2019/2020', '3.', 'a', 5);

INSERT INTO razred
VALUES ('2019/2020', '3.', 'b', 6);

INSERT INTO razred
VALUES ('2019/2020', '4.', 'a', 7);

INSERT INTO razred
VALUES ('2019/2020', '4.', 'b', 8);
--------------------------------------------------------------------

INSERT INTO ucenik
VALUES (1, 'Mia', 'Horvat', TO_DATE('03/05/2005', 'dd/mm/yyyy'), 'Z', 'Vlaška 7, 10000, Zagreb', '2019/2020', '1.', 'a');

INSERT INTO ucenik
VALUES (2, 'Luka', 'Lonèar', TO_DATE('21/08/2005', 'dd/mm/yyyy'), 'M', 'Trg bana J. Jelaèiæa 15, 10000, Zagreb', '2019/2020', '1.', 'a');

INSERT INTO ucenik
VALUES (3, 'Marko', 'Kovaè', TO_DATE('04/06/2005', 'dd/mm/yyyy'), 'M', 'A. Hebranga 16, 10000, Zagreb', '2019/2020', '1.', 'b');

INSERT INTO ucenik
VALUES (4, 'Ema', 'Novak', TO_DATE('05/07/2004', 'dd/mm/yyyy'), 'Z', 'Gajeva 30a, 10000, Zagreb', '2019/2020', '2.', 'a');

INSERT INTO ucenik
VALUES (5, 'Filip', 'Lonèar', TO_DATE('06/08/2004', 'dd/mm/yyyy'), 'M', 'Trg bana J. Jelaèiæa 15, 10000, Zagreb', '2019/2020', '2.', 'b');

INSERT INTO ucenik
VALUES (6, 'Lana', 'Horvat', TO_DATE('23/05/2003', 'dd/mm/yyyy'), 'Z', 'Vlaška 7, 10000, Zagreb', '2019/2020', '3.', 'a');

INSERT INTO ucenik
VALUES (7, 'Dora', 'Kovaè', TO_DATE('25/06/2003', 'dd/mm/yyyy'), 'Z', 'A. Hebranga 16, 10000, Zagreb', '2019/2020', '3.', 'b');

INSERT INTO ucenik
VALUES (8, 'Mislav', 'Novak', TO_DATE('27/07/2002', 'dd/mm/yyyy'), 'M', 'Gajeva 30a, 10000, Zagreb', '2019/2020', '4.', 'a');

INSERT INTO ucenik
VALUES (9, 'Tea', 'Lonèar', TO_DATE('16/08/2002', 'dd/mm/yyyy'), 'Z', 'Trg bana J. Jelaèiæa 15, 10000, Zagreb', '2019/2020', '4.', 'b');
------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO pedagoska_mjera
VALUES (1, 'opomena', 'Uèenik kasni na sat.', 8);

INSERT INTO pedagoska_mjera
VALUES (2, 'opomena', 'Uèenica kasni na sat.', 9);

INSERT INTO pedagoska_mjera
VALUES (3, 'opomena', 'Uèenik ima više od tri neopravdana sata.', 2);

INSERT INTO pedagoska_mjera
VALUES (4, 'ukor', 'Uèenik ima više od šest neopravdanih sati.', 2);
-------------------------------------------------------------------------------

INSERT INTO ucenik_roditelj
VALUES (1,1);

INSERT INTO ucenik_roditelj
VALUES (1,2);

INSERT INTO ucenik_roditelj
VALUES (6,1);

INSERT INTO ucenik_roditelj
VALUES (6,2);

INSERT INTO ucenik_roditelj
VALUES (2,7);

INSERT INTO ucenik_roditelj
VALUES (2,8);

INSERT INTO ucenik_roditelj
VALUES (5,7);

INSERT INTO ucenik_roditelj
VALUES (5,8);

INSERT INTO ucenik_roditelj
VALUES (9,7);

INSERT INTO ucenik_roditelj
VALUES (9,8);

INSERT INTO ucenik_roditelj
VALUES (3,3);

INSERT INTO ucenik_roditelj
VALUES (3,4);

INSERT INTO ucenik_roditelj
VALUES (7,3);

INSERT INTO ucenik_roditelj
VALUES (7,4);

INSERT INTO ucenik_roditelj
VALUES (4,5);

INSERT INTO ucenik_roditelj
VALUES (4,6);

INSERT INTO ucenik_roditelj
VALUES (8,5);

INSERT INTO ucenik_roditelj
VALUES (8,6);
---------------------------------------------------------------------------------

INSERT INTO dnevnik
VALUES (1, 5, TO_DATE('12/10/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 1, 1);

INSERT INTO dnevnik
VALUES (2, 4, TO_DATE('12/10/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 2, 1);

INSERT INTO dnevnik
VALUES (3, 3, TO_DATE('12/10/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 3, 1);

INSERT INTO dnevnik
VALUES (4, 5, TO_DATE('14/10/2019', 'dd/mm/yyyy'), 'Usmeni ispit', 4, 2);

INSERT INTO dnevnik
VALUES (5, 3, TO_DATE('14/10/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 5, 2);

INSERT INTO dnevnik
VALUES (6, 5, TO_DATE('22/10/2019', 'dd/mm/yyyy'), 'Domaæa zadaæa', 6, 3);

INSERT INTO dnevnik
VALUES (7, 2, TO_DATE('22/10/2019', 'dd/mm/yyyy'), 'Domaæa zadaæa', 7, 3);

INSERT INTO dnevnik
VALUES (8, 1, TO_DATE('15/11/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 8, 4);

INSERT INTO dnevnik
VALUES (9, 3, TO_DATE('15/11/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 9, 4);

INSERT INTO dnevnik
VALUES (10, 1, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Usmeni ispit', 8, 2);

INSERT INTO dnevnik
VALUES (11, 1, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Usmeni ispit', 9, 2);

INSERT INTO dnevnik
VALUES (12, 5, TO_DATE('30/11/2019', 'dd/mm/yyyy'), 'Pismeni ispit', 1, 1);
------------------------------------------------------------------------------------

INSERT INTO natjecanje
VALUES (1, 'školska', 1, 'Školsko natjecanje iz matematike', 'Zagreb', 1, 1);

INSERT INTO natjecanje
VALUES (2, 'školska', 2, 'Školsko natjecanje iz matematike', 'Zagreb', 2, 1);

INSERT INTO natjecanje
VALUES (3, 'županijska', 1, 'Županijsko natjecanje iz matematike', 'Zagreb', 1, 1);

INSERT INTO natjecanje
VALUES (4, 'državna', 5, 'Državno natjecanje iz matematike', 'Zagreb', 1, 1);
--------------------------------------------------------------------------------------------------------------------------------

INSERT INTO raspored
VALUES (1, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 1, 'U1', 1, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (2, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 2, 'U2', 2, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (3, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 3, 'U3', 3, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (4, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 4, 'U4', 4, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (5, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 5, 'U5', 5, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (6, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 6, 'U6', 6, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (7, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 7, 'U7', 7, '2019/2020', '1.', 'a');

INSERT INTO raspored
VALUES (8, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 1, 'U2', 2, '2019/2020', '1.', 'b');

INSERT INTO raspored
VALUES (9, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 2, 'U1', 1, '2019/2020', '1.', 'b');

INSERT INTO raspored
VALUES (10, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 3, 'U4', 4, '2019/2020', '1.', 'b');

INSERT INTO raspored
VALUES (11, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 4, 'U3', 3, '2019/2020', '1.', 'b');

INSERT INTO raspored
VALUES (12, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 5, 'U6', 6, '2019/2020', '1.', 'b');

INSERT INTO raspored
VALUES (13, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 6, 'U5', 5, '2019/2020', '1.', 'b');

INSERT INTO raspored
VALUES (14, TO_DATE('01/12/2019', 'dd/mm/yyyy'), 'ponedjeljak', 'prijepodnevna', 7, 'U8', 8, '2019/2020', '1.', 'b');
--------------------------------------------------------------------------------------------------------------------------

INSERT INTO izostanak
VALUES (1, 0, 'Uèenik je pobjegao sa sata.', 2, 1);

INSERT INTO izostanak
VALUES (2, 0, 'Uèenik je pobjegao sa sata.', 2, 2);

INSERT INTO izostanak
VALUES (3, 0, 'Uèenik je pobjegao sa sata.', 2, 3);

INSERT INTO izostanak
VALUES (4, 0, 'Uèenik je pobjegao sa sata.', 2, 4);

INSERT INTO izostanak
VALUES (5, 0, 'Uèenik je pobjegao sa sata.', 2, 5);

INSERT INTO izostanak
VALUES (6, 0, 'Uèenik je pobjegao sa sata.', 2, 6);

INSERT INTO izostanak
VALUES (7, 0, 'Uèenik je pobjegao sa sata.', 2, 7);

INSERT INTO izostanak
VALUES (8, 0, 'Uèenik je pobjegao sa sata.', 3, 8);

INSERT INTO izostanak
VALUES (9, 0, 'Uèenik je pobjegao sa sata.', 3, 9);

INSERT INTO izostanak
VALUES (10, 0, 'Uèenik je pobjegao sa sata.', 3, 10);

INSERT INTO izostanak
VALUES (11, 1, 'Uèenica ima pregled kod zubara.', 1, 7);

COMMIT;