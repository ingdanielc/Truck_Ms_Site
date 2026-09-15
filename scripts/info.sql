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

INSERT INTO city (name, state)
SELECT 'Leticia', 'Amazonas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Leticia' AND state = 'Amazonas'
);

INSERT INTO city (name, state)
SELECT 'Puerto Nariño', 'Amazonas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Nariño' AND state = 'Amazonas'
);

-- =========================
-- ANTIOQUIA
-- =========================

INSERT INTO city (name, state)
SELECT 'Carepa', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Carepa' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Chigorodó', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chigorodó' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'La Ceja', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Ceja' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Marinilla', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Marinilla' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Guarne', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guarne' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Copacabana', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Copacabana' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Girardota', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Girardota' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Sabaneta', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sabaneta' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'La Estrella', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Estrella' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'El Carmen de Viboral', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Carmen de Viboral' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Santa Rosa de Osos', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santa Rosa de Osos' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Yarumal', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Yarumal' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Puerto Berrío', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Berrío' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Sonsón', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sonsón' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Amalfi', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Amalfi' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Segovia', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Segovia' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Remedios', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Remedios' AND state = 'Antioquia'
);

INSERT INTO city (name, state)
SELECT 'Urrao', 'Antioquia'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Urrao' AND state = 'Antioquia'
);

-- =========================
-- ARAUCA
-- =========================

INSERT INTO city (name, state)
SELECT 'Arauquita', 'Arauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Arauquita' AND state = 'Arauca'
);

INSERT INTO city (name, state)
SELECT 'Tame', 'Arauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tame' AND state = 'Arauca'
);

INSERT INTO city (name, state)
SELECT 'Fortul', 'Arauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Fortul' AND state = 'Arauca'
);

-- =========================
-- ATLÁNTICO
-- =========================

INSERT INTO city (name, state)
SELECT 'Sabanalarga', 'Atlántico'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sabanalarga' AND state = 'Atlántico'
);

INSERT INTO city (name, state)
SELECT 'Puerto Colombia', 'Atlántico'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Colombia' AND state = 'Atlántico'
);

INSERT INTO city (name, state)
SELECT 'Baranoa', 'Atlántico'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Baranoa' AND state = 'Atlántico'
);

INSERT INTO city (name, state)
SELECT 'Galapa', 'Atlántico'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Galapa' AND state = 'Atlántico'
);

INSERT INTO city (name, state)
SELECT 'Santo Tomás', 'Atlántico'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santo Tomás' AND state = 'Atlántico'
);

INSERT INTO city (name, state)
SELECT 'Juan de Acosta', 'Atlántico'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Juan de Acosta' AND state = 'Atlántico'
);

-- =========================
-- BOLÍVAR
-- =========================

INSERT INTO city (name, state)
SELECT 'Turbaco', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Turbaco' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'Arjona', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Arjona' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'El Carmen de Bolívar', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Carmen de Bolívar' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'Mompox', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Mompox' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'San Juan Nepomuceno', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Juan Nepomuceno' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'Santa Rosa del Sur', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santa Rosa del Sur' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'San Pablo', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Pablo' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'María La Baja', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'María La Baja' AND state = 'Bolívar'
);

INSERT INTO city (name, state)
SELECT 'Clemencia', 'Bolívar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Clemencia' AND state = 'Bolívar'
);

-- =========================
-- BOYACÁ
-- =========================

INSERT INTO city (name, state)
SELECT 'Chiquinquirá', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chiquinquirá' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Paipa', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Paipa' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Villa de Leyva', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villa de Leyva' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Puerto Boyacá', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Boyacá' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Moniquirá', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Moniquirá' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Garagoa', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Garagoa' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Soatá', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Soatá' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Samacá', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Samacá' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Nobsa', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Nobsa' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Monguí', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Monguí' AND state = 'Boyacá'
);

INSERT INTO city (name, state)
SELECT 'Tibasosa', 'Boyacá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tibasosa' AND state = 'Boyacá'
);

-- =========================
-- CALDAS
-- =========================

INSERT INTO city (name, state)
SELECT 'Chinchiná', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chinchiná' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Villamaría', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villamaría' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Riosucio', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Riosucio' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Anserma', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Anserma' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Supía', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Supía' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Aguadas', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Aguadas' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Salamina', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Salamina' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Neira', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Neira' AND state = 'Caldas'
);

INSERT INTO city (name, state)
SELECT 'Pensilvania', 'Caldas'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Pensilvania' AND state = 'Caldas'
);

-- =========================
-- CAQUETÁ
-- =========================

INSERT INTO city (name, state)
SELECT 'San Vicente del Caguán', 'Caquetá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Vicente del Caguán' AND state = 'Caquetá'
);

INSERT INTO city (name, state)
SELECT 'Puerto Rico', 'Caquetá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Rico' AND state = 'Caquetá'
);

INSERT INTO city (name, state)
SELECT 'El Doncello', 'Caquetá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Doncello' AND state = 'Caquetá'
);

INSERT INTO city (name, state)
SELECT 'La Montañita', 'Caquetá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Montañita' AND state = 'Caquetá'
);

INSERT INTO city (name, state)
SELECT 'Belén de los Andaquíes', 'Caquetá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Belén de los Andaquíes' AND state = 'Caquetá'
);

INSERT INTO city (name, state)
SELECT 'Curillo', 'Caquetá'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Curillo' AND state = 'Caquetá'
);

-- =========================
-- CASANARE
-- =========================

INSERT INTO city (name, state)
SELECT 'Aguazul', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Aguazul' AND state = 'Casanare'
);

INSERT INTO city (name, state)
SELECT 'Villanueva', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villanueva' AND state = 'Casanare'
);

INSERT INTO city (name, state)
SELECT 'Paz de Ariporo', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Paz de Ariporo' AND state = 'Casanare'
);

INSERT INTO city (name, state)
SELECT 'Tauramena', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tauramena' AND state = 'Casanare'
);

INSERT INTO city (name, state)
SELECT 'Monterrey', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Monterrey' AND state = 'Casanare'
);

INSERT INTO city (name, state)
SELECT 'Maní', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Maní' AND state = 'Casanare'
);

INSERT INTO city (name, state)
SELECT 'Hato Corozal', 'Casanare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Hato Corozal' AND state = 'Casanare'
);

-- =========================
-- CAUCA
-- =========================

INSERT INTO city (name, state)
SELECT 'Patía', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Patía' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Piendamó', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Piendamó' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Guapi', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guapi' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'El Tambo', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Tambo' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Cajibío', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cajibío' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Villa Rica', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villa Rica' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Miranda', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Miranda' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Corinto', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Corinto' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Caloto', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Caloto' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Suárez', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Suárez' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Morales', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Morales' AND state = 'Cauca'
);

INSERT INTO city (name, state)
SELECT 'Timbío', 'Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Timbío' AND state = 'Cauca'
);

-- =========================
-- CESAR
-- =========================

INSERT INTO city (name, state)
SELECT 'Codazzi', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Codazzi' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'Curumaní', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Curumaní' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'Chiriguaná', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chiriguaná' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'La Jagua de Ibirico', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Jagua de Ibirico' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'Becerril', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Becerril' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'San Alberto', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Alberto' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'San Martín', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Martín' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'El Copey', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Copey' AND state = 'Cesar'
);

INSERT INTO city (name, state)
SELECT 'Pelaya', 'Cesar'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Pelaya' AND state = 'Cesar'
);

-- =========================
-- CHOCÓ
-- =========================

INSERT INTO city (name, state)
SELECT 'Istmina', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Istmina' AND state = 'Chocó'
);

INSERT INTO city (name, state)
SELECT 'Tadó', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tadó' AND state = 'Chocó'
);

INSERT INTO city (name, state)
SELECT 'Condoto', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Condoto' AND state = 'Chocó'
);

INSERT INTO city (name, state)
SELECT 'Riosucio', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Riosucio' AND state = 'Chocó'
);

INSERT INTO city (name, state)
SELECT 'Acandí', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Acandí' AND state = 'Chocó'
);

INSERT INTO city (name, state)
SELECT 'Bahía Solano', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Bahía Solano' AND state = 'Chocó'
);

INSERT INTO city (name, state)
SELECT 'Nuquí', 'Chocó'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Nuquí' AND state = 'Chocó'
);

-- =========================
-- CÓRDOBA
-- =========================

INSERT INTO city (name, state)
SELECT 'Cereté', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cereté' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Sahagún', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sahagún' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Planeta Rica', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Planeta Rica' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Tierralta', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tierralta' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Montelíbano', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Montelíbano' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Ciénaga de Oro', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ciénaga de Oro' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Chinú', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chinú' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'Puerto Libertador', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Libertador' AND state = 'Córdoba'
);

INSERT INTO city (name, state)
SELECT 'San Pelayo', 'Córdoba'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Pelayo' AND state = 'Córdoba'
);

-- =========================
-- CUNDINAMARCA
-- =========================

INSERT INTO city (name, state)
SELECT 'Chía', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chía' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Cajicá', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cajicá' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Madrid', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Madrid' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Sopó', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sopó' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'La Calera', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Calera' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Villeta', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villeta' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Ubaté', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ubaté' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Guaduas', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guaduas' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'La Mesa', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Mesa' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Anapoima', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Anapoima' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Cáqueza', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cáqueza' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Pacho', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Pacho' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Chocontá', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chocontá' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Sibaté', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sibaté' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'El Colegio', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Colegio' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Tabio', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tabio' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Tenjo', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tenjo' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Suesca', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Suesca' AND state = 'Cundinamarca'
);

INSERT INTO city (name, state)
SELECT 'Nocaima', 'Cundinamarca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Nocaima' AND state = 'Cundinamarca'
);

-- =========================
-- GUAINÍA
-- =========================

INSERT INTO city (name, state)
SELECT 'Inírida', 'Guainía'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Inírida' AND state = 'Guainía'
);

-- =========================
-- GUAVIARE
-- =========================

INSERT INTO city (name, state)
SELECT 'San José del Guaviare', 'Guaviare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San José del Guaviare' AND state = 'Guaviare'
);

INSERT INTO city (name, state)
SELECT 'Calamar', 'Guaviare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Calamar' AND state = 'Guaviare'
);

INSERT INTO city (name, state)
SELECT 'El Retorno', 'Guaviare'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Retorno' AND state = 'Guaviare'
);

-- =========================
-- HUILA
-- =========================

INSERT INTO city (name, state)
SELECT 'La Plata', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Plata' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Campoalegre', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Campoalegre' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Gigante', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Gigante' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Guadalupe', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guadalupe' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'San Agustín', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Agustín' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Aipe', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Aipe' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Palermo', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Palermo' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Rivera', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Rivera' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Timaná', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Timaná' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Acevedo', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Acevedo' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Tesalia', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tesalia' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Hobo', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Hobo' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Algeciras', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Algeciras' AND state = 'Huila'
);

INSERT INTO city (name, state)
SELECT 'Villavieja', 'Huila'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villavieja' AND state = 'Huila'
);

-- =========================
-- LA GUAJIRA
-- =========================

INSERT INTO city (name, state)
SELECT 'Uribia', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Uribia' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Manaure', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Manaure' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'San Juan del Cesar', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Juan del Cesar' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Fonseca', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Fonseca' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Villanueva', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villanueva' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Barrancas', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Barrancas' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Albania', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Albania' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Hatonuevo', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Hatonuevo' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Distracción', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Distracción' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'Dibulla', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Dibulla' AND state = 'La Guajira'
);

INSERT INTO city (name, state)
SELECT 'El Molino', 'La Guajira'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Molino' AND state = 'La Guajira'
);

-- =========================
-- MAGDALENA
-- =========================

INSERT INTO city (name, state)
SELECT 'Ciénaga', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ciénaga' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Fundación', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Fundación' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'El Banco', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Banco' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Plato', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Plato' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Aracataca', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Aracataca' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Zona Bananera', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Zona Bananera' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Pivijay', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Pivijay' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Santa Ana', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santa Ana' AND state = 'Magdalena'
);

INSERT INTO city (name, state)
SELECT 'Guamal', 'Magdalena'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guamal' AND state = 'Magdalena'
);

-- =========================
-- META
-- =========================

INSERT INTO city (name, state)
SELECT 'Puerto López', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto López' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'Puerto Gaitán', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Gaitán' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'San Martín', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Martín' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'Cumaral', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cumaral' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'Restrepo', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Restrepo' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'Guamal', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guamal' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'Castilla La Nueva', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Castilla La Nueva' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'Vista Hermosa', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Vista Hermosa' AND state = 'Meta'
);

INSERT INTO city (name, state)
SELECT 'La Macarena', 'Meta'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Macarena' AND state = 'Meta'
);

-- =========================
-- NARIÑO
-- =========================

INSERT INTO city (name, state)
SELECT 'Barbacoas', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Barbacoas' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'El Charco', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Charco' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Sandoná', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sandoná' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'La Cruz', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Cruz' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Buesaco', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Buesaco' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Consacá', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Consacá' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Chachagüí', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chachagüí' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'El Tambo', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Tambo' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Tangua', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tangua' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Yacuanquer', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Yacuanquer' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Aldana', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Aldana' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Cuaspud', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cuaspud' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Pupiales', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Pupiales' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Puerres', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerres' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Funes', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Funes' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Gualmatán', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Gualmatán' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Ospina', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ospina' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Ricaurte', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ricaurte' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Linares', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Linares' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Policarpa', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Policarpa' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Leiva', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Leiva' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Los Andes', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Los Andes' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'La Florida', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Florida' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Taminango', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Taminango' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'San Lorenzo', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Lorenzo' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Mallama', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Mallama' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Mosquera', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Mosquera' AND state = 'Nariño'
);

INSERT INTO city (name, state)
SELECT 'Olaya Herrera', 'Nariño'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Olaya Herrera' AND state = 'Nariño'
);

-- =========================
-- NORTE DE SANTANDER
-- =========================

INSERT INTO city (name, state)
SELECT 'Villa del Rosario', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villa del Rosario' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Los Patios', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Los Patios' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'El Zulia', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Zulia' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Tibú', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tibú' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Abrego', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Abrego' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Convención', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Convención' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Chinácota', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chinácota' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Sardinata', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sardinata' AND state = 'Norte de Santander'
);

INSERT INTO city (name, state)
SELECT 'Toledo', 'Norte de Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Toledo' AND state = 'Norte de Santander'
);

-- =========================
-- PUTUMAYO
-- =========================

INSERT INTO city (name, state)
SELECT 'Valle del Guamuez', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Valle del Guamuez' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'La Hormiga', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Hormiga' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'Villagarzón', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Villagarzón' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'Puerto Caicedo', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Caicedo' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'Puerto Guzmán', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Guzmán' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'San Miguel', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Miguel' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'Sibundoy', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sibundoy' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'Colón', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Colón' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'Santiago', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santiago' AND state = 'Putumayo'
);

INSERT INTO city (name, state)
SELECT 'San Francisco', 'Putumayo'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Francisco' AND state = 'Putumayo'
);

-- =========================
-- QUINDÍO
-- =========================

INSERT INTO city (name, state)
SELECT 'Montenegro', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Montenegro' AND state = 'Quindío'
);

INSERT INTO city (name, state)
SELECT 'La Tebaida', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Tebaida' AND state = 'Quindío'
);

INSERT INTO city (name, state)
SELECT 'Quimbaya', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Quimbaya' AND state = 'Quindío'
);

INSERT INTO city (name, state)
SELECT 'Circasia', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Circasia' AND state = 'Quindío'
);

INSERT INTO city (name, state)
SELECT 'Filandia', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Filandia' AND state = 'Quindío'
);

INSERT INTO city (name, state)
SELECT 'Salento', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Salento' AND state = 'Quindío'
);

INSERT INTO city (name, state)
SELECT 'Génova', 'Quindío'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Génova' AND state = 'Quindío'
);

-- =========================
-- RISARALDA
-- =========================

INSERT INTO city (name, state)
SELECT 'Santa Rosa de Cabal', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santa Rosa de Cabal' AND state = 'Risaralda'
);

INSERT INTO city (name, state)
SELECT 'La Virginia', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Virginia' AND state = 'Risaralda'
);

INSERT INTO city (name, state)
SELECT 'Belén de Umbría', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Belén de Umbría' AND state = 'Risaralda'
);

INSERT INTO city (name, state)
SELECT 'Marsella', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Marsella' AND state = 'Risaralda'
);

INSERT INTO city (name, state)
SELECT 'Santuario', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santuario' AND state = 'Risaralda'
);

INSERT INTO city (name, state)
SELECT 'Apía', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Apía' AND state = 'Risaralda'
);

INSERT INTO city (name, state)
SELECT 'Quinchía', 'Risaralda'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Quinchía' AND state = 'Risaralda'
);

-- =========================
-- SANTANDER
-- =========================

INSERT INTO city (name, state)
SELECT 'Floridablanca', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Floridablanca' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Girón', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Girón' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Piedecuesta', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Piedecuesta' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Socorro', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Socorro' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Barbosa', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Barbosa' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Vélez', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Vélez' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Málaga', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Málaga' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Sabana de Torres', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sabana de Torres' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Puerto Wilches', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Wilches' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Cimitarra', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cimitarra' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'San Vicente de Chucurí', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Vicente de Chucurí' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Lebrija', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Lebrija' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Rionegro', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Rionegro' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Charalá', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Charalá' AND state = 'Santander'
);

INSERT INTO city (name, state)
SELECT 'Zapatoca', 'Santander'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Zapatoca' AND state = 'Santander'
);

-- =========================
-- SUCRE
-- =========================

INSERT INTO city (name, state)
SELECT 'Corozal', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Corozal' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'Sampués', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sampués' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'San Marcos', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Marcos' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'Tolú', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Tolú' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'Coveñas', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Coveñas' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'San Onofre', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Onofre' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'Majagual', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Majagual' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'Ovejas', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ovejas' AND state = 'Sucre'
);

INSERT INTO city (name, state)
SELECT 'Sincé', 'Sucre'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sincé' AND state = 'Sucre'
);

-- =========================
-- TOLIMA
-- =========================

INSERT INTO city (name, state)
SELECT 'Honda', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Honda' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Mariquita', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Mariquita' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Líbano', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Líbano' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Chaparral', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Chaparral' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Guamo', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guamo' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Flandes', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Flandes' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Purificación', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Purificación' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Fresno', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Fresno' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Natagaima', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Natagaima' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Ortega', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ortega' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Saldaña', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Saldaña' AND state = 'Tolima'
);

INSERT INTO city (name, state)
SELECT 'Venadillo', 'Tolima'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Venadillo' AND state = 'Tolima'
);

-- =========================
-- VALLE DEL CAUCA
-- =========================

INSERT INTO city (name, state)
SELECT 'Yumbo', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Yumbo' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Candelaria', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Candelaria' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Dagua', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Dagua' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Florida', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Florida' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Pradera', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Pradera' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Zarzal', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Zarzal' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Roldanillo', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Roldanillo' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Sevilla', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Sevilla' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Caicedonia', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Caicedonia' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'El Cerrito', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'El Cerrito' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Guacarí', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Guacarí' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Andalucía', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Andalucía' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'San Pedro', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'San Pedro' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Ginebra', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Ginebra' AND state = 'Valle del Cauca'
);

INSERT INTO city (name, state)
SELECT 'Vijes', 'Valle del Cauca'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Vijes' AND state = 'Valle del Cauca'
);

-- =========================
-- VAUPÉS
-- =========================

INSERT INTO city (name, state)
SELECT 'Mitú', 'Vaupés'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Mitú' AND state = 'Vaupés'
);

-- =========================
-- VICHADA
-- =========================

INSERT INTO city (name, state)
SELECT 'Puerto Carreño', 'Vichada'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Puerto Carreño' AND state = 'Vichada'
);

INSERT INTO city (name, state)
SELECT 'La Primavera', 'Vichada'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'La Primavera' AND state = 'Vichada'
);

INSERT INTO city (name, state)
SELECT 'Santa Rosalía', 'Vichada'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Santa Rosalía' AND state = 'Vichada'
);

INSERT INTO city (name, state)
SELECT 'Cumaribo', 'Vichada'
WHERE NOT EXISTS (
    SELECT 1 FROM city WHERE name = 'Cumaribo' AND state = 'Vichada'
);

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
	('Iveco'),
    ('Otra');
    
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
('Porcentaje por viaje', 2),
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
