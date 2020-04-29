--zad4
SELECT count(*) AS liczba_budynkow FROM popp p, majrivers m WHERE Contains(Buffer(m.Geometry,100000), p.Geometry);

CREATE TABLE tableB (
ID INTEGER PRIMARY KEY,
budynki text
);

INSERT INTO tableB (budynki) SELECT F_CODEDESC FROM popp p, majrivers m WHERE Contains(Buffer(m.Geometry,100000), p.Geometry);

SELECT * FROM tableB;


--zad5
CREATE TABLE airportsNew AS SELECT NAME, Geometry, ELEV FROM airports;

--5a
--najbardziej na zachód
SELECT NAME, Geometry FROM airportsNew ORDER BY MbrMinY(Geometry)asc limit 1;
--najbardziej na wschód
SELECT NAME, Geometry FROM airportsNew ORDER BY MbrMaxY(Geometry)desc limit 1;

--5b
INSERT INTO airportsNew VALUES ('airportB', 
(0.5*ST_Distance((SELECT Geometry FROM airportsNew 
WHERE NAME='NOATAK'),(SELECT Geometry FROM airportsNew 
WHERE NAME='NIKOLSKI AS') 
)),
(0.5*((SELECT ELEV FROM airportsNew 
WHERE NAME='NOATAK')+(SELECT ELEV FROM airportsNew 
WHERE NAME='NIKOLSKI AS'))) );

--zad6
SELECT Area(Buffer((ShortestLine(lakes.Geometry, airports.Geometry)),1000)) FROM lakes, airports WHERE lakes.NAMES='Iliamma Lake' AND airports.NAME='AMBLER';
--funkcja ShortestLine() nie jest widoczna w sqlite. W tym zadaniu można również użyć Distance().

--zad7
SELECT SUM(trees.AREA_KM2) AS sum_pole FROM tundra, swamp, trees WHERE Intersects(tundra.Geometry, trees.Geometry) OR Intersects(swamp.Geometry, trees.Geometry);








