START TRANSACTION;

-- ID DEL VIAJE QUE QUIERES ELIMINAR
SET @tripId = 15; -- <-- CAMBIA ESTE ID

-- Verificar qué viaje se va a eliminar
SELECT *
FROM trip
WHERE id = @tripId;

-- Verificar gastos asociados
SELECT *
FROM expense
WHERE trip_id = @tripId;

-- Eliminar gastos del viaje
DELETE FROM expense
WHERE trip_id = @tripId;

-- Eliminar el viaje
DELETE FROM trip
WHERE id = @tripId;

-- Si todo está correcto:
COMMIT;