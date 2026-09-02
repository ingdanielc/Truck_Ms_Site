-- ---------------------------------------------------------------------------------------------------------
-- Reconstruccion completa de la base de datos cashTruck
--
-- Origen de los datos : cashTruck_27082026.sql
-- Estructura          : tables.sql (reordenada: users/roles/user_role antes de owner)
-- Catalogos           : info.sql
--
-- Contenido: solo los owners 2002 y 2005 del respaldo, con toda su informacion
-- asociada (usuarios, conductores, vehiculos, viajes, gastos, categorias
-- propias, ubicaciones y notificaciones), mas el usuario administrador.
-- Todos los identificadores quedan renumerados desde 1.
--
-- Equivalencias con el respaldo original:
--   owner 2002 -> 1  (John H. Hernandez Ortiz / ing.jhenry@gmail.com)
--   owner 2005 -> 2  (Julián Castro Solis / julianc477@gmail.com)
--
-- ADVERTENCIA: este script ELIMINA la base de datos cashTruck y la recrea.
-- ---------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------
-- 1. Base de datos
-- ---------------------------------------------------------------------------------------------------------
DROP DATABASE IF EXISTS cashTruck;
CREATE DATABASE cashTruck CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cashTruck;

-- ---------------------------------------------------------------------------------------------------------
-- 2. Estructura
-- ---------------------------------------------------------------------------------------------------------
-- DROP TABLE IF EXISTS document_type;
CREATE TABLE document_type (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- DROP TABLE IF EXISTS city;
CREATE TABLE city (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state VARCHAR(100)
);

-- DROP TABLE IF EXISTS gender;
CREATE TABLE gender (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- DROP TABLE IF EXISTS expense_type;
CREATE TABLE expense_type (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- DROP TABLE IF EXISTS vehicle_brand;
CREATE TABLE vehicle_brand (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- DROP TABLE IF EXISTS salary_type;
CREATE TABLE salary_type (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Seguridad
-- DROP TABLE IF EXISTS users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    status ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- DROP TABLE IF EXISTS roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- DROP TABLE IF EXISTS user_role
CREATE TABLE user_role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_user_role (user_id, role_id),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);


-- DROP TABLE IF EXISTS owner;
CREATE TABLE owner (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    photo VARCHAR(120),
    document_type_id INT NOT NULL,
    document_number VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cell_phone VARCHAR(20) NOT NULL,
    city_id INT,
    gender_id INT,
    birthdate DATE,
    -- Campo Calculado Automático (Edad)
    age INT AS (TIMESTAMPDIFF(YEAR, birthdate, CURDATE())) VIRTUAL,
    user_id INT UNIQUE,
    max_vehicles INT NOT NULL DEFAULT 3,
    is_driver BOOLEAN DEFAULT FALSE NOT NULL,
    -- Fin de suscripcion. NULL = sin vencimiento
    subscription_end_date DATE NULL,
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (document_type_id) REFERENCES document_type(id),
    FOREIGN KEY (city_id) REFERENCES city(id),
    FOREIGN KEY (gender_id) REFERENCES gender(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- DROP TABLE IF EXISTS driver;
CREATE TABLE driver (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    photo VARCHAR(120),
    document_type_id INT NOT NULL,
    document_number VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cell_phone VARCHAR(20) NOT NULL,
    city_id INT,
    gender_id INT,
    birthdate DATE,
    -- Campo Calculado Automático (Edad)
    age INT AS (TIMESTAMPDIFF(YEAR, birthdate, CURDATE())) VIRTUAL,
    salary_type_id INT,
    salary INT,
    
    license_category VARCHAR(5) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    license_expiry DATE NOT NULL,
    
    user_id INT UNIQUE NULL,
    owner_id BIGINT NOT NULL, -- El conductor pertenece a un Propietario
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	FOREIGN KEY (document_type_id) REFERENCES document_type(id),
    FOREIGN KEY (city_id) REFERENCES city(id),
    FOREIGN KEY (gender_id) REFERENCES gender(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (owner_id) REFERENCES owner(id),
    FOREIGN KEY (salary_type_id) REFERENCES salary_type(id)
);

-- DROP TABLE IF EXISTS vehicle;
CREATE TABLE vehicle (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    photo VARCHAR(120),
    plate VARCHAR(10) NOT NULL UNIQUE,
    current_driver_id BIGINT UNIQUE NULL,
    vehicle_brand_id INT NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    color VARCHAR(30),
    engine_number VARCHAR(50),
    chassis_number VARCHAR(50),
    number_of_axles VARCHAR(50),
    
    status ENUM('Activo', 'En Mantenimiento', 'Inactivo', 'Vendido') DEFAULT 'Activo',
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_brand_id) REFERENCES vehicle_brand(id),
    FOREIGN KEY (current_driver_id) REFERENCES driver(id)
);

-- 1. Optimizar la búsqueda de vehículos por conductor actual Útil para saber rápidamente qué camión tiene asignado un chofer
CREATE INDEX idx_vehicle_driver ON vehicle(current_driver_id);

-- 2. Optimizar filtros por estado (Activo, En Mantenimiento, etc.) Crucial para el dashboard que cuenta cuántos vehículos están operativos
CREATE INDEX idx_vehicle_status ON vehicle(status);

-- DROP TABLE IF EXISTS vehicle_owner;
CREATE TABLE vehicle_owner (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    owner_id BIGINT NOT NULL,
    ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    
    start_date DATE DEFAULT (CURRENT_DATE),
	end_date DATE NULL,
	is_active BOOLEAN DEFAULT TRUE,
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id),
    FOREIGN KEY (owner_id) REFERENCES owner(id),
    UNIQUE(vehicle_id, owner_id)
);

CREATE INDEX idx_owner_history ON vehicle_owner(owner_id);
CREATE INDEX idx_vehicle_history ON vehicle_owner(vehicle_id);

-- DROP TABLE IF EXISTS trip;
CREATE TABLE trip (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    driver_id BIGINT NOT NULL,
    number_trip INT NOT NULL, 
    manifest_number VARCHAR(100) NULL,
    company VARCHAR(100),
    origin_id INT NOT NULL,
    destination_id INT NOT NULL,
    return_destination_id INT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    number_of_days INT NOT NULL,
    load_type VARCHAR(100), 
    trip_type VARCHAR(10) NOT NULL,
    current_leg VARCHAR(10) NULL,
    
    freight DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    advance_payment DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    balance DECIMAL(15,2) AS (freight - advance_payment) VIRTUAL,
    paid_balance BOOLEAN NOT NULL DEFAULT FALSE,
    status ENUM('Planeado', 'En Curso', 'Completado', 'Cancelado', 'Pendiente') DEFAULT 'Planeado',
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id),
    FOREIGN KEY (driver_id) REFERENCES driver(id),
    FOREIGN KEY (origin_id) REFERENCES city(id),
    FOREIGN KEY (destination_id) REFERENCES city(id)
);

-- 1. Índice para búsqueda por vehículo (Muy común para el historial de un camión)
CREATE INDEX idx_trip_vehicle ON trip(vehicle_id);

-- 2. Índice compuesto para Origen y Destino  (Optimiza búsquedas de rutas específicas)
CREATE INDEX idx_trip_route ON trip(origin_id, destination_id);

-- 3. Índice para el número de viaje y manifiesto  (Búsquedas exactas de documentos)
CREATE INDEX idx_trip_numbers ON trip(number_trip, manifest_number);

-- 4. Índice para el estado del viaje (Útil para el dashboard de "Viajes en Curso")
CREATE INDEX idx_trip_status ON trip(status);

-- DROP TABLE IF EXISTS expense_category;
CREATE TABLE expense_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    expense_type_id INT NOT NULL,
    owner_id BIGINT NULL,
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_category_per_owner (name, expense_type_id, owner_id),
    FOREIGN KEY (expense_type_id) REFERENCES expense_type(id)
);

-- DROP TABLE IF EXISTS expense;
CREATE TABLE expense (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    trip_id BIGINT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    expense_date DATE NOT NULL,
    description TEXT,
    receipt_image_url VARCHAR(255),
    
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id),
    FOREIGN KEY (trip_id) REFERENCES trip(id),
    FOREIGN KEY (category_id) REFERENCES expense_category(id)
);

-- Location
CREATE TABLE driver_locations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    driver_id BIGINT NOT NULL,
    vehicle_id BIGINT NOT NULL,
    trip_id BIGINT NULL,
    
    -- Coordenadas de alta precisión
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    
    -- Velocidad aproximada (útil si la app reporta en movimiento)
    speed_kmh DECIMAL(5, 2) DEFAULT 0.00,
    
    -- Dirección descriptiva (opcional)
    address_text TEXT,
    
    -- Auditoría
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Integridad Referencial
    CONSTRAINT fk_loc_driver FOREIGN KEY (driver_id) REFERENCES driver(id) ON DELETE CASCADE,
    CONSTRAINT fk_loc_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle(id) ON DELETE CASCADE,
    CONSTRAINT fk_loc_trip FOREIGN KEY (trip_id) REFERENCES trip(id) ON DELETE SET NULL,
    
    -- Índice para consultas rápidas del Propietario
    INDEX idx_history (vehicle_id, creation_date)
);

-- Notifications
-- DROP TABLE IF EXISTS notification
CREATE TABLE notification (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    
    -- Relación con el Usuario (Puede ser NULL si es para todo un Rol)
    target_user_id INT NULL,
    
    -- Relación con el Rol (Obligatoria)
    target_role_id INT NOT NULL,
    owner_id BIGINT NULL,
    
    reference_id BIGINT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- Auditoría
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Definición de Llaves Foráneas
	FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (target_role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES owner(id) ON DELETE CASCADE,
    
    -- Índices de optimización
    INDEX idx_notif_lookup (target_user_id, target_role_id, is_read)
);

-- DROP TABLE IF EXISTS audit;
CREATE TABLE audit (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    error_type TEXT,
    message_id CHAR(36),
    message_type VARCHAR(50),
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- DROP TABLE IF EXISTS template;
CREATE TABLE template (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    medium VARCHAR(255) NOT NULL,
    message_type VARCHAR(255) NOT NULL,
    -- ContentSid (HX...) de la plantilla aprobada en Twilio. Con una cuenta de
    -- pago WhatsApp rechaza el texto libre en mensajes que inicia el negocio,
    -- asi que sin esto no sale ninguna notificacion. Nulo = enviar texto libre,
    -- que sigue siendo valido dentro de la ventana de 24 horas.
    provider_template_id VARCHAR(64) NULL,
    -- Orden de las variables, separadas por coma: WhatsApp las numera ({{1}},
    -- {{2}}) mientras que template_content las nombra (${name}). Esta columna
    -- es la traduccion entre ambos.
    provider_variables VARCHAR(255) NULL,
    attachment_url_default TEXT,
    template_content TEXT NOT NULL,
    template_subject TEXT NOT NULL
);

-- DROP TABLE IF EXISTS whatsapp;
CREATE TABLE whatsapp (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    message_provide_id VARCHAR(255),
    phone_number VARCHAR(20) NOT NULL,
    message_type VARCHAR(255),
    template_id BIGINT,
    message_content TEXT,
    message_attachment VARCHAR(255),
    status VARCHAR(255) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- DROP TABLE IF EXISTS email;
CREATE TABLE email (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subject VARCHAR(255),
    message_provider_status VARCHAR(255),
    message_type VARCHAR(255),
    template_id BIGINT,
    message_content TEXT,
    message_attachment VARCHAR(255),
    status VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Almacena `LocalDateTime`
    recipient VARCHAR(255) NOT NULL,
    message_provider TEXT
);

-- DROP TABLE IF EXISTS sms;
CREATE TABLE sms (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    message_provide_id VARCHAR(255),
    phone_number VARCHAR(20) NOT NULL,
    message_type VARCHAR(255),
    template_id BIGINT,
    message_content TEXT,
    message_attachment VARCHAR(255),
    status VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- DROP TABLE IF EXISTS password_reset;
CREATE TABLE password_reset (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    phone VARCHAR(20),
    code VARCHAR(128) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    attempts INT NOT NULL DEFAULT 0,
    reset_token VARCHAR(64),
    expiration_date DATETIME NOT NULL,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_password_reset_user (user_id),
    INDEX idx_password_reset_phone (phone, status),
    UNIQUE INDEX uq_password_reset_token (reset_token)
);


-- DROP TABLE IF EXISTS document_file_type;
CREATE TABLE document_file_type (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    -- Evita que el front ofrezca SOAT para un conductor o licencia para un camion.
    applies_to ENUM('VEHICLE', 'DRIVER', 'OWNER') NOT NULL,
    -- Distingue los que vencen (SOAT) de los que no (tarjeta de propiedad).
    requires_expiry BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_document_file_type (name, applies_to)
);

-- Documentos archivados: el papel con su numero, emisor, vencimiento y escaneo.
-- No confundir con document_type, que es el tipo de identificacion de personas.
-- Un documento cuelga de exactamente una entidad; se usan tres columnas con FK
-- real en lugar de un par (tipo, id) polimorfico para no perder la integridad
-- referencial que garantiza el motor en el resto del esquema.
-- DROP TABLE IF EXISTS document_file;
CREATE TABLE document_file (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_file_type_id INT NOT NULL,

    vehicle_id BIGINT NULL,
    driver_id BIGINT NULL,
    owner_id BIGINT NULL,

    document_number VARCHAR(100),
    -- Aseguradora o CDA. Dos SOAT del mismo vehiculo en anios distintos se
    -- distinguen por esto.
    issuer VARCHAR(150),
    issue_date DATE,
    -- Nullable a proposito: la tarjeta de propiedad no vence.
    expiry_date DATE,
    -- Nullable a proposito: el usuario puede registrar el documento sin
    -- cargarlo, solo para que la app le recuerde el vencimiento.
    file_url VARCHAR(255),
    observations TEXT,

    -- Al renovar, el anterior queda inactivo en lugar de desaparecer: un
    -- vencimiento pasado es evidencia y no se recupera si se sobrescribe.
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Vale el tipo mientras el documento este vigente y NULL cuando no. Las tres
    -- claves unicas de abajo se apoyan en esto para permitir un solo documento
    -- activo por entidad y tipo, dejando el historico inactivo sin limite:
    -- MariaDB ignora en un indice unico las filas con alguna columna nula.
    active_key INT AS (CASE WHEN is_active THEN document_file_type_id END) PERSISTENT,

    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_document_file_type FOREIGN KEY (document_file_type_id) REFERENCES document_file_type(id),
    CONSTRAINT fk_document_file_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle(id),
    CONSTRAINT fk_document_file_driver FOREIGN KEY (driver_id) REFERENCES driver(id),
    CONSTRAINT fk_document_file_owner FOREIGN KEY (owner_id) REFERENCES owner(id),

    -- Exactamente un portador: ni cero ni dos.
    CONSTRAINT chk_document_file_holder CHECK (
        (vehicle_id IS NOT NULL) + (driver_id IS NOT NULL) + (owner_id IS NOT NULL) = 1
    ),
    -- Sin archivo y sin vencimiento la fila no sirve: ni se consulta ni se
    -- puede avisar por ella.
    CONSTRAINT chk_document_file_payload CHECK (
        file_url IS NOT NULL OR expiry_date IS NOT NULL
    ),

    UNIQUE KEY uq_document_file_active_vehicle (vehicle_id, active_key),
    UNIQUE KEY uq_document_file_active_driver (driver_id, active_key),
    UNIQUE KEY uq_document_file_active_owner (owner_id, active_key)
);

-- Los tres UNIQUE ya sirven de indice para buscar por portador; falta el del
-- recordatorio de vencimientos, que consulta por fecha exacta y estado.
CREATE INDEX idx_document_file_expiry ON document_file(expiry_date, is_active);

-- ---------------------------------------------------------------------------------------------------------
-- 3. Catalogos, roles, plantillas y usuario administrador (id = 1)
-- ---------------------------------------------------------------------------------------------------------
INSERT INTO document_type (name)
VALUES 
('Cédula de Ciudadanía');

INSERT INTO city (name, state) VALUES 
('Bogotá D.C.', 'Cundinamarca'),
('Medellín', 'Antioquia'),
('Cali', 'Valle del Cauca'),
('Barranquilla', 'Atlántico'),
('Cartagena', 'Bolívar'),
('Bucaramanga', 'Santander'),
('Manizales', 'Caldas'),
('Pereira', 'Risaralda'),
('Cúcuta', 'Norte de Santander'),
('Ibagué', 'Tolima'),
('Santa Marta', 'Magdalena'),
('Villavicencio', 'Meta'),
('Montería', 'Córdoba'),
('Valledupar', 'Cesar'),
('Popayán', 'Cauca'),
('Neiva', 'Huila'),
('Armenia', 'Quindío'),
('Tunja', 'Boyacá'),
('Sincelejo', 'Sucre'),
('Riohacha', 'La Guajira'),
('Florencia', 'Caquetá'),
('Yopal', 'Casanare'),
('Quibdó', 'Chocó'),
('Buenaventura', 'Valle del Cauca'),
('Barrancabermeja', 'Santander'),
('Ipiales', 'Nariño'),
('Tumaco', 'Nariño'),
('Duitama', 'Boyacá'),
('Sogamoso', 'Boyacá'),
('Girardot', 'Cundinamarca'),
('La Dorada', 'Caldas'),
('Cumbal', 'Nariño'),               
('Túquerres', 'Nariño'),            
('Guachucal', 'Nariño'),            
('La Unión', 'Nariño'),             
('Samaniego', 'Nariño'),
('Santander de Quilichao', 'Cauca'),
('Puerto Tejada', 'Cauca'),
('Mocoa', 'Putumayo'),              
('Puerto Asís', 'Putumayo'),        
('Orito', 'Putumayo'),
('Buga', 'Valle del Cauca'),
('Palmira', 'Valle del Cauca'),
('Tuluá', 'Valle del Cauca'),
('Jamundí', 'Valle del Cauca'),
('Cartago', 'Valle del Cauca'),
('Dosquebradas', 'Risaralda'),
('Calarcá', 'Quindío'),
('Soacha', 'Cundinamarca'),
('Mosquera', 'Cundinamarca'),
('Funza', 'Cundinamarca'),
('Facatativá', 'Cundinamarca'),
('Zipaquirá', 'Cundinamarca'),
('Tocancipá', 'Cundinamarca'),
('Fusagasugá', 'Cundinamarca'),
('Melgar', 'Tolima'),
('Espinal', 'Tolima'),
('Pitalito', 'Huila'),
('Garzón', 'Huila'),
('Rionegro', 'Antioquia'),
('Apartadó', 'Antioquia'),
('Turbo', 'Antioquia'),
('Caucasia', 'Antioquia'),
('Bello', 'Antioquia'),
('Itagüí', 'Antioquia'),
('Envigado', 'Antioquia'),
('Barrancabermeja', 'Santander'),
('San Gil', 'Santander'),
('Ocaña', 'Norte de Santander'),
('Pamplona', 'Norte de Santander'),
('Aguachica', 'Cesar'),
('Bosconia', 'Cesar'),
('Maicao', 'La Guajira'),
('Soledad', 'Atlántico'),
('Malambo', 'Atlántico'),
('Magangué', 'Bolívar'),
('Lorica', 'Córdoba'),
('Acacías', 'Meta'),
('Granada', 'Meta'),
('Arauca', 'Arauca'),
('Saravena', 'Arauca'),
('Pasto', 'Nariño'),
('Tulcán', 'Ecuador');

INSERT INTO gender (name) VALUES 
('Masculino'),
('Femenino');

INSERT INTO expense_type (name) 
VALUES 
    ('Gastos del Vehículo'),
    ('Gastos del Conductor'),
    ('Gastos del Viaje'),
    ('Mantenimiento');
    
INSERT INTO salary_type (name) 
VALUES 
    ('Salario mensual'),
    ('Porcentaje');
    
INSERT INTO vehicle_brand (name) 
VALUES 
    ('Kenworth'),
	('International'),
	('Freightliner'),
	('Mack'),
	('Peterbilt'),
	('Ford'),
	('Dodge'),
	('Chevrolet'),
	('Hino'),
	('Foton'),
	('JAC'),
	('JMC'),
	('Dongfeng'),
	('Sinotruk'),
	('Mitsubishi Fuso'),
	('Hyundai'),
	('Scania'),
	('Mercedes-Benz'),
	('Volkswagen'),
	('Volvo'),
	('Renault'),
	('DAF'),
	('Iveco');
    
INSERT INTO expense_category (name, expense_type_id) VALUES 
('Encarrosada', 1),
('Descarrosada', 1),
('Bascula', 1),
('Parqueadero', 1),
('Lavado-brillado', 1),
('Engrasada', 1),
('Montallantas', 1),
('Accesorios', 1),
('Llantas', 1),
('Varios', 1);

INSERT INTO expense_category (name, expense_type_id) VALUES 
('Alimentación conductor', 2),
('Hotel conductor', 2),
('Salario', 2),
('Seguridad social conductor', 2),
('Varios', 2);

INSERT INTO expense_category (name, expense_type_id) VALUES 
('Descuento empresa', 3),
('Retenciones', 3),
('Cambio cheque o papeleo', 3),
('Comisiones', 3),
('Cargue', 3),
('Descargue', 3),
('Combustible', 3),
('Peajes', 3),
('Impuesto 4x1000', 3),
('Varios', 3);

INSERT INTO expense_category (name, expense_type_id) VALUES 
('Créditos', 4),
('Seguros', 4),
('Revisión Tecnomecánica', 4),
('Llantas y rines', 4),
('Aceite, Grasa, Refrigerante', 4),
('Carrocería', 4),
('Lujos y Accesorios', 4),
('Eléctricos', 4),
('Mecánica General', 4),
('Mano de obra', 4),
('Viajes', 4),
('Salario', 4),
('Otro', 4);

-- Security
INSERT INTO users (name, email, password, status) VALUES -- 94800621*
('Daniel Castro S.', 'ingdanielc@hotmail.com', 'ddd5277dd4a9565a6fbe7e7b7d4d47bdc608363cfbff7ba13d169887ad26deae316e709664d5da9f6c88bfc0a6ac22a70087a4e6f9e6571c579a5ee498729b54', 'Activo');

INSERT INTO roles (name, description) VALUES
('Administrador', 'Administrador del sistema con todos los permisos'),
('Propietario', 'Usuario con permisos sobre viajes, vehiculos y gastos'),
('Conductor', 'Usuario con permisos sobre gastos');

INSERT INTO user_role (user_id, role_id) VALUES
(1, 1);

-- Notifications
ALTER TABLE template CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE whatsapp CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Plantillas de WhatsApp. El texto es identico al aprobado en Twilio/Meta:
-- lo que se guarda aqui es lo que el destinatario recibe y lo que queda en la
-- auditoria. Ver docs/plantillas-whatsapp-twilio.md.
--
-- La contrasena no aparece en ningun mensaje: no esta en provider_variables, asi
-- que no sale del backend hacia Twilio ni queda escrita en la auditoria.
DELETE FROM template WHERE medium = 'WhatsApp'
  AND message_type IN ('PASSWORD_RECOVERY', 'WELCOME_OWNER', 'WELCOME_OWNER_DRIVER',
                       'WELCOME_DRIVER', 'SUBSCRIPTION_REMINDER');

-- cashtruck_recuperacion_contrasena | AUTHENTICATION | Categoría obligatoria: Meta exige AUTHENTICATION para cualquier código de un solo uso, y ahí el cuerpo es fijo. Por eso no lleva marca ni saludo; ver la seccion final sobre la marca.
INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'PASSWORD_RECOVERY', NULL,
'${code} es tu código de verificación. Por tu seguridad, no lo compartas.\n\nEste código caduca en 10 minutos.',
'Recuperación de contraseña');

-- cashtruck_bienvenida_propietario | UTILITY | Propietario que no conduce: conserva el paso de crear conductores.
INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'WELCOME_OWNER', NULL,
'🚀 Tu cuenta de CashTruck ya está activa 🚛\n\nHola ${name}, ya puedes gestionar tus vehículos y controlar tus costos.\n\n🔗 App: https://truck.ccsoluciones.com.co\n📧 Usuario: ${email}\n\n*Primeros pasos:*\n1️⃣ Crea tus conductores 👤\n2️⃣ Registra tus vehículos 🚛\n3️⃣ Crea viajes asignando conductor y vehículo 🗺️\n4️⃣ Anota los gastos de cada viaje 💸\n5️⃣ Registra los mantenimientos 🛠️\n6️⃣ Consulta tus rutas en el mapa 📍\n7️⃣ Revisa tus reportes 📊\n\n🤖 Mensaje automático, por favor no respondas a este número.',
'Bienvenido a CashTruck');

-- cashtruck_bienvenida_propietario_conductor | UTILITY | Propietario que también conduce: su conductor se crea solo, así que no aparece ese paso.
INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'WELCOME_OWNER_DRIVER', NULL,
'🚀 Tu cuenta de CashTruck ya está activa 🚛\n\nHola ${name}, ya puedes gestionar tus vehículos y controlar tus costos.\n\n🔗 App: https://truck.ccsoluciones.com.co\n📧 Usuario: ${email}\n\n*Primeros pasos:*\n1️⃣ Registra tus vehículos 🚛\n2️⃣ Crea viajes asignando tu vehículo 🗺️\n3️⃣ Anota los gastos de cada viaje 💸\n4️⃣ Registra los mantenimientos 🛠️\n5️⃣ Consulta tus rutas en el mapa 📍\n6️⃣ Revisa tus reportes 📊\n\n🤖 Mensaje automático, por favor no respondas a este número.',
'Bienvenido a CashTruck');

-- cashtruck_bienvenida_conductor | UTILITY | Conductor al que el propietario le dio acceso a la app.
INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'WELCOME_DRIVER', NULL,
'🚀 Tu cuenta de CashTruck ya está activa 🚛\n\nHola ${name}, ya puedes registrar tus viajes y gastos.\n\n🔗 App: https://truck.ccsoluciones.com.co\n📧 Usuario: ${email}\n\n*Primeros pasos:*\n1️⃣ Crea viajes asignando tu vehículo 🗺️\n2️⃣ Anota los gastos de cada viaje 💸\n3️⃣ Registra los mantenimientos 🛠️\n4️⃣ Consulta tus rutas en el mapa 📍\n5️⃣ Revisa tus reportes 📊\n\n🤖 Mensaje automático, por favor no respondas a este número.',
'Bienvenido a CashTruck');

-- cashtruck_aviso_suscripcion | UTILITY | Aviso de estado de la cuenta, sin precios ni oferta: eso es lo que lo mantiene en UTILITY y no en MARKETING.
INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject)
VALUES ('WhatsApp', 'SUBSCRIPTION_REMINDER', NULL,
'⏳ Tu suscripción a CashTruck está por vencer\n\nHola ${name}, tu suscripción finaliza el *${endDate}*, dentro de ${days} días.\n\nCuando venza perderás el acceso a tus viajes, vehículos, mantenimientos y reportes. Comunícate con el administrador para gestionar la renovación. 🔄\n\n🤖 Mensaje automático, por favor no respondas a este número.',
'Suscripción por vencer');

-- Orden en que Twilio numera las variables de cada plantilla aprobada: la
-- posicion tiene que coincidir con el {{n}} de la plantilla. La contrasena ya
-- no esta en la lista, asi que no se envia al proveedor.
UPDATE template SET provider_variables = 'code'
 WHERE medium = 'WhatsApp' AND message_type = 'PASSWORD_RECOVERY';

UPDATE template SET provider_variables = 'name,email'
 WHERE medium = 'WhatsApp'
   AND message_type IN ('WELCOME_OWNER', 'WELCOME_OWNER_DRIVER', 'WELCOME_DRIVER');

UPDATE template SET provider_variables = 'name,endDate,days'
 WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_REMINDER';

-- ContentSid de cada plantilla aprobada, identicos a los de scripts/info.sql.
-- Sin esto la base queda con provider_template_id en NULL y el backend envia
-- texto libre, que WhatsApp rechaza (63016) fuera de la ventana de 24 horas.
-- Al recrear una plantilla en Twilio cambia el HX: hay que actualizarlo en los
-- dos scripts y en la base ya desplegada, o Twilio responde 20404 "Content was
-- not found" por el HX viejo.

-- cashtruck_recuperacion_contrasena
UPDATE template SET provider_template_id = 'HX007954e19c9324b37c3fac3bb38323e8'
 WHERE medium = 'WhatsApp' AND message_type = 'PASSWORD_RECOVERY';

-- cashtruck_bienvenida_propietario
UPDATE template SET provider_template_id = 'HX076b7a60abab32ab1feacbf459cd86fb'
 WHERE medium = 'WhatsApp' AND message_type = 'WELCOME_OWNER';

-- cashtruck_bienvenida_propietario_conductor
UPDATE template SET provider_template_id = 'HXd8d59f0f3c09c6a37dd4c5342e619ba6'
 WHERE medium = 'WhatsApp' AND message_type = 'WELCOME_OWNER_DRIVER';

-- cashtruck_bienvenida_conductor
UPDATE template SET provider_template_id = 'HX08adab4a5ae2e03f516c9da42481b4b8'
 WHERE medium = 'WhatsApp' AND message_type = 'WELCOME_DRIVER';

-- cashtruck_aviso_suscripcion
UPDATE template SET provider_template_id = 'HX9d0d9af9996d7ed148cca856c8f46af6'
 WHERE medium = 'WhatsApp' AND message_type = 'SUBSCRIPTION_REMINDER';

-- Tipos de documento archivado. Agregar uno nuevo es un INSERT aqui: no
-- requiere desplegar backend.
INSERT INTO document_file_type (name, applies_to, requires_expiry) VALUES
('Tarjeta de Propiedad', 'VEHICLE', FALSE),
('SOAT', 'VEHICLE', TRUE),
('Revisión Tecnomecánica', 'VEHICLE', TRUE),
('Seguro Todo Riesgo', 'VEHICLE', TRUE),
('Tarjeta de Operación', 'VEHICLE', TRUE),
('Póliza de Responsabilidad Civil', 'VEHICLE', TRUE);

INSERT INTO document_file_type (name, applies_to, requires_expiry) VALUES
('Cédula de Ciudadanía', 'DRIVER', FALSE),
('Licencia de Conducción', 'DRIVER', TRUE),
('Certificado de ARL', 'DRIVER', TRUE),
('Examen Médico Ocupacional', 'DRIVER', TRUE);

INSERT INTO document_file_type (name, applies_to, requires_expiry) VALUES
('Cédula de Ciudadanía', 'OWNER', FALSE),
('RUT', 'OWNER', FALSE),
('Certificado de Cámara de Comercio', 'OWNER', TRUE);

-- ---------------------------------------------------------------------------------------------------------
-- 4. Informacion de los owners 2002 y 2005
-- ---------------------------------------------------------------------------------------------------------

-- users
INSERT INTO `users` (`id`,`name`,`email`,`password`,`status`,`creation_date`,`update_date`) VALUES
(2,'John H. Hernandez Ortiz','ing.jhenry@gmail.com','2f0c7da5508b153591fb83b8f0a416828d4a26a927597e0b74db7eda20952ab9372476a2473786695cd766fc69c2ea07d7924d3afdc05c8130291a95b38ee9d5','Activo','2026-08-09 17:07:50','2026-08-09 17:07:50'),
(3,'Julián Castro Solis','julianc477@gmail.com','8faae300719a589acd86611032588030449070abd8bfeaa511ef4a2d4a88783d1d080687f3261151f72dbf5db37ddda466c7d7d9242d1f6fd322d45e488f98d8','Activo','2026-08-25 12:16:03','2026-08-25 12:16:03');

-- user_role
INSERT INTO `user_role` (`id`,`user_id`,`role_id`,`creation_date`,`update_date`) VALUES
(2,2,2,'2026-08-09 17:07:50','2026-08-09 17:07:50'),
(3,3,2,'2026-08-25 12:16:03','2026-08-25 12:16:03');

-- owner
INSERT INTO `owner` (`id`,`photo`,`document_type_id`,`document_number`,`name`,`email`,`cell_phone`,`city_id`,`gender_id`,`birthdate`,`user_id`,`max_vehicles`,`is_driver`,`subscription_end_date`,`creation_date`,`update_date`) VALUES
(1,'https://truck.ccsoluciones.com.co/truck/images/owner/photo2002.webp',1,'1088589009','John H. Hernandez Ortiz','ing.jhenry@gmail.com','3126709282',32,1,'1986-05-07',2,3,0,'2027-07-21','2026-08-09 22:07:50','2026-08-27 03:41:17'),
(2,'https://truck.ccsoluciones.com.co/truck/images/owner/photo2005.webp',1,'87513683','Julián Castro Solis','julianc477@gmail.com','3014929602',3,1,'1984-03-27',3,3,0,'2027-08-25','2026-08-25 17:16:03','2026-08-27 03:41:17');

-- driver
INSERT INTO `driver` (`id`,`photo`,`document_type_id`,`document_number`,`name`,`email`,`cell_phone`,`city_id`,`gender_id`,`birthdate`,`salary_type_id`,`salary`,`license_category`,`license_number`,`license_expiry`,`user_id`,`owner_id`,`creation_date`,`update_date`) VALUES
(1,'',1,'1088596141','DIEGO HERNANDEZ','diefdoheim@gmail.com','3177626969',32,1,'1995-06-09',1,1400000,'c3','1088596141','2027-10-20',NULL,1,'2026-08-09 23:43:10','2026-08-27 03:42:09'),
(2,'',1,'5261667','José Burbano ','joseburbano123@gmail.com','3147796380',32,1,'1963-04-14',1,1400000,'c3','5261667','2027-08-18',NULL,1,'2026-08-19 23:09:06','2026-08-27 03:42:11');

-- vehicle
INSERT INTO `vehicle` (`id`,`photo`,`plate`,`current_driver_id`,`vehicle_brand_id`,`model`,`year`,`color`,`engine_number`,`chassis_number`,`number_of_axles`,`status`,`creation_date`,`update_date`) VALUES
(1,'https://truck.ccsoluciones.com.co/truck/images/vehicle/photo4002.webp','TFU-353',1,1,'T800',2012,'UVA',NULL,NULL,'2','Activo','2026-08-09 23:47:01','2026-08-09 23:47:02'),
(2,'https://truck.ccsoluciones.com.co/truck/images/vehicle/photo4005.webp','WRD-296',2,6,'Cargo',2006,'Negro',NULL,NULL,'2','Activo','2026-08-19 23:10:42','2026-08-19 23:11:29');

-- vehicle_owner
INSERT INTO `vehicle_owner` (`id`,`vehicle_id`,`owner_id`,`ownership_percentage`,`start_date`,`end_date`,`is_active`,`creation_date`,`update_date`) VALUES
(1,1,1,100.00,'2026-08-09',NULL,1,'2026-08-09 23:47:01','2026-08-09 23:47:01'),
(2,2,1,100.00,'2026-08-19',NULL,1,'2026-08-19 23:10:42','2026-08-19 23:10:42');

-- trip
INSERT INTO `trip` (`id`,`vehicle_id`,`driver_id`,`number_trip`,`manifest_number`,`company`,`origin_id`,`destination_id`,`return_destination_id`,`start_date`,`end_date`,`number_of_days`,`load_type`,`trip_type`,`current_leg`,`freight`,`advance_payment`,`paid_balance`,`status`,`creation_date`,`update_date`) VALUES
(1,1,1,1,'2600100041104M','Logística Avanzada',26,3,NULL,'2026-08-08 19:21:15','2026-08-09 20:03:41',2,'General','CARGADO',NULL,5900000.00,4721000.00,1,'Completado','2026-08-10 00:21:16','2026-08-10 01:03:41');

-- expense_category
INSERT INTO `expense_category` (`id`,`name`,`expense_type_id`,`owner_id`,`creation_date`,`update_date`) VALUES
(39,'DIARIOS CONDUCTOR',2,1,'2026-08-10 00:49:58','2026-08-10 00:49:58');

-- expense
INSERT INTO `expense` (`id`,`vehicle_id`,`trip_id`,`category_id`,`amount`,`expense_date`,`description`,`receipt_image_url`,`creation_date`,`update_date`) VALUES
(1,1,1,22,1.00,'2026-08-07','tanqueada pasto ida',NULL,'2026-08-10 00:45:24','2026-08-10 00:58:56'),
(2,1,1,22,1600000.00,'2026-08-09','tanqueada pasto ida',NULL,'2026-08-10 00:46:51','2026-08-10 00:46:51'),
(3,1,1,20,333120.00,'2026-08-09','cargue azucar',NULL,'2026-08-10 00:47:32','2026-08-10 00:47:32'),
(4,1,1,39,200000.00,'2026-08-09','DIARIOS',NULL,'2026-08-10 00:50:44','2026-08-10 00:50:44'),
(5,1,1,10,940000.00,'2026-08-09','PAGO SEGURO MULA',NULL,'2026-08-10 00:52:03','2026-08-10 00:52:03'),
(6,1,1,39,100000.00,'2026-08-09','DIARIO',NULL,'2026-08-10 00:52:35','2026-08-10 00:52:35'),
(7,1,1,22,500000.00,'2026-08-09','RETANQUEO',NULL,'2026-08-10 00:53:48','2026-08-10 00:53:48'),
(8,1,1,17,79000.00,'2026-08-09','',NULL,'2026-08-10 00:56:15','2026-08-10 00:56:15'),
(9,1,1,24,23600.00,'2026-08-09','',NULL,'2026-08-10 00:57:04','2026-08-10 00:57:04'),
(10,1,1,23,626000.00,'2026-08-09','PEAJES VIAJE REDONDO IPIALES TULCAN',NULL,'2026-08-10 01:01:11','2026-08-10 01:01:11'),
(11,1,NULL,26,5450000.00,'2026-08-09','PAGO CREDITO MULA MES DE AGOSTO',NULL,'2026-08-10 01:08:16','2026-08-10 01:08:16'),
(12,1,NULL,27,940000.00,'2026-08-09','PAGO SEGURO MULA MES DE AGOSTO',NULL,'2026-08-10 01:09:00','2026-08-10 01:09:00');

-- driver_locations
-- (sin registros para driver_locations)

-- notification
INSERT INTO `notification` (`id`,`event_type`,`message`,`target_user_id`,`target_role_id`,`owner_id`,`reference_id`,`is_read`,`is_deleted`,`creation_date`,`update_date`) VALUES
(1,'DRIVER_EVENT','Se ha creado un nuevo conductor: DIEGO HERNANDEZ',NULL,1,1,1,0,0,'2026-08-09 22:43:10','2026-08-09 22:43:10'),
(2,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-09 22:47:01','2026-08-09 22:47:01'),
(3,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 2600100041104M para el vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-09 23:21:16','2026-08-09 23:21:16'),
(4,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 2600100041104M para el vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-09 23:22:18','2026-08-09 23:22:18'),
(5,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $130.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-09 23:45:24','2026-08-09 23:45:24'),
(6,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $1.600.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-09 23:46:14','2026-08-09 23:46:14'),
(7,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $1.600.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,2,0,0,'2026-08-09 23:46:51','2026-08-09 23:46:51'),
(8,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $333.120 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,3,0,0,'2026-08-09 23:47:32','2026-08-09 23:47:32'),
(9,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $200.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,4,0,0,'2026-08-09 23:50:44','2026-08-09 23:50:44'),
(10,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $940.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,5,0,0,'2026-08-09 23:52:03','2026-08-09 23:52:03'),
(11,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $100.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,6,0,0,'2026-08-09 23:52:35','2026-08-09 23:52:35'),
(12,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $500.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,7,0,0,'2026-08-09 23:53:48','2026-08-09 23:53:48'),
(13,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $79.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,8,0,0,'2026-08-09 23:56:15','2026-08-09 23:56:15'),
(14,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $23.600 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,9,0,0,'2026-08-09 23:57:04','2026-08-09 23:57:04'),
(15,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $1 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-09 23:58:56','2026-08-09 23:58:56'),
(16,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $626.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,1,10,0,0,'2026-08-10 00:01:11','2026-08-10 00:01:11'),
(17,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 2600100041104M para el vehículo de placa: TFU-353',NULL,1,1,1,0,0,'2026-08-10 00:03:41','2026-08-10 00:03:41'),
(18,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $5.450.000 del vehículo de placa: TFU-353',NULL,1,1,11,0,0,'2026-08-10 00:08:16','2026-08-10 00:08:16'),
(19,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $940.000 del vehículo de placa: TFU-353',NULL,1,1,12,0,0,'2026-08-10 00:09:00','2026-08-10 00:09:00'),
(20,'DRIVER_EVENT','Se ha creado un nuevo conductor: José Burbano ',NULL,1,1,2,0,0,'2026-08-19 22:09:07','2026-08-19 22:09:07'),
(21,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: WRD-296',NULL,1,1,2,0,0,'2026-08-19 22:10:42','2026-08-19 22:10:42'),
(22,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: WRD-296',NULL,1,1,2,0,0,'2026-08-19 22:11:28','2026-08-19 22:11:28');

-- ---------------------------------------------------------------------------------------------------------
-- 5. Reinicio de los contadores AUTO_INCREMENT
-- ---------------------------------------------------------------------------------------------------------
ALTER TABLE users AUTO_INCREMENT = 6;
ALTER TABLE user_role AUTO_INCREMENT = 6;
ALTER TABLE owner AUTO_INCREMENT = 4;
ALTER TABLE driver AUTO_INCREMENT = 4;
ALTER TABLE vehicle AUTO_INCREMENT = 4;
ALTER TABLE vehicle_owner AUTO_INCREMENT = 4;
ALTER TABLE trip AUTO_INCREMENT = 6;
ALTER TABLE expense_category AUTO_INCREMENT = 40;
ALTER TABLE expense AUTO_INCREMENT = 33;
ALTER TABLE driver_locations AUTO_INCREMENT = 1;
ALTER TABLE notification AUTO_INCREMENT = 23;

-- ---------------------------------------------------------------------------------------------------------
-- 6. Verificacion
-- ---------------------------------------------------------------------------------------------------------
SELECT 'owner' AS tabla, COUNT(*) AS registros FROM owner
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'user_role', COUNT(*) FROM user_role
UNION ALL SELECT 'driver', COUNT(*) FROM driver
UNION ALL SELECT 'vehicle', COUNT(*) FROM vehicle
UNION ALL SELECT 'vehicle_owner', COUNT(*) FROM vehicle_owner
UNION ALL SELECT 'trip', COUNT(*) FROM trip
UNION ALL SELECT 'expense', COUNT(*) FROM expense
UNION ALL SELECT 'expense_category', COUNT(*) FROM expense_category
UNION ALL SELECT 'driver_locations', COUNT(*) FROM driver_locations
UNION ALL SELECT 'notification', COUNT(*) FROM notification
UNION ALL SELECT 'document_file_type', COUNT(*) FROM document_file_type
UNION ALL SELECT 'document_file', COUNT(*) FROM document_file;
