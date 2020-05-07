CREATE SCHEMA sklep;

-- tables
-- Table: producenci
CREATE TABLE producenci (
    id_producenta int  NOT NULL,
    nazwa_producenta text  NOT NULL,
    mail text  NOT NULL,
    telefon text  NOT NULL,
    CONSTRAINT producenci_pk PRIMARY KEY (id_producenta)
);

-- Table: produkty
CREATE TABLE produkty (
    id_produktu int  NOT NULL,
    nazwa_produktu text  NOT NULL,
    cena int  NOT NULL,
    producenci_id_producenta int  NOT NULL,
    CONSTRAINT produkty_pk PRIMARY KEY (id_produktu)
);

-- Table: zamowienia
CREATE TABLE zamowienia (
    id_zamowienia int  NOT NULL,
    produkty_id_produktu int  NOT NULL,
    data date  NOT NULL,
    CONSTRAINT zamowienia_pk PRIMARY KEY (id_zamowienia)
);

-- foreign keys
-- Reference: produkty_producenci (table: produkty)
ALTER TABLE produkty ADD CONSTRAINT produkty_producenci
    FOREIGN KEY (producenci_id_producenta)
    REFERENCES producenci (id_producenta)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: zamowienia_produkty (table: zamowienia)
ALTER TABLE zamowienia ADD CONSTRAINT zamowienia_produkty
    FOREIGN KEY (produkty_id_produktu)
    REFERENCES produkty (id_produktu)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

INSERT INTO producenci VALUES ('1', 'Kaskada','kaskada@gmail.com','549112093'),('2', 'Lemoniade','lemoniade@gmail.com','661098257'),('3', 'LPP','lpp@gmail.com','762299800'),('4', 'New_Look','newlook@gmail.com','663096278'),('5', 'Lasocki','lasocki@gmail.com','889536764'),('6', 'Nike','nike@gmail.com','633097251'),('7', 'Puma','puma@gmail.com','734009745'),('8', 'Timberland','timberland@gmail.com','837251684'),('9', 'Vans','vans@gmail.com','786904539'),('10', 'Wojas','wojas@gmail.com','675987910');
INSERT INTO produkty VALUES ('1', 'półbuty','130','5'),('2', 'sandały','180','5'),('3', 'kozaki','250','10'),('4', 'klapki','80','7'),('5', 'buty sportowe','160','6'),('6', 'botki','450','8'),('7', 'tenisówki','240','9'),('8', 'sukienka','320','1'),('9', 'sweter','200','2'),('10', 'spodnie','100','3'),('11', 'bluza','150','2'),('12', 'spódnica','120','4');
INSERT INTO zamowienia VALUES ('1','1', '2020-01-10'),('2','2','2020-01-11'),('3','3', '2020-01-11'),('4','4','2020-02-11'),('5','5', '2020-02-28'),('6','6','2020-02-28'),('7','7', '2020-03-03'),('8','8','2020-03-05'),('9','9', '2020-03-10'),('10','10','2020-03-10'),('11','11', '2020-03-13'),('12','12','2020-03-14'),('13','3', '2020-03-14'),('14','4','2020-03-20'),('15','12', '2020-03-21'),('16','6','2020-03-22'),('17','1', '2020-03-23'),('18','10','2020-03-23'),('19','11', '2020-03-23'),('20','3','2020-03-24');

select producenci.nazwa_producenta as "Producent", Count(zamowienia.id_zamowienia) as "Liczba zamówień", SUM(produkty.cena) as "Wartość zamówień" from producenci, zamowienia, produkty where produkty.id_produktu=zamowienia.produkty_id_produktu and producenci.id_producenta=produkty.producenci_id_producenta group by producenci.nazwa_producenta; --11a

select produkty.nazwa_produktu as "Produkt", Count(zamowienia.id_zamowienia) as "Liczba zamówień produktu" from produkty, zamowienia where produkty.id_produktu=zamowienia.produkty_id_produktu group by produkty.nazwa_produktu; --11b


alter table zamowienia rename COLUMN produkty_id_produktu to id_produktu; --zmiana nazwy kolumny do użycia NATURAL JOIN
select * from produkty natural join zamowienia; --11c

select * from zamowienia where extract(MONTH from data)=01; --11e

select extract(DOW from zamowienia.data) as "Nr dnia tygodnia", Count(zamowienia.id_zamowienia) as "Ilość zamówień" from zamowienia group by extract(DOW from zamowienia.data) order by count(zamowienia.id_zamowienia) desc;--11f

select produkty.nazwa_produktu, Count(zamowienia.id_zamowienia) as "Ilość zamówień" from produkty, zamowienia where produkty.id_produktu=zamowienia.id_produktu  group by produkty.nazwa_produktu order by count(zamowienia.id_zamowienia) desc limit 1; --11g

SELECT 'Produkt '::text || UPPER(produkty.nazwa_produktu) || ', którego producentem jest '::text || lower(producenci.nazwa_producenta) || ' zamówiono '::text || Count(zamowienia.id_zamowienia)::text
|| ' razy.'::text as "opis" FROM produkty, producenci, zamowienia where produkty.id_produktu=zamowienia.id_produktu and producenci.id_producenta=produkty.producenci_id_producenta
group by produkty.nazwa_produktu, producenci.nazwa_producenta
order by count(zamowienia.id_zamowienia) desc; --12a

select zamowienia.*, produkty.cena from zamowienia, produkty where produkty.id_produktu=zamowienia.id_produktu order by produkty.cena desc limit (20-3); --12b

------------------------------12c
CREATE TABLE klienci (
    id_klienta int  NOT NULL,
    e_mail text  NOT NULL,
    telefon text  NOT NULL,
    CONSTRAINT klienci_pk PRIMARY KEY (id_klienta)
);

alter table zamowienia add column klienci_id_klienta int;

-- Reference: zamowienia_klienci (table: zamowienia)
ALTER TABLE zamowienia ADD CONSTRAINT zamowienia_klienci
    FOREIGN KEY (klienci_id_klienta)
    REFERENCES klienci (id_klienta)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

insert into klienci values ('1', 'jankowalski@gmail.com', '759349771'), ('2', 'agnieszka_nowak@gmail.com', '657149528'),
('3', 'jakub.winiarski@gmail.com', '529175931'), ('4','krzysztofwielki@gmail.com', '697113584'), ('5', 'w.zima@gmail.com', '203700895'),('6', 'marzenapiwonska@gmail.com', '531785049'),('7', 'jadwiga.zajac@wp.pl', '889221746'), ('8','martyna_rutkowska@onet.pl', '605971003'), ('9', 'z_kinel@gmail.com', '870694110'),('10', 'borkowski_pawel@gmail.com', '756100894');

update zamowienia set klienci_id_klienta=1 where id_zamowienia=1;
update zamowienia set klienci_id_klienta=2 where id_zamowienia=2;
update zamowienia set klienci_id_klienta=3 where id_zamowienia=3;
update zamowienia set klienci_id_klienta=7 where id_zamowienia=4;
update zamowienia set klienci_id_klienta=5 where id_zamowienia=5;
update zamowienia set klienci_id_klienta=5 where id_zamowienia=6;
update zamowienia set klienci_id_klienta=7 where id_zamowienia=7;
update zamowienia set klienci_id_klienta=8 where id_zamowienia=8;
update zamowienia set klienci_id_klienta=9 where id_zamowienia=9;
update zamowienia set klienci_id_klienta=10 where id_zamowienia=10;
update zamowienia set klienci_id_klienta=10 where id_zamowienia=11;
update zamowienia set klienci_id_klienta=9 where id_zamowienia=12;
update zamowienia set klienci_id_klienta=8 where id_zamowienia=13;
update zamowienia set klienci_id_klienta=7 where id_zamowienia=14;
update zamowienia set klienci_id_klienta=3 where id_zamowienia=15;
update zamowienia set klienci_id_klienta=4 where id_zamowienia=16;
update zamowienia set klienci_id_klienta=10 where id_zamowienia=17;
update zamowienia set klienci_id_klienta=9 where id_zamowienia=18;
update zamowienia set klienci_id_klienta=6 where id_zamowienia=19;
update zamowienia set klienci_id_klienta=1 where id_zamowienia=20;

select klienci.id_klienta, produkty.nazwa_produktu, SUM(produkty.cena) as "wartość zamówienia" from zamowienia, produkty, klienci where produkty.id_produktu=zamowienia.id_produktu and klienci.id_klienta=zamowienia.klienci_id_klienta group by klienci.id_klienta, produkty.nazwa_produktu order by klienci.id_klienta;--12e

select klienci.id_klienta as "Najczęściej zamawiający", klienci.e_mail, klienci.telefon, count(zamowienia.id_zamowienia), SUM(produkty.cena) as "wartość zamówienia" from klienci, zamowienia, produkty where klienci.id_klienta=zamowienia.klienci_id_klienta and produkty.id_produktu=zamowienia.id_produktu group by klienci.id_klienta order by count(zamowienia.id_zamowienia) desc limit 3; --12f NAJCZĘŚCIEJ

select klienci.id_klienta as "Najrzadziej zamawiający", klienci.e_mail, klienci.telefon, count(zamowienia.id_zamowienia),SUM(produkty.cena) as "wartość zamówienia" from klienci, zamowienia, produkty where klienci.id_klienta=zamowienia.klienci_id_klienta and produkty.id_produktu=zamowienia.id_produktu group by klienci.id_klienta order by count(zamowienia.id_zamowienia) asc limit 3; --12f NAJRZADZIEJ


CREATE TABLE numer (
	liczba bigint NOT null primary key
);--13a

CREATE SEQUENCE liczba_seq AS BIGINT START WITH 100 minvalue 0 maxvalue 125 INCREMENT BY 5 cycle; --13b

alter sequence liczba_seq increment by 6;--13d

DROP SEQUENCE IF EXISTS liczba_seq;--13f

select * from pg_user;--14a

create user Superuser299619 with SUPERUSER;
create user guest299619;
GRANT ALL on all tables in schema sklep to superuser299619;
GRANT SELECT on all tables in schema sklep to guest299619;
select * from pg_user;--14b

--14c
alter user Superuser299619 rename to student;
revoke ALL on all tables in schema sklep from student;
GRANT SELECT on all tables in schema sklep to student;
revoke ALL on all tables in schema sklep from guest299619;
drop user guest299619;
select * from pg_user;

BEGIN transaction;
UPDATE produkty SET cena = cena + '10'::int;
COMMIT transaction;--15a

begin transaction;
update produkty set cena = cena + (cena/100)*10 where id_produktu =3;
savepoint s1;
update produkty set cena = cena + (cena/100)*25 where id_produktu !=3;
savepoint s2;
commit transaction;

-- End of file.