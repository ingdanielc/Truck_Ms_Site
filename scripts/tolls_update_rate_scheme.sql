-- ============================================================
-- CashTruck - Escala tarifaria por estacion de peaje
--
-- Se ejecuta DESPUES de:
--   1. tolls_schema_and_data_with_coordinates_FINAL.sql
--   2. tolls_update_missing_coordinates.sql
--
-- En Colombia conviven dos escalas de categorias y el mismo numero romano
-- cobra cosas distintas en cada una. Un camion de 5 ejes es:
--
--   VI  bajo la escala de la OETR (7 categorias)
--   IV  bajo la escala general de INVIAS (5 categorias)
--
-- Sin saber cual usa la estacion, los ejes del camion no alcanzan para
-- determinar su tarifa. Esta columna guarda esa escala.
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE toll
    ADD COLUMN rate_scheme VARCHAR(20) NOT NULL DEFAULT 'INVIAS_5' AFTER active;

START TRANSACTION;

-- ------------------------------------------------------------
-- La escala se deriva de las tarifas ya cargadas: no hay que
-- capturarla a mano ni traerla de una fuente externa.
--
-- El marcador es la categoria VII. Solo la escala de siete la
-- tiene: en la de cinco la ultima categoria es la V. Se usa VII y
-- no VI porque hay estaciones de escala de cinco que publican una
-- VI marginal, practicamente igual a su V --Los Patios, La Cabana
-- y Sopo cobran 71.700 en V y 72.100 en VI--; mirar VI las
-- clasificaria mal, mirar VII no.
--
-- Verificado contra el reporte oficial de la ANI (OETR, corte junio
-- 2026): las estaciones que topan en V tienen un perfil de tarifas
-- corrido exactamente una posicion respecto de las de siete --su IV
-- equivale al VI de las otras y su V al VII-- y su categoria tope
-- concentra el 7,9% del trafico, el peso de una tractomula, contra
-- el 3,1% que mueve la V de las estaciones de escala completa.
-- ------------------------------------------------------------
UPDATE toll t
   SET t.rate_scheme = 'OETR_7'
 WHERE EXISTS (
           SELECT 1
             FROM toll_rate r
            WHERE r.toll_id = t.id
              AND r.category = 'VII'
       );

COMMIT;


-- ============================================================
-- MAPEO RESULTANTE (lo aplica TollCategoryEnum.forAxles)
-- ============================================================
--   Ejes    OETR_7   INVIAS_5
--   2       IV (*)   II
--   3 - 4   V        III
--   5       VI       IV
--   6 o +   VII      V
--
-- (*) La escala de siete parte los camiones de 2 ejes en III
--     (doble llanta pequena) y IV (doble llanta grande). El numero
--     de ejes no distingue una de otra, asi que se aplica IV, la
--     mayor, y la respuesta lo advierte. Resolverlo pide un
--     atributo nuevo del vehiculo, no mas logica.
-- ============================================================


-- ============================================================
-- VERIFICACION
-- ============================================================

SELECT rate_scheme, COUNT(*) AS estaciones
  FROM toll
 WHERE active = 1
 GROUP BY rate_scheme;

-- Cobertura: estaciones que no tienen tarifa para la categoria que
-- les exige el mapeo. Deberian ser solo SAN LUIS DE GACENO y
-- UNISABANA, y unicamente para camiones de 2 a 4 ejes.
SELECT t.toll_key,
       t.rate_scheme,
       CASE t.rate_scheme WHEN 'OETR_7' THEN 'VI' ELSE 'IV' END AS categoria_5_ejes,
       CASE t.rate_scheme WHEN 'OETR_7' THEN 'VII' ELSE 'V' END AS categoria_6_ejes
  FROM toll t
 WHERE t.active = 1
   AND NOT EXISTS (
           SELECT 1 FROM toll_rate r
            WHERE r.toll_id = t.id
              AND r.category = CASE t.rate_scheme WHEN 'OETR_7' THEN 'VI' ELSE 'IV' END
       )
 ORDER BY t.toll_key;
