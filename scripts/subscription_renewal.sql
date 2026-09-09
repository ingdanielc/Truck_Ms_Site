-- Renovacion de suscripcion y su historico de pagos.
--
-- No hay pasarela: el propietario paga por Nequi o Bancolombia leyendo un QR y
-- sube el comprobante, y un administrador lo confirma a mano. El modelo esta
-- pensado para eso, y por eso el pago tiene estado propio en vez de aplicarse
-- en el momento en que se registra.
--
-- Las dos tablas se separan porque responden a preguntas distintas: el plan
-- dice cuanto cuesta hoy, y el pago dice cuanto se cobro aquella vez. Meter el
-- precio solo en el plan haria que subirlo reescribiera el historico.

-- ---------------------------------------------------------------------------
-- Precios vigentes
-- ---------------------------------------------------------------------------
-- Una fila por periodo de precios. Se cambia el precio insertando una fila
-- nueva y cerrando la anterior, no editandola: asi un pago viejo siempre puede
-- explicar contra que tarifa se cobro.
--
-- included_vehicles es cuantos vehiculos cubre la anualidad antes de empezar a
-- cobrar adicionales. Hoy es 1, pero se deja parametrizado porque es
-- exactamente el tipo de numero que cambia con una promocion.
CREATE TABLE subscription_plan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    annual_price DECIMAL(15,2) NOT NULL,
    additional_vehicle_price DECIMAL(15,2) NOT NULL,
    included_vehicles INT NOT NULL DEFAULT 1,
    months INT NOT NULL DEFAULT 12,

    -- Vigencia. valid_to NULL = es la tarifa actual. Solo deberia haber una
    -- fila abierta a la vez; la consulta ordena por valid_from descendente
    -- para que, si quedaran dos, gane la mas reciente en vez de fallar.
    valid_from DATE NOT NULL,
    valid_to DATE NULL,

    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_plan_validity (valid_from, valid_to)
);

-- ---------------------------------------------------------------------------
-- Historico de pagos
-- ---------------------------------------------------------------------------
-- Cada intento de renovacion deja fila, se confirme o no. Un pago rechazado es
-- informacion: explica por que el propietario reclama que ya pago.
--
-- Los precios se copian aqui y no se leen del plan al consultar: el plan puede
-- cambiar o cerrarse, y una factura que cambia de valor con el tiempo no sirve
-- como respaldo. plan_id queda solo como trazabilidad de cual se aplico.
CREATE TABLE subscription_payment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id BIGINT NOT NULL,
    plan_id INT NOT NULL,

    -- Cupo cobrado: copia de owner.max_vehicles al momento de cotizar. Si el
    -- propietario amplia el cupo despues, este pago sigue diciendo por cuantos
    -- vehiculos pago realmente.
    vehicle_count INT NOT NULL,
    additional_vehicles INT NOT NULL,
    -- Anualidades compradas de una vez. No hay suscripcion menor a un ano, asi
    -- que el periodo se cuenta en anos y no en meses sueltos: eso evita tener
    -- que definir cuanto vale un mes, que no es la doceava parte del ano.
    years INT NOT NULL DEFAULT 1,
    annual_price DECIMAL(15,2) NOT NULL,
    additional_vehicle_price DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,

    payment_method ENUM('Nequi', 'Bancolombia', 'Otro') NOT NULL,
    -- Numero de transaccion que el propietario transcribe del comprobante. No
    -- es unico a proposito: Nequi y Bancolombia no garantizan el formato, y un
    -- error de tecleo no puede bloquear el registro del pago.
    reference VARCHAR(100) NULL,
    -- URL que devuelve /common/upload-document. El archivo se sube antes de
    -- crear esta fila, igual que los escaneos de documentos.
    receipt_url VARCHAR(255) NULL,

    status ENUM('Pendiente', 'Confirmado', 'Rechazado') NOT NULL DEFAULT 'Pendiente',
    rejection_reason VARCHAR(255) NULL,

    -- Fotos de la fecha de suscripcion antes y despues de aplicar el pago. La
    -- anterior permite deshacer una confirmacion equivocada sin adivinar.
    previous_end_date DATE NULL,
    new_end_date DATE NULL,

    reviewed_by_user_id INT NULL,
    reviewed_at DATETIME NULL,

    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (owner_id) REFERENCES owner(id),
    FOREIGN KEY (plan_id) REFERENCES subscription_plan(id),
    FOREIGN KEY (reviewed_by_user_id) REFERENCES users(id),

    -- El listado del administrador entra por estado, y el del propietario por
    -- su id: los dos ordenan por fecha de registro.
    INDEX idx_subscription_payment_status (status, creation_date),
    INDEX idx_subscription_payment_owner (owner_id, creation_date)
);

-- ---------------------------------------------------------------------------
-- Tarifa inicial
-- ---------------------------------------------------------------------------
INSERT INTO subscription_plan (name, annual_price, additional_vehicle_price,
                               included_vehicles, months, valid_from, valid_to)
VALUES ('Tarifa 2026', 100000.00, 40000.00, 1, 12, CURDATE(), NULL);

-- ---------------------------------------------------------------------------
-- Plantilla de WhatsApp del aviso de renovacion
-- ---------------------------------------------------------------------------
-- Se borra antes de insertar para que reejecutar el script no duplique la
-- plantilla, igual que hacen los demas scripts de plantillas.
DELETE FROM template
 WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_RENEWED';

INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'SUBSCRIPTION_RENEWED', NULL,
'🚛 ¡Suscripción renovada!\nTu cuenta CashTruck está activa hasta el ${endDate}.\n¡Menos gastos, más camino! 🚛\n\n🤖 Mensaje automático, por favor no respondas a este número.',
'Suscripción renovada');

-- Orden en que Twilio numera las variables de la plantilla aprobada. Tiene que
-- coincidir con el {{1}} de la plantilla registrada en el proveedor.
UPDATE template SET provider_variables = 'endDate'
 WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_RENEWED';

-- ---------------------------------------------------------------------------
-- Plantilla de WhatsApp del pago rechazado
-- ---------------------------------------------------------------------------
-- Dice el motivo y como reintentar. Sin el motivo el propietario no sabe que
-- corregir y vuelve a registrar el mismo comprobante.
DELETE FROM template
 WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_REJECTED';

INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'SUBSCRIPTION_REJECTED', NULL,
'⚠️ No pudimos confirmar tu pago\n\nHola ${name}, revisamos el comprobante que nos enviaste y no logramos confirmarlo.\n\nMotivo: ${reason}\n\nPuedes registrarlo de nuevo desde la app con el comprobante corregido. 🔄\n\n🤖 Mensaje automático, por favor no respondas a este número.',
'Pago no confirmado');

UPDATE template SET provider_variables = 'name,reason'
 WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_REJECTED';

-- ---------------------------------------------------------------------------
-- ContentSid de las plantillas aprobadas en Twilio
-- ---------------------------------------------------------------------------
-- Con una cuenta de pago WhatsApp rechaza el texto libre en los mensajes que
-- inicia el negocio, y estos dos lo son: nadie los pide, salen solos. Sin el
-- ContentSid el backend manda texto libre y Twilio responde 63016 fuera de la
-- ventana de 24 horas.
--
-- Los dos UPDATE van comentados a proposito. Un HX inventado no falla al
-- ejecutar el script pero rompe el envio con 20404 "Content was not found",
-- que es peor de diagnosticar que el NULL: con NULL al menos el mensaje sale
-- dentro de la ventana de 24 horas.
--
-- Para activarlos: crea las dos plantillas en Twilio, copia su HX, reemplaza
-- el marcador y quita el comentario de las dos lineas.
--
-- Ojo al recrear una plantilla en Twilio: el HX cambia y hay que actualizarlo
-- aqui y en la base ya desplegada, o Twilio responde 20404 por el HX viejo.

-- cashtruck_suscripcion_renovada
-- UPDATE template SET provider_template_id = 'HX_PEGAR_AQUI_EL_SID'
--  WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_RENEWED';

-- cashtruck_pago_no_confirmado
-- UPDATE template SET provider_template_id = 'HX_PEGAR_AQUI_EL_SID'
--  WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_REJECTED';

-- Comprobacion rapida tras aplicar el script: las dos filas deben aparecer, y
-- provider_template_id sigue en NULL hasta que se activen los UPDATE de arriba.
SELECT message_type, provider_variables, provider_template_id
  FROM template
 WHERE medium = 'WhatsApp'
   AND message_type IN ('SUBSCRIPTION_RENEWED', 'SUBSCRIPTION_REJECTED');
