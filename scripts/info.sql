-- ---------------------------------------------------------------------------------------------------------
-- Información tablas parametricas
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
('Alimentacion conductor', 2),
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
INSERT INTO template (medium, message_type, attachment_url_default, template_content, template_subject) 
VALUES 
('WhatsApp', 'BIENVENIDA', 'https://instecdevstrgaccount.blob.core.windows.net/instecdevsalesstaticcontent/Bancolombia/notificaciones/bienvenido.jpg', 'Hola ${partnerName}, gracias por unirte a nuestra comunidad fitness. \n\n💯 Estamos emocionados de acompañarte en tu camino hacia una vida más saludable y activa. \n\n🏋️‍♀️ Horarios: Lunes a Sabado \n📍 Ubicación: Calle 19 \n📲 Contacto: 3127199944. \n\nSi tienes alguna pregunta o necesitas ayuda, nuestro equipo está aquí para apoyarte.\n\n💪 Nos vemos en el gimnasio. ¡A romperla! 🚀🔥', ''),
('Email', 'BIENVENIDA', '', 'Hola ${partnerName}, gracias por unirte a nuestra comunidad fitness. \n\n💯 Estamos emocionados de acompañarte en tu camino hacia una vida más saludable y activa. \n\n🏋️‍♀️ Horarios: Lunes a Sabado \n📍 Ubicación: Calle 19 \n📲 Contacto: 3127199944. \n\nSi tienes alguna pregunta o necesitas ayuda, nuestro equipo está aquí para apoyarte.\n\n💪 Nos vemos en el gimnasio. ¡A romperla! 🚀🔥', 'Bienvenido'),
('Sms', 'BIENVENIDA', '', 'Hola ${partnerName}, gracias por unirte a nuestra comunidad fitness. \n\n💯 Estamos emocionados de acompañarte en tu camino hacia una vida más saludable y activa. \n\n🏋️‍♀️ Horarios: Lunes a Sabado \n📍 Ubicación: Calle 19 \n📲 Contacto: 3127199944. \n\nSi tienes alguna pregunta o necesitas ayuda, nuestro equipo está aquí para apoyarte.\n\n💪 Nos vemos en el gimnasio. ¡A romperla! 🚀🔥', ''),
('WhatsApp', 'COMPRA_MEMBRESIA', 'https://instecdevstrgaccount.blob.core.windows.net/instecdevsalesstaticcontent/Bancolombia/notificaciones/bienvenido.jpg', 'Hola ${partnerName}, gracias por confiar en nosotros. 🏋️‍♂️🔥\nTu membresía ha sido procesada correctamente.\n\n📅 Fecha de inicio: ${startDate}\n📅 Fecha de vencimiento: ${endDate}\n💳 Plan adquirido: ${membershipName}\n\nRecuerda que estamos aquí para apoyarte en tu camino fitness. Si tienes alguna duda, contáctanos. \n\n📲¡Nos vemos en el gimnasio! 💪😃', '');


INSERT INTO notification (
    event_type, 
    message, 
    reference_id, 
    target_role_id, 
    is_read, 
    is_deleted, 
    creation_date, 
    update_date
) VALUES 
('TRIP_EVENT', 'Se ha creado un nuevo viaje con manifiesto: MF00031', 13, 1, FALSE, FALSE, '2026-03-07 00:50:42', '2026-03-07 00:50:42'),
('VEHICLE_EVENT', 'Se ha actualizado el vehículo con placa: TRH-982', 14, 1, FALSE, FALSE, '2026-03-07 00:57:20', '2026-03-07 00:57:20'),
('DRIVER_EVENT', 'Se ha actualizado el conductor: Juan Perea', 17, 1, FALSE, FALSE, '2026-03-07 01:06:19', '2026-03-07 01:06:19'),
('DRIVER_EVENT', 'Se ha actualizado el conductor: Pedro Fernandez', 13, 1, FALSE, FALSE, '2026-03-07 01:06:52', '2026-03-07 01:06:52'),
('TRIP_EVENT', 'Se ha actualizado el viaje con manifiesto: Mf0004', 19, 1, FALSE, FALSE, '2026-03-07 01:08:22', '2026-03-07 01:08:22');

INSERT INTO driver_locations 
(driver_id, vehicle_id, trip_id, latitude, longitude, speed_kmh, address_text, creation_date) 
VALUES
(1, 1, 1, 0.82500000, -77.64200000, 0.00, 'Salida Ipiales - Terminal', '2026-03-25 08:00:00'),
(1, 1, 1, 0.90500000, -77.58500000, 45.50, 'Vía Panamericana - El Contadero', '2026-03-25 08:15:00'),
(1, 1, 1, 1.01200000, -77.45200000, 35.20, 'Descenso hacia el Río Guáitara', '2026-03-25 08:30:00'),
(1, 1, 1, 1.12300000, -77.38200000, 40.00, 'Aproximación a Tangua', '2026-03-25 08:45:00'),
(1, 1, 1, 1.21300000, -77.28100000, 50.10, 'Entrada a Pasto - Sector Catambuco', '2026-03-25 09:00:00'),
(1, 1, 1, 1.25000000, -77.26500000, 20.00, 'Paso Urbano Pasto', '2026-03-25 09:15:00'),
(1, 1, 1, 1.35200000, -77.18500000, 65.40, 'Vía Chachagüí - Cerca Aeropuerto', '2026-03-25 09:30:00'),
(1, 1, 1, 1.48500000, -77.10200000, 42.00, 'Cañón del Juanambú', '2026-03-25 09:45:00'),
(1, 1, 1, 1.61200000, -77.05200000, 55.00, 'Sector El Remolino', '2026-03-25 10:00:00'),
(1, 1, 1, 1.74500000, -77.01200000, 60.80, 'Mojarras, Cauca', '2026-03-25 10:15:00'),
(1, 1, 1, 1.88500000, -76.98500000, 58.00, 'Aproximación a El Bordo', '2026-03-25 10:30:00'),
(1, 1, 1, 2.11200000, -76.85200000, 62.10, 'Piedra de Sentura', '2026-03-25 10:45:00'),
(1, 1, 1, 2.25400000, -76.75200000, 55.30, 'Rosas, Cauca', '2026-03-25 11:00:00'),
(1, 1, 1, 2.35200000, -76.65200000, 48.00, 'Sector Timbío', '2026-03-25 11:15:00'),
(1, 1, 1, 2.44100000, -76.60600000, 30.00, 'Entrada a Popayán', '2026-03-25 11:30:00'),
(1, 1, 1, 2.50200000, -76.58200000, 75.00, 'Variante Popayán - Norte', '2026-03-25 11:45:00'),
(1, 1, 1, 2.65200000, -76.52500000, 80.20, 'Vía Piendamó', '2026-03-25 12:00:00'),
(1, 1, 1, 2.78500000, -76.48500000, 78.50, 'Túnel, Cauca', '2026-03-25 12:15:00'),
(1, 1, 1, 2.91200000, -76.42500000, 82.00, 'Sector Mondomo', '2026-03-25 12:30:00'),
(1, 1, 1, 3.01200000, -76.40200000, 70.00, 'Santander de Quilichao', '2026-03-25 12:45:00'),
(1, 1, 1, 3.12500000, -76.38500000, 85.00, 'Recta hacia Villa Rica', '2026-03-25 13:00:00'),
(1, 1, 1, 3.19500000, -76.41200000, 88.00, 'Peaje Villa Rica', '2026-03-25 13:15:00'),
(1, 1, 1, 3.25400000, -76.45200000, 90.50, 'Límite Cauca - Valle', '2026-03-25 13:30:00'),
(1, 1, 1, 3.31200000, -76.48500000, 85.00, 'Paso por Jamundí', '2026-03-25 13:45:00'),
(1, 1, 1, 3.35200000, -76.51200000, 82.00, 'Vía Cañasgordas', '2026-03-25 14:00:00'),
(1, 1, 1, 3.38500000, -76.52500000, 60.00, 'Entrada a Cali - Sector Pance', '2026-03-25 14:15:00'),
(1, 1, 1, 3.41200000, -76.53500000, 55.00, 'Calle 5 - Unicentro', '2026-03-25 14:30:00'),
(1, 1, 1, 3.43500000, -76.52500000, 40.20, 'Calle 5 con Carrera 66', '2026-03-25 14:45:00'),
(1, 1, 1, 3.45000000, -76.53200000, 30.00, 'Sector Imbanaco', '2026-03-25 15:00:00'),
(1, 1, 1, 3.46200000, -76.52800000, 0.00, 'Llegada Destino - Centro Cali', '2026-03-25 15:15:00');





















