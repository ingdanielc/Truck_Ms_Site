-- ---------------------------------------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------------------------------------

CREATE DATABASE cashTruck;
USE cashTruck;

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
