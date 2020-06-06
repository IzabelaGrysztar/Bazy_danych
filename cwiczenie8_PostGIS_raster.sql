ALTER SCHEMA schema_name RENAME TO grysztar;

--przykład 1
--cmd
--"C:\Program Files\PostgreSQL\12\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d "C:\Users\Izabela\Desktop\BD i GIS\8\rasters\srtm_1arc_v3.tif" rasters.dem > "C:\Users\Izabela\Desktop\BD i GIS\8\rasters\dem.sql"
CREATE EXTENSION postgis_raster;

--przykład 2
--cmd
--"C:\Program Files\PostgreSQL\12\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d "C:\Users\Izabela\Desktop\BD i GIS\8\rasters\srtm_1arc_v3.tif" rasters.dem | psql -d raster -h localhost -U postgres -p 5432

--przykład 3
--cmd
--"C:\Program Files\PostgreSQL\12\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 128x128 -I -C -M -d "C:\Users\Izabela\Desktop\BD i GIS\8\rasters\Landsat8_L1TP_RGBN.TIF" rasters.landsat8 | psql -d raster -h localhost -U postgres -p 5432

--Przykład 1 - ST_Intersects
CREATE TABLE grysztar.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

--dodanie serial primary key:
alter table grysztar.intersects
add column rid SERIAL PRIMARY KEY;
--utworzenie indeksu przestrzennego:
CREATE INDEX idx_intersects_rast_gist ON grysztar.intersects
USING gist (ST_ConvexHull(rast));
--dodanie raster constraints:
-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('grysztar'::name, 'intersects'::name,'rast'::name);


--Przykład 2 - ST_Clip
CREATE TABLE grysztar.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--Przykład 3 - ST_Union
CREATE TABLE grysztar.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

-------------------
--Przykład 1 - ST_AsRaster
CREATE TABLE grysztar.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przykład 2 - ST_Union
DROP TABLE grysztar.porto_parishes; --> drop table porto_parishes first
CREATE TABLE grysztar.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przykład 3 - ST_Tile
DROP TABLE grysztar.porto_parishes; --> drop table porto_parishes first
CREATE TABLE grysztar.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Przykład 1 - ST_Intersection
create table grysztar.intersection as
SELECT a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przykład 2 - ST_DumpAsPolygons
CREATE TABLE grysztar.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przykład 1 - ST_Band
CREATE TABLE grysztar.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--Przykład 2 - ST_Clip
CREATE TABLE grysztar.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Przykład 3 - ST_Slope
CREATE TABLE grysztar.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM grysztar.paranhos_dem AS a;

--Przykład 4 - ST_Reclass
CREATE TABLE grysztar.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM grysztar.paranhos_slope AS a;

--Przykład 5 - ST_SummaryStats
SELECT st_summarystats(a.rast) AS stats
FROM grysztar.paranhos_dem AS a;

--Przykład 6 - ST_SummaryStats oraz Union
SELECT st_summarystats(ST_Union(a.rast))
FROM grysztar.paranhos_dem AS a;

--Przykład 7 - ST_SummaryStats z lepszą kontrolą złożonego typu danych
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM grysztar.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--Przykład 8 - ST_SummaryStats w połączeniu z GROUP BY
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--Przykład 9 - ST_Value
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--Przykład 10 - ST_TPI
create table grysztar.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;
--indeks przestrzenny:
CREATE INDEX idx_tpi30_rast_gist ON grysztar.tpi30
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów:
SELECT AddRasterConstraints('grysztar'::name, 'tpi30'::name,'rast'::name);

--problem samodzielny
create table grysztar.tpi30_porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'
--Dodanie indeksu przestrzennego:
CREATE INDEX idx_tpi30_porto_rast_gist ON grysztar.tpi30_porto
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów:
SELECT AddRasterConstraints('grysztar'::name, 'tpi30_porto'::name,'rast'::name);

--Przykład 1 - Wyrażenie Algebry Map
CREATE TABLE grysztar.porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
) AS rast
FROM r;
--indeks przestrzenny
CREATE INDEX idx_porto_ndvi_rast_gist ON grysztar.porto_ndvi
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów
SELECT AddRasterConstraints('grysztar'::name, 'porto_ndvi'::name,'rast'::name);

--Przykład 2 – Funkcja zwrotna
create or replace function grysztar.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE grysztar.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'grysztar.ndvi(double precision[], integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;
--Dodanie indeksu przestrzennego:
CREATE INDEX idx_porto_ndvi2_rast_gist ON grysztar.porto_ndvi2
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów:
SELECT AddRasterConstraints('grysztar'::name, 'porto_ndvi2'::name,'rast'::name);

----------------
--Eksport danych

--Przykład 1 - ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM grysztar.porto_ndvi;

--lista formatów obsługiwanych przez bibliotekę
SELECT ST_GDALDrivers();

--Przykład 2 - ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM grysztar.porto_ndvi;

--Przykład 3 - Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM grysztar.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'C:\myraster.tiff') --> Save the file
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.

--Przykład 4 - Użycie Gdal
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 PG:"host=localhost port=5432 dbname=postgis_raster user=postgres password=postgis schema=grysztar table=porto_ndvi mode=2" porto_ndvi.tiff

--Przykład 1 - Mapfile
MAP
	NAME 'map'
	SIZE 800 650
	STATUS ON
	EXTENT -58968 145487 30916 206234
	UNITS METERS
	
	WEB
		METADATA
			'wms_title' 'Terrain wms'
			'wms_srs' 'EPSG:3763 EPSG:4326 EPSG:3857'
			'wms_enable_request' '*'
			'wms_onlineresource' 
		'http://54.37.13.53/mapservices/srtm'
		END
	end
	
	PROJECTION
		'init=epsg:3763'
	end
	
	LAYER
		NAME srtm
		TYPE raster
		STATUS OFF
		DATA "PG:host=localhost port=5432 dbname='raster' user='sasig' password='postgis' schema='rasters' table='dem' mode='2'"
		PROCESSING "SCALE=AUTO"
		PROCESSING "NODATA=-32767"
		OFFSITE 0 0 0
		METADATA
			'wms_title' 'srtm'
		END
	END
END



