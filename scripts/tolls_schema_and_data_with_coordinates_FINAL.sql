-- ============================================================
-- CashTruck - Colombia Toll Catalog
-- Structure + complete data from cashtruck_tolls_with_coordinates.csv
-- ============================================================

SET NAMES utf8mb4;

DROP TABLE IF EXISTS toll_rate;
DROP TABLE IF EXISTS toll;

CREATE TABLE IF NOT EXISTS toll (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    toll_key VARCHAR(150) NOT NULL,
    name VARCHAR(150) NOT NULL,
    department VARCHAR(100),
    municipality VARCHAR(100),
    divipola VARCHAR(20),
    project VARCHAR(255),
    current_administrator VARCHAR(150),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    active TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uk_toll_key (toll_key),
    KEY idx_toll_name (name),
    KEY idx_toll_location (department, municipality),
    KEY idx_toll_coordinates (latitude, longitude),
    KEY idx_toll_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS toll_rate (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    toll_id BIGINT UNSIGNED NOT NULL,
    category VARCHAR(20) NOT NULL,
    rate INT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    source VARCHAR(255),
    source_entity VARCHAR(100),
    PRIMARY KEY (id),
    CONSTRAINT fk_toll_rate_toll FOREIGN KEY (toll_id)
        REFERENCES toll(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY uk_toll_category_start (toll_id, category, start_date),
    KEY idx_toll_rate_search (toll_id, category, start_date, end_date),
    KEY idx_toll_rate_validity (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT * FROM toll;
SELECT * FROM toll WHERE latitude IS NULL;
SELECT * FROM toll_rate;

START TRANSACTION;

INSERT INTO toll
(toll_key,name,department,municipality,divipola,project,
 current_administrator,latitude,longitude)
VALUES
('ABURRA','ABURRÁ','Antioquia','Medellín','5001.0','Autopista al Mar 1','ANI',6.293192,-75.651083),
('ACAPULCO','ACAPULCO','Caldas','Belalcázar','17088.0','Autopista Conexión Pacífico 3','ANI',4.999062,-75.858871),
('AGUAS NEGRAS','AGUAS NEGRAS','Santander','Puerto Parra','68573.0','Troncal del Magdalena Puerto Salgar - Barrancabermeja C1.','ANI',6.645326,-73.952462),
('ALBARRACIN','ALBARRACÍN','Cundinamarca','Villapinzón','25873.0','Briceño - Tunja - Sogamoso','ANI',5.290677,-73.583504),
('ALTAMIRA','ALTAMIRA','Huila','Altamira','41026.0','Santana - Mocoa - Neiva','ANI',2.142885,-75.700684),
('ALTO PINO','ALTO PINO','La Guajira','Manaure','44560.0','Santa Marta - Riohacha - Paraguachón','ANI',11.444818,-72.542564),
('ALVARADO','ALVARADO','Tolima','Alvarado','73026.0','APP IP - Cambao - Manizales.','ANI',4.507609,-74.991661),
('AMAGA','AMAGÁ','Antioquia','Caldas','5129.0','Autopista Conexión Pacífico 1','ANI',6.046949,-75.659874),
('ANDES','ANDES','Cundinamarca','Chía','25175.0','IP - Accesos Norte a Bogotá','ANI',4.830003,-74.033081),
('ARCABUCO','ARCABUCO','Boyacá',NULL,NULL,NULL,'INVIAS',5.79502466,-73.47761994),
('ARMERO','ARMERO','Tolima','Lérida','73408.0','APP IP - Cambao - Manizales.','ANI',4.958352,-74.914426),
('ARROYO DE PIEDRA','ARROYO DE PIEDRA','Atlántico','Repelón','8606.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','ANI',10.650256,-75.066936),
('BAYUNCA','BAYUNCA','Bolívar','Clemencia','13222.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','INVIAS',10.546992,-75.365173),
('BICENTENARIO','BICENTENARIO','Cundinamarca',NULL,NULL,NULL,'INVIAS',5.20310294,-74.68461735),
('BOQUERON I','BOQUERÓN I','Cundinamarca','Chipaque','25178.0','IP - Chirajara - Fundadores','ANI',4.452599,-74.073395),
('BOQUERON II','BOQUERÓN II','Cundinamarca','Chipaque','25178.0','IP - Chirajara - Fundadores','ANI',4.454584,-74.05033),
('BRISAS','BRISAS','Cundinamarca','Puerto Salgar','25572.0','Honda - Puerto Salgar - Girardot','ANI',5.458545,-74.639726),
('CABILDO','CABILDO','Antioquia','Girardota','5308.0','IP - Vías del Nus','ANI',6.395797,-75.423661),
('CAIMANERA','CAIMANERA','Sucre','Coveñas','70221.0','IP - Antioquia - Bolívar','ANI',9.465677,-75.606506),
('CAIQUERO','CAIQUERO','Cundinamarca','Nocaima','25491.0','Santafé de Bogotá (Puente el Cortijo)  - Siberia - La Punta - El Vino - La Vega - Villeta','ANI',5.065366,-74.414108),
('CALAMAR','CALAMAR','Bolívar','Calamar','13140.0','Puerta de Hierro - Palmar de Varela y Carreto - Cruz del Viso','ANI',10.208106,-74.945015),
('CAMBAO','CAMBAO','Cundinamarca','San Juan de Río Seco','25662.0','Honda - Puerto Salgar - Girardot','ANI',4.946412,-74.719094),
('CANO','CANO','Nariño',NULL,NULL,NULL,'INVIAS',1.42545608,-77.28445244),
('CARIMAGUA','CARIMAGUA','Córdoba',NULL,NULL,NULL,'INVIAS',8.60485611,-75.4848211),
('CASABLANCA','CASABLANCA','Cundinamarca',NULL,NULL,NULL,'INVIAS',5.10439419,-73.91282774),
('CASETABLA','CASETABLA','Meta','Puerto López','50573.0','IP - Malla vial del Meta','ANI',4.112715,-72.835014),
('CEDROS','CEDROS','Córdoba','Montería','23001.0','IP - Antioquia - Bolívar','ANI',8.819775,-75.998909),
('CENCAR','CENCAR','Valle del Cauca','Palmira','76520.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.557337,-76.462683),
('CERRITO','CERRITO','Valle del Cauca','Ginebra','76306.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.713022,-76.31918),
('CERRITOS II','CERRITOS II','Risaralda',NULL,NULL,NULL,'INVIAS',4.79340821,-75.85996286),
('CHAPARRAL','CHAPARRAL','Antioquia','Chigorodó','5172.0','Autopista al Mar 2','ANI',NULL,NULL),
('CHICORAL','CHICORAL','Tolima','Flandes','73275.0','IP Girardot - Cajamarca.','ANI',4.245502,-74.880531),
('CHINAUTA','CHINAUTA','Cundinamarca','Fusagasugá','25290.0','IP - Ampliación a tercer carril doble calzada Bogotá - Girardot','ANI',4.269378,-74.500107),
('CHUSACA','CHUSACA','Cundinamarca','Sibaté','25740.0','IP - Ampliación a tercer carril doble calzada Bogotá - Girardot','ANI',4.537452,-74.271805),
('CIAT','CIAT','Valle del Cauca','Palmira','76520.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.523449,-76.343279),
('CIRCASIA','CIRCASIA','Quindío','Filandia','63272.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',4.698388,-75.606148),
('CIRILO','CIRILO','Antioquia','Turbo','5837.0','Autopista al Mar 2','ANI',8.212907,-76.744636),
('CISNEROS','CISNEROS','Antioquia','Cisneros','5190.0','IP - Vías del Nus','ANI',6.53633,-75.074777),
('COCORA','COCORA','Tolima','Ibagué','73001.0','IP Girardot - Cajamarca.','ANI',4.405747,-75.2855),
('COCORNA','COCORNÁ','Antioquia',NULL,NULL,NULL,'INVIAS',6.1246071,-75.24303963),
('COROZAL','COROZAL','Valle del Cauca','Sevilla','76766.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',4.407929,-75.899872),
('CURITI','CURITÍ','Santander',NULL,NULL,NULL,'INVIAS',6.61769609,-73.08030867),
('EL BORDO','EL BORDO','Cauca',NULL,NULL,NULL,'INVIAS',2.18894946,-76.85116469),
('EL CARMEN','EL CARMEN','Bolívar','El Carmen de Bolívar','13244.0','Puerta de Hierro - Palmar de Varela y Carreto - Cruz del Viso','ANI',9.682155,-75.124916),
('EL COPEY','EL COPEY','Cesar','El Copey','20238.0','Ruta del Sol - Sector 3','ANI',10.060372,-73.923826),
('EL CORZO','EL CORZO','Cundinamarca',NULL,NULL,NULL,'INVIAS',4.74867879,-74.2911216),
('EL CRUCERO','EL CRUCERO','Boyacá',NULL,NULL,NULL,'INVIAS',5.63127851,-72.92125203),
('EL DIFICIL','EL DIFÍCIL','Magdalena','Nueva Granada','47460.0','Ruta del Sol - Sector 3','ANI',9.831166,-74.267754),
('EL EBANAL','EL EBANAL','La Guajira','Riohacha','44001.0','Santa Marta - Riohacha - Paraguachón','ANI',11.276194,-73.122124),
('EL KORAN','EL KORÁN','Cundinamarca',NULL,NULL,NULL,'INVIAS',5.4971317,-74.613481),
('EL PATA','EL PATÁ','Huila','Aipe','41016.0','IP Neiva - Espinal - Girardot.','ANI',3.393787,-75.203758),
('EL PICACHO','EL PICACHO','Santander',NULL,NULL,NULL,'INVIAS',7.107969,-72.968979),
('EL PLACER','EL PLACER','Nariño','Tangua','52788.0','Rumichaca - Pasto','ANI',1.064573,-77.428397),
('EL ROBLE','EL ROBLE','Cundinamarca','Sesquilé','25736.0','Briceño - Tunja - Sogamoso','ANI',5.031285,-73.839882),
('ESTAMBUL','ESTAMBUL','Valle del Cauca','Palmira','76520.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.500739,-76.443065),
('ETD 10 850','ETD 10+850','Nariño','Ipiales','52356.0','Rumichaca - Pasto','ANI',0.84743,-77.58593),
('FLANDES','FLANDES','Tolima','Espinal','73268.0','IP Neiva - Espinal - Girardot.','ANI',4.192099,-74.861153),
('FRAGUA','FRAGUA','Antioquia','Segovia','5736.0','APP - Conexión Norte.','ANI',7.277304,-74.832168),
('FUEMIA','FUEMIA','Antioquia','Dabeiba','5234.0','Autopista al Mar 2','ANI',6.952529,-76.242629),
('FUSCA','FUSCA','Cundinamarca','Chía','25175.0','IP - Accesos Norte a Bogotá','ANI',4.835358,-74.028931),
('GALAPA','GALAPA','Atlántico','Baranoa','8078.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','INVIAS',10.837533,-74.902122),
('GALAPA 02','GALAPA 02','Atlántico','Galapa','8296.0','Cartagena - Barranquilla y Circunvalar de la Prosperidad','ANI',10.886767,-74.844541),
('GAMBOTE','GAMBOTE','Bolívar','Arjona','13052.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','INVIAS',10.136159,-75.264267),
('GUAICO','GUAICO','Caldas','Risaralda','17616.0','Autopista Conexión Pacífico 3','ANI',5.105917,-75.760278),
('GUALANDAY','GUALANDAY','Tolima','Ibagué','73001.0','IP Girardot - Cajamarca.','ANI',4.300426,-75.050087),
('GUARNE','GUARNE','Antioquia','Copacabana','5212.0','Desarrollo Vial del Oriente de Medellín - DEVIMED','INVIAS',6.327955,-75.515533),
('GUATAQUI','GUATAQUÍ','Cundinamarca','Guataquí','25324.0','Honda - Puerto Salgar - Girardot','ANI',4.564435,-74.797319),
('HONDA','HONDA','Tolima','Honda','73349.0','APP IP - Cambao - Manizales.','ANI',5.201584,-74.820282),
('IRACA','IRACÁ','Meta','Granada','50313.0','IP - Malla vial del Meta','ANI',3.633037,-73.706421),
('IRRA','IRRA','Caldas','Neira','17486.0','Autopista Conexión Pacífico 3','ANI',5.257732,-75.657461),
('JUAN MINA','JUAN MINA','Atlántico','Galapa','8296.0','Cartagena - Barranquilla y Circunvalar de la Prosperidad','ANI',10.929328,-74.894495),
('LA APARTADA','LA APARTADA','Córdoba','La Apartada','23350.0','IP - Antioquia - Bolívar','ANI',8.031508,-75.30281),
('LA CABANA','LA CABAÑA','Cundinamarca','Guasca','25322.0','Perimetral de Oriente de Cundinamarca','ANI',4.809454,-73.945587),
('LA ESPERANZA','LA ESPERANZA','Sucre',NULL,NULL,NULL,'INVIAS',9.430742,-75.435951),
('LA GOMEZ','LA GÓMEZ','Santander','Sabana de Torres','68655.0','Troncal del Magdalena Sabana de Torres - Curumaní C2.','ANI',7.397176,-73.546519),
('LA LIBERTAD','LA LIBERTAD','Meta','Villavicencio','50001.0','IP - Malla vial del Meta','ANI',4.05697,-73.463287),
('LA LIZAMA','LA LIZAMA','Santander','Barrancabermeja','68081.0','Bucaramanga - Barrancabermeja - Yondó','ANI',7.083517,-73.717392),
('LA LOMA','LA LOMA','Cesar','El Paso','20250.0','Ruta del Sol - Sector 3','ANI',9.638003,-73.639435),
('LA PARADA','LA PARADA','Norte de Santander',NULL,NULL,NULL,'INVIAS',7.86745647,-72.48416464),
('LA PAZ','LA PAZ','Santander','La Paz','68397.0','Bucaramanga - Barrancabermeja - Yondó','ANI',9.644355,-73.890145),
('LA PINTADA','LA PINTADA','Antioquia','Jericó','5368.0','Autopista Conexión Pacífico 2','ANI',5.812156,-75.679156),
('LA RENTA','LA RENTA','Santander','Lebríja','68406.0','Bucaramanga - Barrancabermeja - Yondó','ANI',9.637044,-73.927495),
('LABERINTO','LABERINTO','Huila','Hobo','41349.0','Santana - Mocoa - Neiva','ANI',2.54056,-75.50417),
('LAS FLORES','LAS FLORES','Sucre',NULL,NULL,NULL,'INVIAS',9.318891,-75.320053),
('LAS PALMAS','LAS PALMAS','Antioquia','Retiro','5607.0','Desarrollo Vial del Oriente de Medellín - DEVIMED','INVIAS',6.15063,-75.531273),
('LEBRIJA','LEBRIJA','Santander',NULL,NULL,NULL,'INVIAS',7.10312712,7.10312712),
('LOBOGUERRERO','LOBOGUERRERO','Valle del Cauca','Dagua','76233.0','APP Nueva Malla vial del Valle del Cauca corredor: Buenaventura - Loboguerrero - Buga.','ANI',3.763004,-76.665594),
('LOS ACACIOS','LOS ACACIOS','Norte de Santander','Los Patios','54405.0','Pamplona - Cúcuta','ANI',7.721372,-72.57132),
('LOS CAUCHOS','LOS CAUCHOS','Huila','Rivera','41615.0','Santana - Mocoa - Neiva','ANI',2.785578,-75.301956),
('LOS CUROS','LOS CUROS','Santander',NULL,NULL,NULL,'INVIAS',6.82563437,-72.99948187),
('LOS GARZONES I','LOS GARZONES I','Córdoba',NULL,NULL,NULL,'INVIAS',NULL,NULL),
('LOS GARZONES II','LOS GARZONES II','Córdoba',NULL,NULL,NULL,'INVIAS',NULL,NULL),
('LOS LLANOS','LOS LLANOS','Antioquia',NULL,NULL,NULL,'INVIAS',6.83050248,-75.4681404),
('LOS PATIOS','LOS PATIOS','Bogotá, D.C.','Bogotá, D.C.','11001.0','Perimetral de Oriente de Cundinamarca','ANI',4.663374,-74.01058),
('MACHETA','MACHETÁ','Cundinamarca','Macheta','25426.0','Transversal del Sisga','ANI',5.077249,-73.553398),
('MANGUITOS','MANGUITOS','Córdoba','Planeta Rica','23555.0','IP - Antioquia - Bolívar','ANI',8.301572,-75.530099),
('MARAHUACO','MARAHUACO','Bolívar','Cartagena','13001.0','Cartagena - Barranquilla y Circunvalar de la Prosperidad','ANI',10.574535,-75.450559),
('MATA DE CANA','MATA DE CAÑA','Córdoba','Lorica','23417.0','IP - Antioquia - Bolívar','ANI',9.091459,-75.819862),
('MEDIACANOA','MEDIACANOA','Valle del Cauca','Yotoco','76890.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.759912,-76.411322),
('MORRISON','MORRISON','Cesar','Río de Oro','20614.0','Troncal del Magdalena Sabana de Torres - Curumaní C2.','ANI',8.092349,-73.560015),
('MUTATA','MUTATÁ','Antioquia','Mutatá','5480.0','Autopista al Mar 2','ANI',7.228179,-76.433743),
('NARANJAL','NARANJAL','Cundinamarca','Quetame','25594.0','IP - Chirajara - Fundadores','ANI',4.279872,-73.834808),
('NEGUANJE','NEGUANJE','Magdalena','Santa Marta','47001.0','Santa Marta - Riohacha - Paraguachón','ANI',11.253063,-74.109322),
('NEIVA','NEIVA','Huila','Neiva','41001.0','IP Neiva - Espinal - Girardot.','ANI',2.977802,-75.307259),
('OCOA','OCOA','Meta','Acacías','50006.0','IP - Malla vial del Meta','ANI',4.026259,-73.775192),
('OIBA','OIBA','Santander',NULL,NULL,NULL,'INVIAS',6.17823642,-73.33328957),
('PAILITAS','PAILITAS','Cesar','Pailitas','20517.0','Troncal del Magdalena Sabana de Torres - Curumaní C2.','ANI',8.852804,-73.669722),
('PAMPLONITA','PAMPLONITA','Norte de Santander','Pamplonita','54520.0','Pamplona - Cúcuta','ANI',7.421408,-72.619137),
('PANDEQUESO','PANDEQUESO','Antioquia','Don Matías','5237.0','IP - Vías del Nus','ANI',6.477998,-75.37861),
('PAPIROS','PAPIROS','Atlántico','Puerto Colombia','8573.0','Cartagena - Barranquilla y Circunvalar de la Prosperidad','ANI',11.0127,-74.889588),
('PARAGUACHON','PARAGUACHÓN','La Guajira','Maicao','44430.0','Santa Marta - Riohacha - Paraguachón','ANI',11.367614,-72.156624),
('PASACABALLOS','PASACABALLOS','Bolívar','Turbaná','13838.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','INVIAS',10.244507,-75.445772),
('PASO LA TORRE','PASO LA TORRE','Valle del Cauca','Yumbo','76892.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.627602,-76.457651),
('PAVAS','PAVAS','Caldas','Manizales','17001.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',5.027062,-75.587418),
('PIPIRAL','PIPIRAL','Meta','Villavicencio','50001.0','IP - Chirajara - Fundadores','ANI',4.200048,-73.72142),
('PLATANAL','PLATANAL','Cesar',NULL,NULL,NULL,'INVIAS',8.23123833,-73.49857234),
('PRIMAVERA','PRIMAVERA','Antioquia','Santa Bárbara','5679.0','Autopista Conexión Pacífico 2','ANI',5.968797,-75.594025),
('PUENTE AMARILLO','PUENTE AMARILLO','Meta','Villavicencio','50001.0','Villavicencio - Yopal','ANI',4.194172,-73.596703),
('PUENTE PLATO','PUENTE PLATO','Magdalena','Plato','47555.0','Ruta del Sol - Sector 3','ANI',9.791388,-74.808983),
('PUERTO BERRIO','PUERTO BERRÍO','Antioquia','Puerto Berrío','5579.0','APP Autopista al Río Magdalena 2.','ANI',6.496662,-74.501381),
('PUERTO COLOMBIA','PUERTO COLOMBIA','Atlántico','Tubará','8832.0','Cartagena - Barranquilla y Circunvalar de la Prosperidad','ANI',10.967563,-74.956105),
('PUERTO TRIUNFO','PUERTO TRIUNFO','Antioquia',NULL,NULL,NULL,'INVIAS',5.87259891,-74.61139541),
('PURGATORIO','PURGATORIO','Córdoba','Montería','23001.0','IP - Antioquia - Bolívar','ANI',8.630711,-75.763725),
('RANCHO CAMACHO','RANCHO CAMACHO','Santander','Barrancabermeja','68081.0','Bucaramanga - Barrancabermeja - Yondó','ANI',1.252067,-74.169626),
('RINCON HONDO','RINCÓN HONDO','Cesar',NULL,NULL,NULL,'INVIAS',9.431032,-73.47355215),
('RIO BLANCO','RÍO BLANCO','Santander',NULL,NULL,NULL,'INVIAS',7.55433129,-73.23110812),
('RIO BOGOTA','RÍO BOGOTÁ','Cundinamarca',NULL,NULL,NULL,'INVIAS',4.6987,-74.179344),
('RIO FRIO','RÍO FRÍO','Valle del Cauca',NULL,NULL,NULL,'INVIAS',3.99550925,-76.3284967),
('RIO GRANDE','RIO GRANDE','Antioquia','Turbo','5837.0','Autopista al Mar 2','ANI',NULL,NULL),
('RIONEGRO','RIONEGRO','Santander',NULL,NULL,NULL,'INVIAS',7.24326753,7.24326753),
('ROZO','ROZO','Valle del Cauca','Palmira','76520.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.643896,-76.381091),
('SABANAGRANDE','SABANAGRANDE','Atlántico','Sabanagrande','8634.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','INVIAS',10.799603,-74.759003),
('SABOYA','SABOYÁ','Boyacá',NULL,NULL,NULL,'INVIAS',5.7278648,-73.74466588),
('SACHICA','SÁCHICA','Boyacá',NULL,NULL,NULL,'INVIAS',5.55768488,-73.50115778),
('SAN BERNARDO','SAN BERNARDO','Caldas','Manizales','17001.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',5.0522,-75.594574),
('SAN CARLOS','SAN CARLOS','Córdoba','San Carlos','23678.0','IP - Antioquia - Bolívar','ANI',8.709985,-75.716599),
('SAN CLEMENTE','SAN CLEMENTE','Caldas',NULL,NULL,NULL,'INVIAS',5.33243849,-75.77560328),
('SAN DIEGO','SAN DIEGO','Cesar',NULL,NULL,NULL,'INVIAS',10.12172583,-73.23863778),
('SAN JUAN','SAN JUAN','Guajira',NULL,NULL,NULL,'INVIAS',10.80001593,-72.97554033),
('SAN LUIS DE GACENO','SAN LUIS DE GACENO','Boyacá','San Luis de Gaceno','15667.0','Transversal del Sisga','ANI',4.82556,-73.083497),
('SAN ONOFRE','SAN ONOFRE','Sucre','San Onofre','70713.0','IP - Antioquia - Bolívar','ANI',9.872531,-75.393358),
('SAN PEDRO','SAN PEDRO','Casanare','Villanueva','85440.0','Villavicencio - Yopal','ANI',4.678609,-72.943748),
('SANTA ISABEL','SANTA ISABEL','Antioquia','Remedios','5604.0','APP Autopista al Río Magdalena 2.','ANI',8.303892,-74.107679),
('SANTAGUEDA','SANTÁGUEDA','Caldas','Manizales','17001.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',5.048662,-75.598846),
('SIBERIA','SIBERIA','Cundinamarca','Tenjo','25799.0','Santafé de Bogotá (Puente el Cortijo)  - Siberia - La Punta - El Vino - La Vega - Villeta','ANI',4.780402,-74.185028),
('SOPO','SOPÓ','Cundinamarca','Sopó','25758.0','Perimetral de Oriente de Cundinamarca','ANI',4.841656,-73.936084),
('SUPIA','SUPIA','Antioquia','Caramanta','5145.0','Autopista Conexión Pacífico 3','ANI',5.540526,-75.570252),
('T LA LINEA QUINDIO','T. LA LÍNEA QUINDÍO','Quindío',NULL,NULL,NULL,'INVIAS',NULL,NULL),
('T LA LINEA TOLIMA','T. LA LÍNEA TOLIMA','Tolima',NULL,NULL,NULL,'INVIAS',NULL,NULL),
('TARAPACA I','TARAPACÁ I','Caldas','Chinchiná','17174.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',4.939546,-75.616445),
('TARAPACA II','TARAPACÁ II','Risaralda','Santa Rosa de Cabal','66682.0','Desarrollo Vial Armenia - Pereira - Manizales.','ANI',4.950099,-75.618682),
('TARAZA','TARAZÁ','Antioquia',NULL,NULL,NULL,'INVIAS',7.58918891,-75.39364303),
('TORO','TORO','Valle del Cauca',NULL,NULL,NULL,'INVIAS',4.66542498,-76.04953245),
('TRAPICHE','TRAPICHE','Antioquia','Girardota','5308.0','IP - Vías del Nus','ANI',6.399637,-75.433016),
('TUCURINCA','TUCURINCA','Magdalena','Aracataca','47053.0','Ruta del Sol - Sector 3','ANI',10.608983,-74.168495),
('TURBACO','TURBACO','Bolívar','Turbaco','13836.0','IP Autopistas del Caribe, corredor de carga Cartagena - Barranquilla','INVIAS',10.357028,-75.443443),
('TUTA','TUTA','Boyacá','Cómbita','15204.0','Briceño - Tunja - Sogamoso','ANI',5.656912,-73.278435),
('UNISABANA','UNISABANA','Cundinamarca','Chía','25175.0','IP - Accesos Norte a Bogotá','ANI',4.855403,-74.031464),
('VALENCIA','VALENCIA','Cesar','Valledupar','20001.0','Ruta del Sol - Sector 3','ANI',10.259704,-73.430756),
('VEGACHI','VEGACHÍ','Antioquia','Yolombó','5890.0','APP Autopista al Río Magdalena 2.','ANI',8.272597,-74.434389),
('VERACRUZ','VERACRUZ','Meta','Cumaral','50226.0','Villavicencio - Yopal','ANI',4.261088,-73.448189),
('VILLA RICA','VILLA RICA','Cauca','Villa Rica','19845.0','Nueva Malla Vial del Valle Accesos Cali y Palmira.','ANI',3.151276,-76.460045),
('YUCAO','YUCAO','Meta','Puerto López','50573.0','IP - Malla vial del Meta','ANI',4.351317,-72.169253),
('ZAMBITO','ZAMBITO','Santander','Cimitarra','68190.0','Troncal del Magdalena Puerto Salgar - Barrancabermeja C1.','ANI',6.294714,-74.456992),
('ZARAGOZA','ZARAGOZA','Antioquia','Zaragoza','5895.0','APP - Conexión Norte.','ANI',7.633288,-74.894704)
ON DUPLICATE KEY UPDATE
    name=VALUES(name),
    department=VALUES(department),
    municipality=VALUES(municipality),
    divipola=VALUES(divipola),
    project=VALUES(project),
    current_administrator=VALUES(current_administrator),
    latitude=VALUES(latitude),
    longitude=VALUES(longitude),
    active=1;

COMMIT;

START TRANSACTION;

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',27300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',31700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',31700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',71500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',91600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',108200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ABURRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ACAPULCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AGUAS NEGRAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',20500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AGUAS NEGRAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',47600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AGUAS NEGRAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AGUAS NEGRAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',67200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AGUAS NEGRAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALBARRACIN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALBARRACIN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALBARRACIN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALBARRACIN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALBARRACIN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTAMIRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTAMIRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTAMIRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTAMIRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTAMIRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',86200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALTO PINO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',40500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',55400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',60000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ALVARADO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',24400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',24400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',70000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',80500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='AMAGA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16100,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',26400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',27800,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18700,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38100,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',54500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55500,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',69900,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',75900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',76900,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='ANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='ARCABUCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='ARCABUCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='ARCABUCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='ARCABUCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='ARCABUCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',40600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',55400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',76600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARMERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARROYO DE PIEDRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARROYO DE PIEDRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',37400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARROYO DE PIEDRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARROYO DE PIEDRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',74700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ARROYO DE PIEDRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BAYUNCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BAYUNCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BAYUNCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',41200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BAYUNCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BAYUNCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='BICENTENARIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='BICENTENARIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',41600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='BICENTENARIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',50400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='BICENTENARIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',58500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='BICENTENARIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',61400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',81000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',91500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',101600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',121800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',61400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',81000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',91500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',101600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',121800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BOQUERON II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',7700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',33800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',45100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',103400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',118200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='BRISAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',23800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',34500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',59800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',75000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',86500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CABILDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAIQUERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAIQUERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',45500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAIQUERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',54800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAIQUERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',62900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAIQUERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CALAMAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CALAMAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CALAMAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CALAMAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',58100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CALAMAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',90100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',102900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CAMBAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CANO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CANO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',33900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CANO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',44600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CANO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CANO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CARIMAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',26600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CARIMAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',26600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CARIMAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',48200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CARIMAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',76500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CARIMAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CASABLANCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CASABLANCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CASABLANCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CASABLANCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CASABLANCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',8300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',8800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',9900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',9900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',45300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',51200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CASETABLA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',52500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',83400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',96000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CEDROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CENCAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CENCAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CENCAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CENCAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CENCAR'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CERRITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CERRITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CERRITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CERRITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CERRITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CERRITOS II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CERRITOS II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',52100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CERRITOS II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',68100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CERRITOS II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',78000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CERRITOS II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',30400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',39100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',43900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHAPARRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',16600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',58000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHICORAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHINAUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHINAUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',38000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHINAUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',61700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHINAUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',70700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHINAUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHUSACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHUSACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',38000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHUSACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',61700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHUSACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',70700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CHUSACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIAT'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIAT'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',43200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIAT'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIAT'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIAT'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',21200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',27000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',27000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',27000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',65500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',80400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',89400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRCASIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',30400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',39100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',43900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CIRILO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',29400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',35600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',35600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',85200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',107600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',123700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='CISNEROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COCORA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COCORA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',43300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COCORA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COCORA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',63800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COCORA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='COCORNA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='COCORNA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='COCORNA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',31800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='COCORNA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',63700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='COCORNA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',90600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='COCORNA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',58900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',68100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='COROZAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CURITI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CURITI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CURITI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CURITI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='CURITI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL BORDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL BORDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL BORDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL BORDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL BORDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL CARMEN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL CARMEN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL CARMEN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL CARMEN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL CARMEN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL COPEY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL COPEY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL COPEY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',40700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL COPEY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL COPEY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',16200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',48800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',52800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CORZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CRUCERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CRUCERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CRUCERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CRUCERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL CRUCERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL DIFICIL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL DIFICIL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',36800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL DIFICIL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',52200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL DIFICIL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL DIFICIL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',86200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL EBANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',27700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',39000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',81100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',100700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',119400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL KORAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',28900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',36600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',70000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',81000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL PICACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL PICACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL PICACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL PICACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='EL PICACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PLACER'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PLACER'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',49000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PLACER'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',58600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PLACER'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',67600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL PLACER'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL ROBLE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL ROBLE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL ROBLE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL ROBLE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='EL ROBLE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ESTAMBUL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ESTAMBUL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',43200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ESTAMBUL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ESTAMBUL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ESTAMBUL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',0,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ETD 10 850'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',0,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ETD 10 850'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',0,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ETD 10 850'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',0,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ETD 10 850'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',0,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ETD 10 850'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',28900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',36600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',70000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',81000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FLANDES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FRAGUA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',25300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',31400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',31400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',74100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',93000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',107500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUEMIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16100,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',26400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',27800,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18700,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38100,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',54500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55500,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',69900,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',75900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',76900,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='FUSCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',44500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',10000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',10800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',18600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',57500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',76300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',84800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GALAPA 02'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GAMBOTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GAMBOTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GAMBOTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',41200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GAMBOTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GAMBOTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',25300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',31500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',31500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',74100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',93500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',107600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUAICO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUALANDAY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUALANDAY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUALANDAY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUALANDAY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',62500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUALANDAY'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',32000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',32000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',63400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',90400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',90400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUARNE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',90100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',102900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='GUATAQUI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',40500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',55400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',60000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='HONDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',30500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',23100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',59000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',77900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',84700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRACA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='IRRA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',10000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',10800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',18600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',57500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',76300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',84800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='JUAN MINA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',52500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',83400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',96000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA APARTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA CABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA CABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA CABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',52300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA CABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',71700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA CABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',72100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA CABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',11500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA ESPERANZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA ESPERANZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',26600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA ESPERANZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',33400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA ESPERANZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA ESPERANZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA GOMEZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',20500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA GOMEZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',47600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA GOMEZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA GOMEZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',67200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA GOMEZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',39500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',52000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',76900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',100900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',115700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIBERTAD'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',58900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',73500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',84900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LIZAMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LOMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LOMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LOMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LOMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA LOMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',2800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA PARADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',2800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA PARADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',2800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA PARADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',2800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA PARADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',2800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LA PARADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',23900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',28600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',28600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',28600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',66600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',83800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',96300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LA PINTADA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',24300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',38100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',53400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',60700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LABERINTO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',6400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LAS FLORES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LAS FLORES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LAS FLORES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',32200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LAS FLORES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LAS FLORES'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',35700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',47900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',53700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LAS PALMAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',11500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LEBRIJA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LEBRIJA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LEBRIJA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',40900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LEBRIJA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LEBRIJA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOBOGUERRERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOBOGUERRERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',33100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOBOGUERRERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOBOGUERRERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',49100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOBOGUERRERO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',9500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',29700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',38400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS ACACIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS CAUCHOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS CAUCHOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS CAUCHOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS CAUCHOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS CAUCHOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS CUROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS CUROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS CUROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS CUROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS CUROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',8500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',32200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',8500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',32200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS GARZONES II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS LLANOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS LLANOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS LLANOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS LLANOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='LOS LLANOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS PATIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS PATIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS PATIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',52300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS PATIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',71700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS PATIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',72100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='LOS PATIOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',24500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',76800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',89000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MACHETA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',52500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',83400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',96000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MANGUITOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',22200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',33300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',24400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',42200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',131700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',175900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',195200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MARAHUACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',28500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',28500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',28500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',30300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',44300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',44400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MATA DE CANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MEDIACANOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MEDIACANOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MEDIACANOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MEDIACANOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MEDIACANOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MORRISON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MORRISON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',32900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MORRISON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',42000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MORRISON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MORRISON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='MUTATA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',46100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',34800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',68300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',79400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',91500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',101600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NARANJAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',86200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEGUANJE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',28900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',36600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',70000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',81000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='NEIVA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',30500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',23100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',59000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',77900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',84700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='OCOA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='OIBA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='OIBA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='OIBA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='OIBA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='OIBA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAILITAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAILITAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',32900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAILITAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',42000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAILITAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAILITAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',27100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',32200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',45800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',81500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',94400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAMPLONITA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',60300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PANDEQUESO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',11100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAPIROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAPIROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',60900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAPIROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',81500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAPIROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',90500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAPIROS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',86200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PARAGUACHON'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',44100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',44100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',44100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASACABALLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASO LA TORRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASO LA TORRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASO LA TORRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASO LA TORRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PASO LA TORRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',58900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',68100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PAVAS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',57000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',39100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',68300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',74300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',113800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',147000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PIPIRAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PLATANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PLATANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PLATANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',36600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PLATANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PLATANAL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PRIMAVERA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PRIMAVERA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PRIMAVERA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PRIMAVERA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PRIMAVERA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',5800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',19200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',12300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',27200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',36300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',41100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE AMARILLO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE PLATO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE PLATO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',36800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE PLATO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',52200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE PLATO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUENTE PLATO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',38700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',48700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',55600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO BERRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',31200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',22700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',39600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',123200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',164000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',182200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PUERTO COLOMBIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',18800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PUERTO TRIUNFO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PUERTO TRIUNFO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',25600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PUERTO TRIUNFO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',31800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PUERTO TRIUNFO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',63700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PUERTO TRIUNFO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',90600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='PUERTO TRIUNFO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',52500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',83400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',96000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='PURGATORIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19074,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23374,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29074,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',36774,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55974,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',69874,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',80774,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RANCHO CAMACHO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',15600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',16800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',17800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',19100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',54500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',62500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RINCON HONDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BLANCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BLANCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BLANCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BLANCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BLANCO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',18500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',16200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',48800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',52800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO BOGOTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO FRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO FRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO FRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO FRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIO FRIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',14900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',30400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',39100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',43900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='RIO GRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',11500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIONEGRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIONEGRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIONEGRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',40900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIONEGRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='RIONEGRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ROZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ROZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ROZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ROZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ROZO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SABANAGRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SABANAGRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',31500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SABANAGRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',41200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SABANAGRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SABANAGRANDE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SABOYA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SABOYA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SABOYA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SABOYA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51100,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SABOYA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SACHICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SACHICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SACHICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SACHICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SACHICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',58900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',68100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN BERNARDO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',28500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',28500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',28500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',30300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',44300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',44400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN CARLOS'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN CLEMENTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN CLEMENTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN CLEMENTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN CLEMENTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN CLEMENTE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',7400,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',8000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',8600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',9200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',19000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',54500,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',61900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN DIEGO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN JUAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN JUAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',30000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN JUAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN JUAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',43000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='SAN JUAN'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',76600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN LUIS DE GACENO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',89000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN LUIS DE GACENO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',19700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',29100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',52500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',83400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',96000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN ONOFRE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',24900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',32400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',40900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',62700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',78400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',90900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SAN PEDRO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTA ISABEL'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',19300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',47100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',58900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',68100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SANTAGUEDA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',15300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',18300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',24400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',57000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',62700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SIBERIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',14800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SOPO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SOPO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',38800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SOPO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SOPO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',78000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SOPO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',78800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SOPO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='SUPIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA QUINDIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA QUINDIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA QUINDIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA QUINDIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA QUINDIO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA TOLIMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA TOLIMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA TOLIMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA TOLIMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='T LA LINEA TOLIMA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',23500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',23500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',58000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',76900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',85900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA I'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',23500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',23500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',23500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',58000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',76900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',85900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TARAPACA II'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13000,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TARAZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14600,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TARAZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TARAZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TARAZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',42900,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TARAZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TORO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TORO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29300,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TORO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',37200,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TORO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',41800,'2026-01-16',
NULL,'INVIAS - Resolución 0062 del 15-ene-2026','INVIAS'
FROM toll
WHERE toll_key='TORO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',20300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',22400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',23800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',34500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',59800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',75000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',86500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TRAPICHE'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUCURINCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',14300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUCURINCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',33500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUCURINCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUCURINCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',50900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUCURINCA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',5800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TURBACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',12900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TURBACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',15900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TURBACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',15900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TURBACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',15900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TURBACO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',35400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='TUTA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',54500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='UNISABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',55500,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='UNISABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',68900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='UNISABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',69900,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='UNISABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',75900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='UNISABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',76900,'2026-07-01',
NULL,'ANI - Resolución 20253040016965 / actualización 01-jul-2026','ANI'
FROM toll
WHERE toll_key='UNISABANA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',12500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VALENCIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',13700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VALENCIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',29700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VALENCIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',38400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VALENCIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',43700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VALENCIA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VEGACHI'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',10400,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',20700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',13300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',20700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',29600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',39800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',44600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VERACRUZ'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',13200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VILLA RICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',16100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VILLA RICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',42600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VILLA RICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',55500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VILLA RICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',64000,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='VILLA RICA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',8300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',8800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',9900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',9900,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',36700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',45300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',51200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='YUCAO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',16300,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZAMBITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',20500,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZAMBITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',47600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZAMBITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',57100,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZAMBITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',67200,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZAMBITO'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'I',17600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'II',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'III',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'IV',21800,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'V',51600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VI',64700,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

INSERT INTO toll_rate
(toll_id,category,rate,start_date,end_date,source,source_entity)
SELECT id,'VII',74600,'2026-06-01',
'2026-06-30','ANI-OETR (corte junio 2026)','ANI'
FROM toll
WHERE toll_key='ZARAGOZA'
ON DUPLICATE KEY UPDATE
    rate=VALUES(rate),
    end_date=VALUES(end_date),
    source=VALUES(source),
    source_entity=VALUES(source_entity);

COMMIT;

-- ============================================================
-- VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_tolls FROM toll;

SELECT COUNT(*) AS tolls_with_coordinates
FROM toll
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

SELECT COUNT(*) AS tolls_without_coordinates
FROM toll
WHERE latitude IS NULL OR longitude IS NULL;

SELECT COUNT(*) AS total_rates FROM toll_rate;

-- ============================================================
-- END
-- ============================================================
