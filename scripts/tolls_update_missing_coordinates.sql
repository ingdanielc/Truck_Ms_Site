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
-- PENDIENTES: CHAPARRAL y RIO GRANDE
-- ============================================================
-- Estas dos estaciones siguen sin coordenadas y NO se completan aqui a
-- proposito: ninguna de las dos fuentes cargadas las trae, y ubicarlas a ojo
-- por el casco urbano de su municipio las dejaria a decenas de kilometros del
-- punto real. Con una tolerancia de 2 km eso no solo no las haria aparecer en
-- su ruta, sino que podria pegarlas a una via vecina y cobrar un peaje que el
-- camion no cruza. Un NULL se excluye y se reporta; una coordenada equivocada
-- cobra de mas en silencio.
--
-- Ademas hay una duda de vigencia previa a la de las coordenadas. El script
-- cashtruck_tolls_schema_and_data_definitive.sql excluyo ambas estaciones a
-- proposito, con esta nota:
--
--   "CHAPARRAL and RIO GRANDE are intentionally excluded because they are
--    historical stations associated with the former unidirectional collection
--    arrangement; the replacement/merged arrangement is represented by El Tigre."
--
-- El catalogo actual no tiene ninguna estacion 'EL TIGRE', asi que esa fusion
-- no esta representada. Antes de geolocalizarlas conviene confirmar con la ANI
-- si siguen recaudando.
--
-- Si se confirma que ya no operan, lo correcto es desactivarlas en vez de
-- darles coordenadas: findActiveGeoReferenced() solo mira estaciones activas,
-- asi que dejan de contarse tanto en el emparejamiento como en el aviso de
-- catalogo incompleto. Descomentar solo tras esa confirmacion:
--
-- UPDATE toll SET active = 0 WHERE toll_key IN ('CHAPARRAL', 'RIO GRANDE');


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
