-- ---------------------------------------------------------------------------------------------------------
-- Eventos de base de datos: ELIMINADOS
--
-- Todos los avisos programados viven ahora en el backend (cash.truck.infrastructure.scheduler), que guarda la
-- notificacion interna y ademas envia el push. Ejecutar este script una vez en cada base de datos para borrar
-- los eventos; si siguen activos, duplican los avisos del backend.
--
--   daily_birthday_check             -> BirthdayReminderScheduler
--   daily_license_expiry_check       -> DocumentExpiryReminderScheduler (licencia del conductor)
--   daily_pending_balance_check      -> PendingBalanceReminderScheduler
--   evt_check_trip_inactivity        -> InactivityReminderScheduler
--   daily_subscription_expiry_check  -> SubscriptionReminderScheduler
-- ---------------------------------------------------------------------------------------------------------

DROP EVENT IF EXISTS daily_birthday_check;
DROP EVENT IF EXISTS daily_license_expiry_check;
DROP EVENT IF EXISTS daily_pending_balance_check;
DROP EVENT IF EXISTS evt_check_trip_inactivity;
DROP EVENT IF EXISTS daily_subscription_expiry_check;

-- Verificacion: no debe quedar ningun evento en el esquema.
SELECT EVENT_NAME, STATUS FROM information_schema.EVENTS WHERE EVENT_SCHEMA = 'cashTruck';
