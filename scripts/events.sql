-- ---------------------------------------------------------------------------------------------------------
-- Eventos
-- ---------------------------------------------------------------------------------------------------------

SELECT CURRENT_TIMESTAMP();
SET GLOBAL event_scheduler = ON;
SHOW VARIABLES LIKE 'event_scheduler';
SHOW EVENTS;
SELECT EVENT_NAME, STATUS FROM information_schema.EVENTS WHERE EVENT_SCHEMA = 'cashTruck';

-- DROP EVENT IF EXISTS daily_birthday_check;
DELIMITER //
CREATE EVENT daily_birthday_check
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY)
DO
BEGIN
    -- Notificar a Propietarios (Rol ID 2)
    INSERT INTO notifications (event_type, message, target_user_id, target_role_id)
    SELECT 
        'CUMPLEAÑOS', 
        CONCAT('¡Feliz cumpleaños, ', name, '! Todo el equipo de CashTruck te desea un excelente día.'), 
        user_id, 2, id
    FROM owner 
    WHERE DATE_FORMAT(birthdate, '%m-%d') = DATE_FORMAT(CURDATE(), '%m-%d')
    AND user_id IS NOT NULL;

    -- Notificar a Conductores (Rol ID 3)
    INSERT INTO notifications (event_type, message, target_user_id, target_role_id, owner_id)
    SELECT 
        'CUMPLEAÑOS', 
        CONCAT('¡Feliz cumpleaños, ', name, '! Te deseamos un viaje seguro y un gran día de celebración.'), 
        user_id, 3
    FROM driver 
    WHERE DATE_FORMAT(birthdate, '%m-%d') = DATE_FORMAT(CURDATE(), '%m-%d')
    AND user_id IS NOT NULL;
END //

-- DROP EVENT IF EXISTS daily_license_expiry_check;
DELIMITER //
CREATE EVENT daily_license_expiry_check
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY)
DO
BEGIN
    -- Notificar al Conductor (Rol ID 3)
    INSERT INTO notifications (event_type, message, target_user_id, target_role_id, reference_id)
    SELECT 
        'VENCIMIENTO_LICENCIA', 
        CONCAT('Tu licencia de conducción vence en ', DATEDIFF(license_expiry, CURDATE()), ' días. Por favor, gestiona la renovación.'), 
        user_id, 3, id, owner_id
    FROM driver 
    WHERE DATEDIFF(license_expiry, CURDATE()) BETWEEN 1 AND 5
    AND user_id IS NOT NULL;

    -- Notificar al Propietario (Rol ID 2) sobre la licencia de su conductor
    INSERT INTO notifications (event_type, message, target_user_id, target_role_id, reference_id)
    SELECT 
        'ALERTA_LICENCIA_CONDUCTOR', 
        CONCAT('Atención: La licencia del conductor ', d.name, ' vence en ', DATEDIFF(d.license_expiry, CURDATE()), ' días.'), 
        o.user_id, 2, d.id, d.owner_id
    FROM driver d
    JOIN owner o ON d.owner_id = o.id
    WHERE DATEDIFF(d.license_expiry, CURDATE()) BETWEEN 1 AND 5;
END //

-- DROP EVENT IF EXISTS daily_pending_balance_check;
DELIMITER //
CREATE EVENT daily_pending_balance_check
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY)
DO
BEGIN
    -- Notificar al Propietario (Rol ID 2) sobre el dinero que le deben
    INSERT INTO notifications (
        event_type, 
        message, 
        target_user_id, 
        target_role_id, 
        reference_id
    )
    SELECT 
        'SALDO_PENDIENTE_COBRO', 
        CONCAT('El viaje #', t.number_trip, ' (Manifiesto: ', t.manifest_number, ') lleva 3 días pendiente de cobro. Saldo: $', t.balance), 
        o.user_id, 
        2, -- ID del Rol Propietario
        t.id, o.id
    FROM trip t
    JOIN driver d ON t.driver_id = d.id
    JOIN owner o ON d.owner_id = o.id
    WHERE t.status = 'Pendiente' 
      AND t.paid_balance = FALSE 
      AND t.balance > 0
      -- Compara si han pasado exactamente 3 días o más desde la última actualización (el cambio a pendiente)
      AND DATEDIFF(CURDATE(), t.update_date) >= 3;

    -- Notificar también al Administrador (Rol ID 1) para seguimiento general
    INSERT INTO notifications (
        event_type, 
        message, 
        target_role_id, 
        reference_id
    )
    SELECT 
        'ALERTA_CARTERA', 
        CONCAT('Viaje #', t.number_trip, ' de la empresa ', t.company, ' tiene saldo pendiente por cobrar hace más de 3 días.'), 
        1, -- ID del Rol Administrador
        t.id, o.id
    FROM trip t
    JOIN driver d ON t.driver_id = d.id
    JOIN owner o ON d.owner_id = o.id
    WHERE t.status = 'Pendiente' 
      AND t.paid_balance = FALSE 
      AND t.balance > 0
      AND DATEDIFF(CURDATE(), t.update_date) >= 3;
END //

DELIMITER //

-- DROP EVENT IF EXISTS evt_check_trip_inactivity;
CREATE EVENT IF NOT EXISTS evt_check_trip_inactivity
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Insertar notificaciones en la tabla 'notification'
    INSERT INTO notification (
        event_type, 
        message, 
        target_user_id, -- El conductor asociado al vehículo del viaje
        target_role_id, -- Rol del destinatario (ej. 2 para Propietario o el que definas)
        owner_id,       -- Dueño del vehículo/conductor
        reference_id,   -- ID del viaje (trip_id)
        is_read, 
        creation_date
    )
    SELECT 
        'TRIP_INACTIVITY_ALERT' AS event_type,
        CONCAT('Alerta: El viaje #', t.number_trip, ' del vehículo con placa: ', v.plate, ' no registra actividad de gastos en más de 12 horas.'),
        d.user_id,      -- ID de usuario del conductor
        2,              -- ID del Rol (Ajustar según tu tabla 'roles', ej: 1 Admin, 2 Owner)
        d.owner_id,     -- Relación directa desde el conductor
        t.id,           -- ID del viaje como referencia
        FALSE,
        NOW()
    FROM trip t
    INNER JOIN vehicle v ON t.vehicle_id = v.id
    INNER JOIN driver d ON v.current_driver_id = d.id
    LEFT JOIN (
        -- Obtenemos el último timestamp de creación de un gasto para cada viaje
        SELECT trip_id, MAX(creation_date) as last_expense_time 
        FROM expense 
        GROUP BY trip_id
    ) e ON t.id = e.trip_id
    WHERE t.status = 'En curso' 
    AND (
        -- Si no hay gastos: comparamos contra la creación del viaje
        (e.last_expense_time IS NULL AND TIMESTAMPDIFF(HOUR, t.creation_date, NOW()) >= 12)
        OR 
        -- Si hay gastos: comparamos contra el último registro
        (e.last_expense_time IS NOT NULL AND TIMESTAMPDIFF(HOUR, e.last_expense_time, NOW()) >= 12)
    )
    -- Evitar duplicados: No crear otra notificación si ya existe una para este viaje en las últimas 12h
    AND NOT EXISTS (
        SELECT 1 FROM notification n 
        WHERE n.reference_id = t.id 
        AND n.event_type = 'TRIP_INACTIVITY_ALERT'
        AND n.creation_date > DATE_SUB(NOW(), INTERVAL 12 HOUR)
    );
END //

DELIMITER //

-- ---------------------------------------------------------------------------------------------------------
-- Aviso de proximo vencimiento de suscripcion (10, 5 y 1 dia antes). Una sola fila por propietario, visible
-- para el y sus conductores. No aplica para el administrador.
-- Ver Truck_Ms_Site/scripts/migrations/2026_08_event_subscription_expiry_notice.sql
-- ---------------------------------------------------------------------------------------------------------
DROP EVENT IF EXISTS daily_subscription_expiry_check;

DELIMITER //

CREATE EVENT daily_subscription_expiry_check
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 6 HOUR)
ON COMPLETION PRESERVE
COMMENT 'Avisa al propietario y a sus conductores cuando faltan 10, 5 o 1 dia para el vencimiento de la suscripcion'
DO
BEGIN
    -- Una sola notificacion por propietario, visible para el y para todos sus
    -- conductores asociados.
    INSERT INTO notification (
        event_type,
        message,
        target_user_id,
        target_role_id,
        owner_id,
        reference_id,
        is_read,
        is_deleted,
        creation_date
    )
    SELECT
        'SUBSCRIPTION_EXPIRATION',
        CONCAT('La suscripción de ', o.name, ' vence ',
               IF(DATEDIFF(o.subscription_end_date, CURDATE()) = 1,
                  'mañana',
                  CONCAT('en ', DATEDIFF(o.subscription_end_date, CURDATE()), ' días')),
               ' (', DATE_FORMAT(o.subscription_end_date, '%d/%m/%Y'),
               '). Al vencer no será posible ingresar a la aplicación. ',
               'Contacta al administrador por WhatsApp para renovarla.'),
        NULL,   -- aviso de grupo: lo ve el propietario y sus conductores
        2,      -- Rol Propietario
        o.id,   -- agrupador usado por la aplicacion para mostrar la notificacion
        o.id,
        FALSE,
        FALSE,
        NOW()
    FROM owner o
    LEFT JOIN users u ON u.id = o.user_id
    WHERE o.subscription_end_date IS NOT NULL
      AND DATEDIFF(o.subscription_end_date, CURDATE()) IN (10, 5, 1)
      -- Propietario sin usuario: igual se avisa, sus conductores lo veran
      AND (u.id IS NULL OR u.status = 'Activo')
      -- El administrador queda excluido
      AND (o.user_id IS NULL OR NOT EXISTS (
          SELECT 1 FROM user_role ur
          WHERE ur.user_id = o.user_id AND ur.role_id = 1
      ))
      -- Anti-duplicados del mismo dia
      AND NOT EXISTS (
          SELECT 1 FROM notification n
          WHERE n.event_type = 'SUBSCRIPTION_EXPIRATION'
            AND n.owner_id = o.id
            AND DATE(n.creation_date) = CURDATE()
      );
END //

DELIMITER ;
