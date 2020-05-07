CREATE database s299619;
create SCHEMA firma;
CREATE ROLE ksiegowosc;

GRANT SELECT on all tables in schema firma to ksiegowosc;

-- tables
-- Table: godziny
CREATE TABLE godziny (
    id_godziny int  NOT NULL,
    data date  NOT NULL,
    liczba_godzin int  NOT NULL,
    pracownicy_id_pracownika int  NOT NULL,
    CONSTRAINT godziny_pk PRIMARY KEY (id_godziny)
);

-- Table: pensja_stanowisko
CREATE TABLE pensja_stanowisko (
    id_pensji int  NOT NULL,
    stanowisko text  NOT NULL,
    kwota int  NOT NULL,
    CONSTRAINT pensja_stanowisko_pk PRIMARY KEY (id_pensji)
);

-- Table: pracownicy
CREATE TABLE pracownicy (
    id_pracownika int  NOT NULL,
    imie text  NOT NULL,
    nazwisko text  NOT NULL,
    adres text  NOT NULL,
    telefon int  NOT NULL,
    CONSTRAINT pracownicy_pk PRIMARY KEY (id_pracownika)
);

comment on table pracownicy is 'Pracownicy naszej firmy.';

-- Table: premia
CREATE TABLE premia (
    id_premii int  NOT NULL,
    rodzaj text  NOT NULL,
    kwota int  NULL,
    CONSTRAINT premia_pk PRIMARY KEY (id_premii)
);

-- Table: wynagrodzenie
CREATE TABLE wynagrodzenie (
    id_wynagrodzenia int  NOT NULL,
    data date  NOT NULL,
    pracownicy_id_pracownika int  NOT NULL,
    godziny_id_godziny int  NOT NULL,
    pensja_stanowisko_id_pensji int  NOT NULL,
    premia_id_premii int  NOT NULL,
    CONSTRAINT wynagrodzenie_pk PRIMARY KEY (id_wynagrodzenia)
);

create index "nazwisko" on pracownicy (nazwisko ASC);

-- foreign keys
-- Reference: godziny_pracownicy (table: godziny)
ALTER TABLE godziny ADD CONSTRAINT godziny_pracownicy
    FOREIGN KEY (pracownicy_id_pracownika)
    REFERENCES pracownicy (id_pracownika)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: wynagrodzenie_godziny (table: wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_godziny
    FOREIGN KEY (godziny_id_godziny)
    REFERENCES godziny (id_godziny)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: wynagrodzenie_pensja_stanowisko (table: wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_pensja_stanowisko
    FOREIGN KEY (pensja_stanowisko_id_pensji)
    REFERENCES pensja_stanowisko (id_pensji)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: wynagrodzenie_pracownicy (table: wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_pracownicy
    FOREIGN KEY (pracownicy_id_pracownika)
    REFERENCES pracownicy (id_pracownika)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: wynagrodzenie_premia (table: wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_premia
    FOREIGN KEY (premia_id_premii)
    REFERENCES premia (id_premii)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

insert into pracownicy values ('1','Jan','Kowalski','Warszawa ul.Blokowa 20/2','759349771');
insert into pracownicy values ('2','Agnieszka','Nowak','Warszawa ul.Wyborna 98/134','657149528'),
('3','Jakub','Winiarski','Warszawa ul.Bajeczna 2/8','529175931'),
('4','Krzysztof','Wielki','Warszawa ul.Chojnowska 11/9','889221746'),
('5','Witold','Zima','Warszawa ul.Deszczowa 97/12','697113584'),
('6','Marzena','Piwońska','Warszawa ul.Zamiejska 45/4','203700895'),
('7','Jadwiga','Zając','Warszawa ul.Trocka 36/88','531785049'),
('8','Martyna','Rutkowska','Warszawa ul.Blokowa 258/3','605971003'),
('9','Zbigniew','Kinel','Warszawa ul.Mokra 7/90','870694110'),
('10','Paweł','Borkowski','Warszawa ul.Trocka 87/2','756100894');

insert into pensja_stanowisko values ('1','Księgowa','3100'),('2','Dyrektor','10000'),('3','Kierownik','9000'),
('4','Sekretarka','3300'),('5','Dyrektor HR','3000'),('6','Kierownik Produkcji','5500'),('7','Prezes Zarządu','9500'),
('8','IT Manager','7600'),('9','Lider Zespołu','6900'),('10','Kierownik Działu Technicznego','5500');

insert into premia values ('1','Uznaniowa','200'),('2','Regulaminowa','300'),('3','Brak','0'),
('4','Nadgodziny','200'),('5','Bezwypadkowa praca','500'),('6','Terminowe wykonanie zadania','400'),
('7','Przedterminowe wykonanie zadania','600'),('8','Roczna','2000'),
('9','Opcyjna','100'),('10','kompensacyjna','350');

insert into godziny values ('1', '2020-03-10','45','5');
insert into godziny values ('2', '2020-02-10','35','1'),('3', '2020-02-10','38','2'),('4', '2020-02-10','45','3'),
('5', '2020-02-10','50','4'),('6', '2020-02-10','45','6'),('7', '2020-02-10','40','7'),('8', '2020-02-10','20','8'),
('9', '2020-02-10','35','9'),('10', '2020-02-10','38','10');

insert into wynagrodzenie values ('1','2020-03-10','1','1','10','7'),
('2','2020-03-10','2','2','9','9'),('3','2020-03-10','3','3','8','6'),
('4','2020-03-10','4','4','7','1'),('5','2020-03-10','5','5','6','4'),
('6','2020-03-10','6','6','5','10'),('7','2020-03-10','7','7','4','8'),
('8','2020-03-10','8','8','1','3'),('9','2020-03-10','9','9','2','5'),
('10','2020-03-10','10','10','3','2');

ALTER TABLE godziny ADD miesiac int NULL;
ALTER TABLE godziny ADD tydzien int NULL;
update godziny set tydzien=extract(WEEK from data);
update godziny set miesiac=extract(MONTH from data); --5a

ALTER TABLE firma.wynagrodzenie ALTER COLUMN "data" TYPE text USING "data"::text;--5b

SELECT id_pracownika, nazwisko FROM pracownicy;--6a

SELECT pracownicy.id_pracownika FROM pracownicy, wynagrodzenie, pensja_stanowisko WHERE pensja_stanowisko.kwota>1000 
AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji; --6b

SELECT pracownicy.id_pracownika FROM pracownicy, wynagrodzenie, premia, pensja_stanowisko WHERE pensja_stanowisko.kwota>2000 AND premia.rodzaj='Brak' AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji AND premia.id_premii=wynagrodzenie.premia_id_premii; --6c

SELECT * FROM pracownicy WHERE imie LIKE 'J%'; --6d

SELECT * FROM pracownicy WHERE nazwisko LIKE '%n%' AND imie LIKE '%a'; --6e

SELECT pracownicy.imie, pracownicy.nazwisko, 4*godziny.liczba_godzin-160 FROM pracownicy, godziny WHERE 4*godziny.liczba_godzin>160 AND pracownicy.id_pracownika=godziny.pracownicy_id_pracownika;--6f

SELECT pracownicy.imie, pracownicy.nazwisko FROM pracownicy, pensja_stanowisko, wynagrodzenie  WHERE pensja_stanowisko.kwota BETWEEN 1500 AND 3000 AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji;--6g

SELECT pracownicy.imie, pracownicy.nazwisko FROM pracownicy, godziny, premia, wynagrodzenie WHERE 4*godziny.liczba_godzin>160 AND premia.rodzaj='Brak' and pracownicy.id_pracownika=godziny.pracownicy_id_pracownika and premia.id_premii=wynagrodzenie.premia_id_premii and pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika;--6h

SELECT pracownicy.* FROM pracownicy, wynagrodzenie, pensja_stanowisko WHERE pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji ORDER BY pensja_stanowisko.kwota asc; --7a

SELECT pracownicy.imie, pracownicy.nazwisko, pensja_stanowisko.kwota, premia.kwota, pensja_stanowisko.kwota+premia.kwota FROM pracownicy, pensja_stanowisko, wynagrodzenie, premia WHERE pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika and premia.id_premii=wynagrodzenie.premia_id_premii ORDER BY pensja_stanowisko.kwota+premia.kwota desc; --7b

SELECT pensja_stanowisko.stanowisko, Count(*) as "Liczba pracownikow" FROM pracownicy, pensja_stanowisko, wynagrodzenie WHERE pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika group by pensja_stanowisko.stanowisko; --7c

SELECT AVG(kwota) AS "Srednia pensja", MIN(kwota) as "Min pensja", MAX(kwota) as "Max pensja" FROM pensja_stanowisko WHERE stanowisko like '%Kierownik%'; --7d

select SUM(kwota) as "Suma wynagrodzen" from pensja_stanowisko; --7e

select SUM(kwota) as "Suma wynagrodzen" from pensja_stanowisko where stanowisko like '%Kierownik%'; --7f

select Count(premia.id_premii) as "Liczba premii" from premia, pensja_stanowisko, wynagrodzenie where pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji AND premia.id_premii=wynagrodzenie.premia_id_premii and stanowisko like '%Kierownik%'; --7g

select Count(premia.id_premii) as "Liczba premii" from premia, pensja_stanowisko, wynagrodzenie where pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji AND premia.id_premii=wynagrodzenie.premia_id_premii group by pensja_stanowisko.stanowisko; --7g inaczej

delete from pracownicy using pensja_stanowisko, wynagrodzenie where pracownicy.id_pracownika=wynagrodzenie.id_pracownika and pensja_stanowisko.id_pensji=wynagrodzenie.id_pensji and pensja_stanowisko.kwota < 1200; --7h

ALTER TABLE firma.pracownicy ALTER COLUMN telefon TYPE text USING telefon::text;
update pracownicy set telefon='(+48)'::text || telefon; --8a

UPDATE pracownicy SET telefon=CONCAT(SUBSTRING(telefon, 1, 9), '-', SUBSTRING(telefon, 10, 3), '-', SUBSTRING(telefon, 13, 3)); --8b

SELECT UPPER(nazwisko) FROM pracownicy as "nazwisko klienta" WHERE LENGTH(nazwisko) =(SELECT MAX(LENGTH(pracownicy.nazwisko)) FROM pracownicy); --8c

select md5(pracownicy.imie) as "imie", md5(pracownicy.nazwisko) as "nazwisko", md5(pracownicy.adres) as "adres", md5(pracownicy.telefon) as "telefon", md5(cast(pensja_stanowisko.kwota as varchar(20))) as "pensja" from pracownicy join wynagrodzenie on wynagrodzenie.id_pracownika=pracownicy.id_pracownika join pensja_stanowisko on pensja_stanowisko.id_pensji=wynagrodzenie.id_pensji; --8d

SELECT 'Pracownik '::text || pracownicy.imie || ' ' || pracownicy.nazwisko || ', w dniu '::text || wynagrodzenie."data" || ' otrzymał pensję całkowitą na kwotę '::text || (pensja_stanowisko.kwota+premia.kwota)::text || ', gdzie wynagrodzenie zasadnicze wynosiło: ' || pensja_stanowisko.kwota::text || ', premia: ' || premia.kwota::text || '.' as "Raport koncowy" FROM pracownicy, wynagrodzenie, pensja_stanowisko, premia where pracownicy.id_pracownika = wynagrodzenie.pracownicy_id_pracownika and pensja_stanowisko.id_pensji = wynagrodzenie.pensja_stanowisko_id_pensji and wynagrodzenie.premia_id_premii = premia.id_premii group by pracownicy.imie, pracownicy.nazwisko, wynagrodzenie.data, pensja_stanowisko.kwota, premia.kwota;
--9


-- End of file.
