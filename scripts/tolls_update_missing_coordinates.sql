-- ============================================================
-- CashTruck - Coordenadas faltantes del catalogo de peajes
--
-- Se ejecuta DESPUES de tolls_schema_and_data_with_coordinates_FINAL.sql,
-- que deja 165 estaciones con 159 georreferenciadas.
--
-- Sin latitude/longitude una estacion no puede emparejarse contra la ruta:
-- el endpoint POST /trip/tolls la excluye y lo informa en warnings. Este
-- script cierra 4 de las 6 que faltan.
--
-- Las coordenadas provienen de cashtruck_tolls_schema_and_data_definitive.sql,
-- que si las trae para estas cuatro estaciones. No son valores estimados.
-- ============================================================

SET NAMES utf8mb4;

START TRANSACTION;

-- Concesion Cordoba - Sucre (INVIAS), via Monteria - Planeta Rica.
UPDATE toll
   SET latitude  = 8.8450400,
       longitude = -75.8244700
 WHERE toll_key = 'LOS GARZONES I'
   AND (latitude IS NULL OR longitude IS NULL);

UPDATE toll
   SET latitude  = 8.8278000,
       longitude = -75.8368000
 WHERE toll_key = 'LOS GARZONES II'
   AND (latitude IS NULL OR longitude IS NULL);

-- Tuneles de La Linea (INVIAS), corredor Armenia - Ibague.
UPDATE toll
   SET latitude  = 4.5237200,
       longitude = -75.5894900
 WHERE toll_key = 'T LA LINEA QUINDIO'
   AND (latitude IS NULL OR longitude IS NULL);

UPDATE toll
   SET latitude  = 4.4453100,
       longitude = -75.5184400
 WHERE toll_key = 'T LA LINEA TOLIMA'
   AND (latitude IS NULL OR longitude IS NULL);

COMMIT;


-- ============================================================
-- CHAPARRAL y RIO GRANDE  ->  ver script aparte
-- ============================================================
-- Estas dos siguen sin coordenadas y se completan en
-- tolls_update_coordinates_chaparral_riogrande.sql, que trae el
-- procedimiento y el cerco de validacion.
--
-- CORRECCION: una version anterior de este archivo dejaba comentado un
-- "UPDATE toll SET active = 0" para ambas, siguiendo la nota del script
-- cashtruck_tolls_schema_and_data_definitive.sql que las daba por
-- historicas y fusionadas en El Tigre. Esa nota esta desactualizada y
-- desactivarlas seria un error: el reporte oficial de la ANI (OETR,
-- corte junio 2026) las reporta recaudando con 95.903 y 103.401
-- vehiculos en el mes, mas que sus vecinas Cirilo y Mutata.
-- ============================================================


-- ============================================================
-- REVISAR TAMBIEN: ETD 10+850
-- ============================================================
-- No es un problema de coordenadas —las tiene— sino de si debe cobrarse.
-- El script definitivo tambien la excluyo, con esta nota:
--
--   "ETD 10+850 excluded: counting station, not a toll station."
--
-- En el catalogo actual esta activa, georreferenciada y con tarifas en las
-- siete categorias, de modo que se va a sumar al total de cualquier viaje por
-- el corredor Rumichaca - Pasto. Si efectivamente es una estacion de conteo:
--
-- UPDATE toll SET active = 0 WHERE toll_key = 'ETD 10 850';


-- ============================================================
-- VERIFICACION
-- ============================================================

SELECT COUNT(*) AS total_estaciones,
       SUM(latitude IS NOT NULL AND longitude IS NOT NULL) AS georreferenciadas,
       SUM(latitude IS NULL OR longitude IS NULL)          AS sin_coordenadas
  FROM toll
 WHERE active = 1;

SELECT toll_key, name, department, municipality
  FROM toll
 WHERE active = 1
   AND (latitude IS NULL OR longitude IS NULL)
 ORDER BY toll_key;
