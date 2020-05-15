--zad1
--Właściwości warstwy trees->Styl->Wartość unikalna->VEGDESC->Wybrano paletę kolorów (odcienie zieleni)->Klasyfikuj->OK
SELECT SUM(trees.AREA_KM2) AS pole_mieszane FROM trees WHERE VEGDESC='Mixed Trees';
--pole_mieszane = 189273,33

--zad2
--Wektor->Narzędzia zarządzania danymi->Podziel warstwę wektorową->Pole z unikalnym ID->VEGDESC

--zad3
SELECT SUM(ST_Length(railroads.Geometry)) AS dl_kolei FROM regions, railroads WHERE regions.NAME_2='Matanuska-Susitna';
--2768932,0458

--zad4
SELECT AVG(ELEV) AS sr_wys FROM airports WHERE USE='Military';
--średnia wysokość wynosi 593,25
SELECT COUNT(*) AS il_militarnych FROM airports WHERE USE='Military';--8 lotnisk

SELECT COUNT(*) AS il_militarnych FROM airports WHERE USE='Military' AND ELEV>1400;
--1 lotnisko

DELETE FROM airports WHERE USE='Military' AND ELEV>1400;


--zad5
SELECT COUNT(*) AS il_budynkow FROM popp, regions WHERE regions.NAME_2='Bristol Bay' AND popp.F_CODEDESC='Building' AND Contains(regions.geometry, popp.geometry);
--Takich budynków jest 5.

SELECT COUNT(*) AS il_budynkow2 FROM popp, regions, rivers WHERE popp.F_CODEDESC='Building' AND regions.NAME_2='Bristol Bay' AND ST_Contains(ST_Buffer(rivers.Geometry,100000), popp.Geometry) AND ST_Contains(regions.geometry, popp.geometry);


--zad6
SELECT COUNT(*) FROM majrivers, railroads WHERE ST_Intersects(majrivers.Geometry, railroads.Geometry);--rzeki przecinają się w 5 miejscach

--zad7
--Wektor->Narzędzia geometrii->Wydobądź wierzchołki
--Dla warstwy railroads jest 662 wierzchołków.

--zad8
SELECT re.NAME_2 FROM regions re, airports a, railroads ra WHERE ST_Distance(a.Geometry, re.Geometry)<100000 AND ST_Distance(ra.Geometry, re.Geometry)>=50000 LIMIT 1;
--Najlepszy region to "Aleutians East".


--zad9
--Wektor->Narzędzia geometrii->Uprość geometrię->Ustawiono tolerancję na 100 i zapisano jako swamps_100

--pole przed uproszczeniem
SELECT SUM(AREAKM2) AS pole_przed FROM swamp;
--pole po uproszczeniu
SELECT SUM(AREAKM2) AS pole_po FROM swamp_100;
--Pole powierzchni nie zmieniło się.
--Dla swamps jest 7469 wierzchołków, a dla swamps_100 (po uproszczeniu) jest 6661 wierzchołków
