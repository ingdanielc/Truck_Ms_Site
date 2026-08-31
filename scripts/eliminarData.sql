-- Iniciamos una transacción. Si algo falla, puedes hacer ROLLBACK.
START TRANSACTION;

-- 1. DEFINIR EL ID DEL OWNER A ELIMINAR
SET @ownerId = 9; -- <--- ¡CAMBIA ESTE NÚMERO POR EL ID REAL!

-- 2. DESACTIVAR REVISIÓN DE LLAVES FORÁNEAS TEMPORALMENTE
-- Esto evita bloqueos por referencias cruzadas entre driver, vehicle y owner
SET FOREIGN_KEY_CHECKS = 0;

-- 3. LIMPIEZA DE TABLAS HIJAS (De menor a mayor jerarquía)

-- Eliminar ubicaciones asociadas a los conductores de este owner
DELETE FROM driver_locations 
WHERE driver_id IN (SELECT id FROM driver WHERE owner_id = @ownerId);

-- Eliminar gastos asociados a los vehículos de este owner
DELETE FROM expense 
WHERE vehicle_id IN (SELECT vehicle_id FROM vehicle_owner WHERE owner_id = @ownerId);

-- Eliminar viajes (trips) asociados a los conductores de este owner
DELETE FROM trip 
WHERE driver_id IN (SELECT id FROM driver WHERE owner_id = @ownerId);

-- Eliminar los vehículos físicos vinculados al owner
DELETE FROM vehicle 
WHERE id IN (SELECT vehicle_id FROM vehicle_owner WHERE owner_id = @ownerId);

-- Eliminar la relación en la tabla pivote (vehicle_owner)
DELETE FROM vehicle_owner 
WHERE owner_id = @ownerId;

-- Eliminar notificaciones directas al owner
-- (Nota: Las notificaciones vinculadas a 'users' se borrarán solas por el CASCADE)
DELETE FROM notification 
WHERE owner_id = @ownerId;

-- 4. LIMPIEZA DE USUARIOS Y CONDUCTORES

-- Primero: Eliminar los roles (user_role) de los conductores asociados a este owner
DELETE FROM user_role 
WHERE user_id IN (SELECT user_id FROM driver WHERE owner_id = @ownerId AND user_id IS NOT NULL);

-- Eliminar las cuentas de usuario de los conductores que pertenecen a este owner
DELETE FROM users 
WHERE id IN (SELECT user_id FROM driver WHERE owner_id = @ownerId AND user_id IS NOT NULL);

-- Eliminar los conductores
DELETE FROM driver 
WHERE owner_id = @ownerId;

-- 5. LIMPIEZA FINAL DEL OWNER

-- Primero: Eliminar los roles (user_role) del owner
DELETE FROM user_role 
WHERE user_id = (SELECT user_id FROM owner WHERE id = @ownerId AND user_id IS NOT NULL);

-- Eliminar la cuenta de usuario del owner
DELETE FROM users 
WHERE id = (SELECT user_id FROM owner WHERE id = @ownerId AND user_id IS NOT NULL);

-- Finalmente, eliminar al Owner
DELETE FROM owner 
WHERE id = @ownerId;

-- 6. REACTIVAR LLAVES FORÁNEAS (¡Muy importante!)
SET FOREIGN_KEY_CHECKS = 1;

-- Si todo salió bien, guardamos los cambios.
-- (Si estás probando el script y quieres ver si funciona sin borrar, cambia COMMIT por ROLLBACK)
COMMIT;