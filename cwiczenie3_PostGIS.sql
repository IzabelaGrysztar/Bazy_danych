CREATE EXTENSION postgis;
create schema mapa;
-- tables
-- Table: budynki
CREATE TABLE budynki (
    id int  NOT NULL,
    geometria geometry  NOT NULL,
    nazwa varchar(20)  NOT NULL,
    wysokosc int  NOT NULL,
    CONSTRAINT budynki_pk PRIMARY KEY (id)
);

-- Table: drogi
CREATE TABLE drogi (
    id int  NOT NULL,
    geometria geometry  NOT NULL,
    nazwa varchar(20)  NOT NULL,
    CONSTRAINT drogi_pk PRIMARY KEY (id)
);

-- Table: pktinfo
CREATE TABLE pktinfo (
    id int  NOT NULL,
    geometria geometry  NOT NULL,
    nazwa varchar(20)  NOT NULL,
    liczprac int  NOT NULL,
    CONSTRAINT pktinfo_pk PRIMARY KEY (id)
);


insert into budynki(id, geometria, nazwa, wysokosc) values ('1',ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))',-1), 'BuildingC','8'), ('2',ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))',-1) ,'BuildingB','9'),('3',ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))',-1), 'BuildingD','6'),
('4',ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))',-1),'BuildingF','6'),('5',ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))',-1),'BuildingA','11');

insert into drogi values ('1',ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)',-1), 'RoadY'), ('2',ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',-1) ,'RoadX');

insert into pktinfo values ('1', ST_GeomFromText('POINT(6 9.5)',-1), 'K', '1'), ('2', ST_GeomFromText('POINT(6.5 6)',-1) ,'J', '2'), ('3', ST_GeomFromText('POINT(9.5 6)',-1), 'I', '3'),
('4', ST_GeomFromText('POINT(1 3.5)',-1), 'G', '4'), ('5', ST_GeomFromText('POINT(5.5 1.5)',-1), 'H', '5');

--zad1
select SUM(ST_Length(geometria)) as CalkowitaDl from drogi;

--zad2
SELECT geometria as WKT, ST_Area(geometria) as PolePowierzchni, ST_Perimeter(geometria) as Obwod FROM budynki WHERE nazwa='BuildnigA';

--zad3
SELECT nazwa, ST_Area(geometria) as PolePowierzchni FROM budynki order by nazwa asc;

--zad4
SELECT nazwa, ST_Perimeter(geometria) as Obwod FROM budynki order by ST_Area(geometria) desc limit 2;

--zad5
select ST_Distance(budynki.geometria, pktinfo.geometria) from budynki, pktinfo where budynki.nazwa='BuildingC' and pktinfo.nazwa='G'; 

--zad6
select ST_Area(ST_Difference(geometria, (select ST_Buffer(geometria, 0.5, 'join=mitre') from budynki where nazwa='BuildingB'))) as Pole_pow from budynki where budynki.nazwa='BuildingC';

--zad7
select budynki.nazwa from budynki, drogi where ST_Centroid(budynki.geometria)|>>drogi.geometria and drogi.nazwa='RoadX';

--zad8
select ST_Area(ST_SymDifference(budynki.geometria, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) as Pole_pow from budynki where budynki.nazwa='BuildingC';

-- End of file.