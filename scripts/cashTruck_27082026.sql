-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: 168.231.93.145    Database: cashTruck
-- ------------------------------------------------------
-- Server version	5.5.5-10.11.11-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit`
--

DROP TABLE IF EXISTS `audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `error_type` text DEFAULT NULL,
  `message_id` char(36) DEFAULT NULL,
  `message_type` varchar(50) DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit`
--

LOCK TABLES `audit` WRITE;
/*!40000 ALTER TABLE `audit` DISABLE KEYS */;
INSERT INTO `audit` VALUES (1,'Sent','Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 693567  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'1',NULL,'2026-08-26 22:36:58'),(2,'Sent','Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 635528  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'2',NULL,'2026-08-26 22:49:30'),(3,'Sent','Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 982457  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'3',NULL,'2026-08-26 23:04:16'),(4,'Sent','Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 946047  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'4',NULL,'2026-08-26 23:20:54'),(5,'Sent','Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 384381  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'5',NULL,'2026-08-26 23:22:32'),(6,'Sent','ðŸš€ Â¡Bienvenido a CashTruck! ðŸš›ðŸ’¨\n\nHola Nuevo Owner, ya puedes gestionar tus vehÃ­culos y controlar tus costos.\n\nðŸ”— App: https://truck.ccsoluciones.com.co\nðŸ“§ Usuario: new@gmail.com\nðŸ”‘ ContraseÃ±a: 12345678\n\n*Primeros pasos:*\n1ï¸âƒ£ Crea tus conductores ðŸ‘¤\n2ï¸âƒ£ Registra tus vehÃ­culos ðŸš›\n3ï¸âƒ£ Crea viajes asignando conductor y vehÃ­culo ðŸ—ºï¸\n4ï¸âƒ£ Anota los gastos de cada viaje ðŸ’¸\n5ï¸âƒ£ Registra los mantenimientos ðŸ› ï¸\n6ï¸âƒ£ Consulta tus rutas en el mapa ðŸ“\n7ï¸âƒ£ Revisa tus reportes ðŸ“Š\n\nÂ¿Dudas? EscrÃ­benos por este medio ðŸ“²',NULL,'6',NULL,'2026-08-27 00:39:36'),(7,'Sent','ðŸš€ Â¡Bienvenido a CashTruck! ðŸš›ðŸ’¨\n\nHola newTest, ya puedes gestionar tus vehÃ­culos y controlar tus costos.\n\nðŸ”— App: https://truck.ccsoluciones.com.co\nðŸ“§ Usuario: new2@gmail.com\nðŸ”‘ ContraseÃ±a: 12345678\n\n*Primeros pasos:*\n1ï¸âƒ£ Registra tus vehÃ­culos ðŸš›\n2ï¸âƒ£ Crea viajes asignando tu vehÃ­culo ðŸ—ºï¸\n3ï¸âƒ£ Anota los gastos de cada viaje ðŸ’¸\n4ï¸âƒ£ Registra los mantenimientos ðŸ› ï¸\n5ï¸âƒ£ Consulta tus rutas en el mapa ðŸ“\n6ï¸âƒ£ Revisa tus reportes ðŸ“Š\n\nÂ¿Dudas? EscrÃ­benos por este medio ðŸ“²',NULL,'7',NULL,'2026-08-27 00:46:21');
/*!40000 ALTER TABLE `audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `city`
--

DROP TABLE IF EXISTS `city`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `city` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `state` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `city`
--

LOCK TABLES `city` WRITE;
/*!40000 ALTER TABLE `city` DISABLE KEYS */;
INSERT INTO `city` VALUES (1,'Bogotá D.C.','Cundinamarca'),(2,'Medellín','Antioquia'),(3,'Cali','Valle del Cauca'),(4,'Barranquilla','Atlántico'),(5,'Cartagena','Bolívar'),(6,'Bucaramanga','Santander'),(7,'Manizales','Caldas'),(8,'Pereira','Risaralda'),(9,'Cúcuta','Norte de Santander'),(10,'Ibagué','Tolima'),(11,'Santa Marta','Magdalena'),(12,'Villavicencio','Meta'),(13,'Montería','Córdoba'),(14,'Valledupar','Cesar'),(15,'Popayán','Cauca'),(16,'Neiva','Huila'),(17,'Armenia','Quindío'),(18,'Tunja','Boyacá'),(19,'Sincelejo','Sucre'),(20,'Riohacha','La Guajira'),(21,'Florencia','Caquetá'),(22,'Yopal','Casanare'),(23,'Quibdó','Chocó'),(24,'Buenaventura','Valle del Cauca'),(25,'Barrancabermeja','Santander'),(26,'Ipiales','Nariño'),(27,'Tumaco','Nariño'),(28,'Duitama','Boyacá'),(29,'Sogamoso','Boyacá'),(30,'Girardot','Cundinamarca'),(31,'La Dorada','Caldas'),(32,'Cumbal','Nariño'),(33,'Túquerres','Nariño'),(34,'Guachucal','Nariño'),(35,'La Unión','Nariño'),(36,'Samaniego','Nariño'),(37,'Santander de Quilichao','Cauca'),(38,'Puerto Tejada','Cauca'),(39,'Mocoa','Putumayo'),(40,'Puerto Asís','Putumayo'),(41,'Orito','Putumayo'),(42,'Buga','Valle del Cauca'),(43,'Palmira','Valle del Cauca'),(44,'Tuluá','Valle del Cauca'),(45,'Jamundí','Valle del Cauca'),(46,'Cartago','Valle del Cauca'),(47,'Dosquebradas','Risaralda'),(48,'Calarcá','Quindío'),(49,'Soacha','Cundinamarca'),(50,'Mosquera','Cundinamarca'),(51,'Funza','Cundinamarca'),(52,'Facatativá','Cundinamarca'),(53,'Zipaquirá','Cundinamarca'),(54,'Tocancipá','Cundinamarca'),(55,'Fusagasugá','Cundinamarca'),(56,'Melgar','Tolima'),(57,'Espinal','Tolima'),(58,'Pitalito','Huila'),(59,'Garzón','Huila'),(60,'Rionegro','Antioquia'),(61,'Apartadó','Antioquia'),(62,'Turbo','Antioquia'),(63,'Caucasia','Antioquia'),(64,'Bello','Antioquia'),(65,'Itagüí','Antioquia'),(66,'Envigado','Antioquia'),(67,'Barrancabermeja','Santander'),(68,'San Gil','Santander'),(69,'Ocaña','Norte de Santander'),(70,'Pamplona','Norte de Santander'),(71,'Aguachica','Cesar'),(72,'Bosconia','Cesar'),(73,'Maicao','La Guajira'),(74,'Soledad','Atlántico'),(75,'Malambo','Atlántico'),(76,'Magangué','Bolívar'),(77,'Lorica','Córdoba'),(78,'Acacías','Meta'),(79,'Granada','Meta'),(80,'Arauca','Arauca'),(81,'Saravena','Arauca'),(82,'Pasto','Nariño'),(83,'Tulcán','Ecuador');
/*!40000 ALTER TABLE `city` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_type`
--

DROP TABLE IF EXISTS `document_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_type`
--

LOCK TABLES `document_type` WRITE;
/*!40000 ALTER TABLE `document_type` DISABLE KEYS */;
INSERT INTO `document_type` VALUES (1,'Cédula de Ciudadanía');
/*!40000 ALTER TABLE `document_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver`
--

DROP TABLE IF EXISTS `driver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `photo` varchar(120) DEFAULT NULL,
  `document_type_id` int(11) NOT NULL,
  `document_number` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `email` varchar(100) NOT NULL,
  `cell_phone` varchar(20) NOT NULL,
  `city_id` int(11) DEFAULT NULL,
  `gender_id` int(11) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `age` int(11) GENERATED ALWAYS AS (timestampdiff(YEAR,`birthdate`,curdate())) VIRTUAL,
  `salary_type_id` int(11) DEFAULT NULL,
  `salary` int(11) DEFAULT NULL,
  `license_category` varchar(5) NOT NULL,
  `license_number` varchar(50) NOT NULL,
  `license_expiry` date NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `owner_id` bigint(20) NOT NULL,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `document_number` (`document_number`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `document_type_id` (`document_type_id`),
  KEY `city_id` (`city_id`),
  KEY `gender_id` (`gender_id`),
  KEY `owner_id` (`owner_id`),
  KEY `salary_type_id` (`salary_type_id`),
  CONSTRAINT `driver_ibfk_1` FOREIGN KEY (`document_type_id`) REFERENCES `document_type` (`id`),
  CONSTRAINT `driver_ibfk_2` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`),
  CONSTRAINT `driver_ibfk_3` FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`),
  CONSTRAINT `driver_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `driver_ibfk_5` FOREIGN KEY (`owner_id`) REFERENCES `owner` (`id`),
  CONSTRAINT `driver_ibfk_6` FOREIGN KEY (`salary_type_id`) REFERENCES `salary_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4009 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver`
--

LOCK TABLES `driver` WRITE;
/*!40000 ALTER TABLE `driver` DISABLE KEYS */;
INSERT INTO `driver` (`id`, `photo`, `document_type_id`, `document_number`, `name`, `email`, `cell_phone`, `city_id`, `gender_id`, `birthdate`, `salary_type_id`, `salary`, `license_category`, `license_number`, `license_expiry`, `user_id`, `owner_id`, `creation_date`, `update_date`) VALUES (4001,'https://truck.ccsoluciones.com.co/truck/images/driver/photo4001.webp',1,'1088552542','Juan Perez ','juan@gmail.com','3100582500',82,1,'2007-07-08',2,50,'c2','1088552542','2026-06-23',6002,2001,'2026-04-16 05:07:24','2026-08-27 03:42:09'),(4002,'',1,'1088596141','DIEGO HERNANDEZ','diefdoheim@gmail.com','3177626969',32,1,'1995-06-09',1,1400000,'c3','1088596141','2027-10-20',NULL,2002,'2026-08-09 23:43:10','2026-08-27 03:42:09'),(4004,'https://truck.ccsoluciones.com.co/truck/images/driver/photo4004.webp',1,'1234567','Conductor 1','cond1@gmail.com','3234234234',74,1,'2008-08-14',1,1400000,'c3','1234567','2027-07-13',6006,2004,'2026-08-16 20:57:23','2026-08-27 03:42:10'),(4005,'',1,'123412345','Conductor 2','cond2@gmail.com','3523454544',76,1,'2008-08-15',2,25,'c2','123412345','2026-11-10',6007,2004,'2026-08-16 20:58:16','2026-08-27 03:42:10'),(4006,'',1,'23334544','Conductor 3','cond3@gmail.com','3564564565',53,1,'2008-08-14',2,16,'c2','23334544','2026-11-24',6008,2004,'2026-08-16 21:06:30','2026-08-27 03:42:11'),(4007,'',1,'5261667','José Burbano ','joseburbano123@gmail.com','3147796380',32,1,'1963-04-14',1,1400000,'c3','5261667','2027-08-18',NULL,2002,'2026-08-19 23:09:06','2026-08-27 03:42:11');
/*!40000 ALTER TABLE `driver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver_locations`
--

DROP TABLE IF EXISTS `driver_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_locations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `driver_id` bigint(20) NOT NULL,
  `vehicle_id` bigint(20) NOT NULL,
  `trip_id` bigint(20) DEFAULT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `speed_kmh` decimal(5,2) DEFAULT 0.00,
  `address_text` text DEFAULT NULL,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_loc_driver` (`driver_id`),
  KEY `fk_loc_trip` (`trip_id`),
  KEY `idx_history` (`vehicle_id`,`creation_date`),
  CONSTRAINT `fk_loc_driver` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_loc_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_loc_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_locations`
--

LOCK TABLES `driver_locations` WRITE;
/*!40000 ALTER TABLE `driver_locations` DISABLE KEYS */;
INSERT INTO `driver_locations` VALUES (22,4001,4001,60523,0.90904513,-77.78997384,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:17:59'),(23,4001,4001,60523,0.90904514,-77.78997380,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:19:15'),(24,4001,4001,60523,0.90904514,-77.78997380,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:19:28'),(25,4001,4001,60523,0.90904512,-77.78997390,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:19:44'),(26,4001,4001,60523,0.90904513,-77.78997384,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:19:54'),(27,4001,4001,60523,0.90904514,-77.78997382,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:20:16'),(28,4001,4001,NULL,0.90904513,-77.78997387,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:21:24'),(29,4001,4001,NULL,0.90904514,-77.78997382,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:21:42'),(30,4001,4001,60523,0.90904514,-77.78997381,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:22:28'),(31,4001,4001,60523,0.90904514,-77.78997380,0.00,'Cl. 19 # 7-48, Cumbal, Nariño, Colombia','2026-04-16 04:23:56'),(35,4001,4001,60525,0.90960000,-77.79250000,0.00,'Cl. 19 #10-33, Cumbal, Nariño, Colombia','2026-08-11 05:01:41'),(36,4001,4001,60525,0.90960000,-77.79250000,0.00,'Cl. 19 #10-33, Cumbal, Nariño, Colombia','2026-08-11 05:03:04'),(37,4004,4003,60540,0.90910064,-77.78990094,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:28:10'),(38,4004,4003,60540,0.90910064,-77.78990091,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:31:37'),(39,4004,4003,60540,0.90910064,-77.78990094,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:31:51'),(40,4004,4003,60540,0.90910064,-77.78990094,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:32:37'),(41,4004,4003,60541,0.90910064,-77.78990094,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:41:50'),(42,4004,4003,60541,0.90910064,-77.78990091,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:42:51'),(43,4004,4003,60541,0.90910066,-77.78990074,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:43:08'),(44,4004,4003,60541,0.90910064,-77.78990088,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:43:25'),(45,4004,4003,60541,0.90910066,-77.78990069,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:43:37'),(46,4004,4003,60541,0.90910066,-77.78990069,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:43:59'),(47,4004,4003,60541,0.90910064,-77.78990089,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:45:27'),(48,4004,4003,60541,0.90910065,-77.78990082,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:45:38'),(49,4004,4003,60541,0.90910065,-77.78990078,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:45:48'),(50,4004,4003,60541,0.90910064,-77.78990089,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:46:02'),(51,4004,4003,NULL,0.90910066,-77.78990068,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:46:42'),(52,4004,4003,60541,0.90910066,-77.78990068,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:47:31'),(53,4004,4003,60541,0.90910066,-77.78990073,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:47:40'),(54,4004,4003,60541,0.90910065,-77.78990078,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:47:51'),(55,4004,4003,60541,0.90910064,-77.78990089,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:48:56'),(56,4004,4003,60541,0.90910066,-77.78990070,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:49:07'),(57,4004,4003,60541,0.90910066,-77.78990070,0.00,'Cl. 19 #7-44, Cumbal, Nariño, Colombia','2026-08-18 02:49:20');
/*!40000 ALTER TABLE `driver_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email`
--

DROP TABLE IF EXISTS `email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `message_provider_status` varchar(255) DEFAULT NULL,
  `message_type` varchar(255) DEFAULT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `message_content` text DEFAULT NULL,
  `message_attachment` varchar(255) DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `recipient` varchar(255) NOT NULL,
  `message_provider` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email`
--

LOCK TABLES `email` WRITE;
/*!40000 ALTER TABLE `email` DISABLE KEYS */;
/*!40000 ALTER TABLE `email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense`
--

DROP TABLE IF EXISTS `expense`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vehicle_id` bigint(20) NOT NULL,
  `trip_id` bigint(20) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `expense_date` date NOT NULL,
  `description` text DEFAULT NULL,
  `receipt_image_url` varchar(255) DEFAULT NULL,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `trip_id` (`trip_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `expense_ibfk_1` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`id`),
  CONSTRAINT `expense_ibfk_2` FOREIGN KEY (`trip_id`) REFERENCES `trip` (`id`),
  CONSTRAINT `expense_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `expense_category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=558414 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense`
--

LOCK TABLES `expense` WRITE;
/*!40000 ALTER TABLE `expense` DISABLE KEYS */;
INSERT INTO `expense` VALUES (558327,4001,60523,19,65000.00,'2026-04-16','',NULL,'2026-04-16 05:19:14','2026-04-16 05:19:14'),(558328,4001,60523,21,600000.00,'2026-04-15','',NULL,'2026-04-16 05:19:28','2026-04-16 05:22:28'),(558329,4001,60523,6,35000.00,'2026-04-16','',NULL,'2026-04-16 05:19:43','2026-04-16 05:19:43'),(558330,4001,60523,12,50000.00,'2026-04-16','',NULL,'2026-04-16 05:19:54','2026-04-16 05:19:54'),(558331,4001,60523,11,65000.00,'2026-04-16','',NULL,'2026-04-16 05:20:15','2026-04-16 05:20:15'),(558332,4001,NULL,30,125000.00,'2026-04-15','Arreglo de compuertas',NULL,'2026-04-16 05:21:23','2026-04-16 05:21:41'),(558333,4001,60523,3,60000.00,'2026-04-16','',NULL,'2026-04-16 05:25:12','2026-04-16 05:25:12'),(558334,4002,60524,21,1.00,'2026-08-07','tanqueada pasto ida',NULL,'2026-08-10 00:45:24','2026-08-10 00:58:56'),(558335,4002,60524,21,1600000.00,'2026-08-09','tanqueada pasto ida',NULL,'2026-08-10 00:46:51','2026-08-10 00:46:51'),(558336,4002,60524,19,333120.00,'2026-08-09','cargue azucar',NULL,'2026-08-10 00:47:32','2026-08-10 00:47:32'),(558337,4002,60524,39,200000.00,'2026-08-09','DIARIOS',NULL,'2026-08-10 00:50:44','2026-08-10 00:50:44'),(558338,4002,60524,10,940000.00,'2026-08-09','PAGO SEGURO MULA',NULL,'2026-08-10 00:52:03','2026-08-10 00:52:03'),(558339,4002,60524,39,100000.00,'2026-08-09','DIARIO',NULL,'2026-08-10 00:52:35','2026-08-10 00:52:35'),(558340,4002,60524,21,500000.00,'2026-08-09','RETANQUEO',NULL,'2026-08-10 00:53:48','2026-08-10 00:53:48'),(558341,4002,60524,16,79000.00,'2026-08-09','',NULL,'2026-08-10 00:56:15','2026-08-10 00:56:15'),(558342,4002,60524,23,23600.00,'2026-08-09','',NULL,'2026-08-10 00:57:04','2026-08-10 00:57:04'),(558343,4002,60524,22,626000.00,'2026-08-09','PEAJES VIAJE REDONDO IPIALES TULCAN',NULL,'2026-08-10 01:01:11','2026-08-10 01:01:11'),(558344,4002,NULL,25,5450000.00,'2026-08-09','PAGO CREDITO MULA MES DE AGOSTO',NULL,'2026-08-10 01:08:16','2026-08-10 01:08:16'),(558345,4002,NULL,26,940000.00,'2026-08-09','PAGO SEGURO MULA MES DE AGOSTO',NULL,'2026-08-10 01:09:00','2026-08-10 01:09:00'),(558346,4001,60526,21,150000.00,'2026-08-13','',NULL,'2026-08-13 05:43:53','2026-08-13 05:43:53'),(558347,4001,60528,23,125000.00,'2026-08-12','',NULL,'2026-08-13 07:02:57','2026-08-13 07:03:20'),(558348,4001,60528,19,45000.00,'2026-08-13','',NULL,'2026-08-14 00:42:36','2026-08-14 00:42:36'),(558349,4001,60530,21,350000.00,'2026-08-15','',NULL,'2026-08-16 01:18:14','2026-08-16 01:18:14'),(558350,4001,60530,3,30000.00,'2026-08-15','',NULL,'2026-08-16 01:18:29','2026-08-16 01:18:29'),(558351,4001,60530,11,120000.00,'2026-08-15','',NULL,'2026-08-16 01:18:40','2026-08-16 01:18:40'),(558352,4001,60531,21,300000.00,'2026-08-15','',NULL,'2026-08-16 01:22:53','2026-08-16 01:22:53'),(558353,4001,60531,18,60000.00,'2026-08-15','Comisionista Cali',NULL,'2026-08-16 01:23:18','2026-08-16 01:23:18'),(558354,4001,60531,9,25000.00,'2026-08-15','',NULL,'2026-08-16 01:23:39','2026-08-16 01:23:39'),(558355,4001,60531,4,35000.00,'2026-08-15','Cali',NULL,'2026-08-16 01:23:57','2026-08-16 01:23:57'),(558356,4001,60531,11,120000.00,'2026-08-15','',NULL,'2026-08-16 01:26:27','2026-08-16 01:26:27'),(558357,4001,60531,12,60000.00,'2026-08-15','',NULL,'2026-08-16 01:26:41','2026-08-16 01:26:41'),(558358,4001,60532,6,32000.00,'2026-08-15','',NULL,'2026-08-16 01:42:52','2026-08-16 01:42:52'),(558359,4001,60532,21,168000.00,'2026-08-15','',NULL,'2026-08-16 01:43:22','2026-08-16 01:43:22'),(558360,4001,60538,23,7500.00,'2026-08-14','',NULL,'2026-08-16 04:24:02','2026-08-16 04:24:23'),(558361,4001,60539,18,20000.00,'2026-08-16','',NULL,'2026-08-16 18:07:58','2026-08-16 18:07:58'),(558362,4001,60539,21,120000.00,'2026-08-16','',NULL,'2026-08-16 18:08:24','2026-08-16 18:08:24'),(558363,4001,60538,21,250000.00,'2026-08-16','',NULL,'2026-08-16 18:09:45','2026-08-16 18:09:45'),(558364,4001,60538,20,25000.00,'2026-08-16','',NULL,'2026-08-16 18:09:55','2026-08-16 18:09:55'),(558365,4001,60537,21,380000.00,'2026-08-16','',NULL,'2026-08-16 18:10:55','2026-08-16 18:10:55'),(558366,4001,60537,20,95000.00,'2026-08-16','',NULL,'2026-08-16 18:11:06','2026-08-16 18:11:06'),(558367,4001,60537,3,75000.00,'2026-08-16','',NULL,'2026-08-16 18:25:11','2026-08-16 18:25:11'),(558368,4001,60535,6,75000.00,'2026-08-16','',NULL,'2026-08-16 18:25:32','2026-08-16 18:25:32'),(558369,4001,60535,11,120000.00,'2026-08-16','',NULL,'2026-08-16 18:25:42','2026-08-16 18:25:42'),(558370,4001,60533,21,300000.00,'2026-08-16','',NULL,'2026-08-16 18:47:13','2026-08-16 18:47:13'),(558371,4003,60540,21,250000.00,'2026-08-17','',NULL,'2026-08-18 03:31:36','2026-08-18 03:31:36'),(558372,4003,60540,22,162000.00,'2026-08-17','',NULL,'2026-08-18 03:31:51','2026-08-18 03:31:51'),(558373,4003,60540,3,60000.00,'2026-08-17','Báscula pasto',NULL,'2026-08-18 03:32:37','2026-08-18 03:32:37'),(558374,4003,60540,12,80000.00,'2026-08-17','Remolino',NULL,'2026-08-18 03:35:49','2026-08-18 03:35:49'),(558375,4003,60540,11,120000.00,'2026-08-17','',NULL,'2026-08-18 03:36:17','2026-08-18 03:36:17'),(558376,4003,60540,21,350000.00,'2026-08-17','',NULL,'2026-08-18 03:37:18','2026-08-18 03:37:18'),(558377,4003,60541,21,650000.00,'2026-08-17','Tanqueada en Cali ',NULL,'2026-08-18 03:40:25','2026-08-18 03:40:25'),(558378,4003,60541,14,120000.00,'2026-08-17','Diario',NULL,'2026-08-18 03:40:51','2026-08-18 03:40:51'),(558379,4003,60541,6,32000.00,'2026-08-16','En el Valle del Cauca',NULL,'2026-08-18 03:42:51','2026-08-25 23:22:19'),(558380,4003,60541,23,26000.00,'2026-08-17','',NULL,'2026-08-18 03:43:08','2026-08-18 03:43:08'),(558381,4003,60541,19,75000.00,'2026-08-17','',NULL,'2026-08-18 03:43:25','2026-08-18 03:43:25'),(558382,4003,60541,18,120000.00,'2026-08-17','',NULL,'2026-08-18 03:43:36','2026-08-18 03:43:36'),(558383,4003,60541,22,120000.00,'2026-08-17','',NULL,'2026-08-18 03:43:58','2026-08-18 03:43:58'),(558384,4003,60541,8,125000.00,'2026-08-17','',NULL,'2026-08-18 03:45:27','2026-08-18 03:45:27'),(558385,4003,60541,12,120000.00,'2026-08-17','',NULL,'2026-08-18 03:45:37','2026-08-18 03:45:37'),(558386,4003,60541,21,740000.00,'2026-08-17','',NULL,'2026-08-18 03:45:47','2026-08-18 03:45:47'),(558387,4003,60541,22,120000.00,'2026-08-17','',NULL,'2026-08-18 03:46:02','2026-08-18 03:46:02'),(558388,4003,NULL,30,320000.00,'2026-08-17','Arreglo de compuertas con carpintero ',NULL,'2026-08-18 03:46:41','2026-08-18 03:46:41'),(558389,4003,60541,11,90000.00,'2026-08-17','',NULL,'2026-08-18 03:47:30','2026-08-18 03:47:30'),(558390,4003,60541,7,45000.00,'2026-08-17','',NULL,'2026-08-18 03:47:40','2026-08-18 03:47:40'),(558391,4003,60541,22,170000.00,'2026-08-17','',NULL,'2026-08-18 03:47:50','2026-08-18 03:47:50'),(558392,4003,60541,20,110000.00,'2026-08-17','',NULL,'2026-08-18 03:48:56','2026-08-18 03:48:56'),(558393,4003,60541,12,74000.00,'2026-08-17','',NULL,'2026-08-18 03:49:06','2026-08-18 03:49:06'),(558394,4003,60541,22,142000.00,'2026-08-17','',NULL,'2026-08-18 03:49:19','2026-08-18 03:49:19'),(558395,4003,60542,21,935000.00,'2026-08-17','',NULL,'2026-08-18 03:52:46','2026-08-18 03:52:46'),(558396,4003,60542,9,48000.00,'2026-08-17','',NULL,'2026-08-18 03:52:58','2026-08-18 03:52:58'),(558397,4003,60542,19,121000.00,'2026-08-17','',NULL,'2026-08-18 03:53:06','2026-08-18 03:53:06'),(558398,4003,60542,22,320000.00,'2026-08-17','',NULL,'2026-08-18 03:53:19','2026-08-18 03:53:19'),(558399,4003,60542,12,240000.00,'2026-08-17','',NULL,'2026-08-18 03:53:31','2026-08-18 03:53:31'),(558400,4003,60542,12,320000.00,'2026-08-17','',NULL,'2026-08-18 03:56:03','2026-08-18 03:56:03'),(558401,4003,60542,18,92000.00,'2026-08-17','',NULL,'2026-08-18 03:56:16','2026-08-18 03:56:16'),(558402,4003,60542,15,120000.00,'2026-08-17','',NULL,'2026-08-18 03:56:26','2026-08-18 03:56:26'),(558403,4003,60542,23,24800.00,'2026-08-17','',NULL,'2026-08-18 03:56:35','2026-08-18 03:56:35'),(558404,4003,60542,11,250000.00,'2026-08-17','',NULL,'2026-08-18 03:58:16','2026-08-18 03:58:16'),(558405,4003,60542,5,145000.00,'2026-08-17','',NULL,'2026-08-18 03:58:28','2026-08-18 03:58:28'),(558406,4004,60543,21,1300000.00,'2026-08-17','',NULL,'2026-08-18 04:01:36','2026-08-18 04:01:36'),(558407,4004,60543,22,420000.00,'2026-08-17','',NULL,'2026-08-18 04:01:46','2026-08-18 04:01:46'),(558408,4004,60543,12,180000.00,'2026-08-17','',NULL,'2026-08-18 04:01:55','2026-08-18 04:01:55'),(558409,4004,60543,11,120000.00,'2026-08-17','',NULL,'2026-08-18 04:02:04','2026-08-18 04:02:04'),(558410,4001,60544,21,2500000.00,'2026-08-21','',NULL,'2026-08-21 23:56:58','2026-08-21 23:56:58'),(558411,4003,NULL,30,120000.00,'2026-08-25','Arreglo compuertas',NULL,'2026-08-25 23:41:00','2026-08-25 23:41:00'),(558412,4003,60542,5,95000.00,'2026-08-25','Brillado de tanques',NULL,'2026-08-25 23:49:37','2026-08-25 23:49:37'),(558413,4003,60542,12,30000.00,'2026-08-25','Tangua',NULL,'2026-08-25 23:50:47','2026-08-25 23:50:47');
/*!40000 ALTER TABLE `expense` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_category`
--

DROP TABLE IF EXISTS `expense_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `expense_type_id` int(11) NOT NULL,
  `owner_id` bigint(20) DEFAULT NULL,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_category_per_owner` (`name`,`expense_type_id`,`owner_id`),
  KEY `expense_type_id` (`expense_type_id`),
  CONSTRAINT `expense_category_ibfk_1` FOREIGN KEY (`expense_type_id`) REFERENCES `expense_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_category`
--

LOCK TABLES `expense_category` WRITE;
/*!40000 ALTER TABLE `expense_category` DISABLE KEYS */;
INSERT INTO `expense_category` VALUES (1,'Encarrosada',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(2,'Descarrosada',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(3,'Bascula',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(4,'Parqueadero',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(5,'Lavado-brillado',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(6,'Engrasada',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(7,'Montallantas',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(8,'Accesorios',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(9,'Llantas',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(10,'Varios',1,NULL,'2026-03-31 16:08:04','2026-03-31 16:08:04'),(11,'Alimentación conductor',2,NULL,'2026-03-31 16:08:09','2026-08-25 23:43:56'),(12,'Hotel conductor',2,NULL,'2026-03-31 16:08:09','2026-03-31 16:08:09'),(13,'Seguridad social conductor',2,NULL,'2026-03-31 16:08:09','2026-03-31 16:08:09'),(14,'Varios',2,NULL,'2026-03-31 16:08:09','2026-03-31 16:08:09'),(15,'Descuento empresa',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(16,'Retenciones',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(17,'Cambio cheque o papeleo',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(18,'Comisiones',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(19,'Cargue',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(20,'Descargue',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(21,'Combustible',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(22,'Peajes',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(23,'Impuesto 4x1000',3,NULL,'2026-03-31 16:08:13','2026-08-16 04:12:10'),(24,'Varios',3,NULL,'2026-03-31 16:08:13','2026-03-31 16:08:13'),(25,'Créditos',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(26,'Seguros',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(27,'Revisión Tecnomecánica',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(28,'Llantas y rines',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(29,'Aceite, Grasa, Refrigerante',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(30,'Carrocería',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(31,'Lujos y Accesorios',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(32,'Eléctricos',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(33,'Mecánica General',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(34,'Mano de obra',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(35,'Viajes',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(36,'Otro',4,NULL,'2026-03-31 16:08:16','2026-03-31 16:08:16'),(37,'Salario',2,NULL,'2026-04-20 23:37:25','2026-04-20 23:37:25'),(38,'Salario',4,NULL,'2026-04-20 23:37:25','2026-04-20 23:37:25'),(39,'DIARIOS CONDUCTOR',2,2002,'2026-08-10 00:49:58','2026-08-10 00:49:58');
/*!40000 ALTER TABLE `expense_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_type`
--

DROP TABLE IF EXISTS `expense_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_type`
--

LOCK TABLES `expense_type` WRITE;
/*!40000 ALTER TABLE `expense_type` DISABLE KEYS */;
INSERT INTO `expense_type` VALUES (2,'Gastos del Conductor'),(1,'Gastos del Vehículo'),(3,'Gastos del Viaje'),(4,'Mantenimiento');
/*!40000 ALTER TABLE `expense_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gender`
--

DROP TABLE IF EXISTS `gender`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gender` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gender`
--

LOCK TABLES `gender` WRITE;
/*!40000 ALTER TABLE `gender` DISABLE KEYS */;
INSERT INTO `gender` VALUES (2,'Femenino'),(1,'Masculino');
/*!40000 ALTER TABLE `gender` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_type` varchar(50) NOT NULL,
  `message` text NOT NULL,
  `target_user_id` int(11) DEFAULT NULL,
  `target_role_id` int(11) NOT NULL,
  `owner_id` bigint(20) DEFAULT NULL,
  `reference_id` bigint(20) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `is_deleted` tinyint(1) DEFAULT 0,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `target_role_id` (`target_role_id`),
  KEY `owner_id` (`owner_id`),
  KEY `idx_notif_lookup` (`target_user_id`,`target_role_id`,`is_read`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notification_ibfk_2` FOREIGN KEY (`target_role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notification_ibfk_3` FOREIGN KEY (`owner_id`) REFERENCES `owner` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6225 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (5731,'OWNER_EVENT','Se ha actualizado el propietario: Owner 6',NULL,1,NULL,6,1,1,'2026-04-10 04:08:54','2026-04-17 04:37:59'),(6033,'OWNER_EVENT','Se ha actualizado el propietario: Owner 5',NULL,1,NULL,5,1,1,'2026-04-13 22:15:56','2026-04-17 04:37:59'),(6037,'OWNER_EVENT','Se ha creado un nuevo propietario: Julián Castro',NULL,1,NULL,2001,0,1,'2026-04-16 04:04:49','2026-04-17 04:37:59'),(6038,'OWNER_EVENT','Se ha actualizado el propietario: Julián Castro',NULL,1,NULL,2001,0,1,'2026-04-16 04:04:51','2026-04-17 04:37:59'),(6039,'DRIVER_EVENT','Se ha creado un nuevo conductor: Juan Perez ',NULL,1,2001,4001,1,1,'2026-04-16 04:07:24','2026-04-16 04:24:22'),(6040,'OWNER_EVENT','Se ha actualizado el propietario: Julián Castro Solis',NULL,1,NULL,2001,0,1,'2026-04-16 04:08:09','2026-04-17 04:37:59'),(6041,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: TMH-037',NULL,1,2001,4001,1,1,'2026-04-16 04:11:44','2026-04-16 04:24:21'),(6042,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: TMH-037',NULL,1,NULL,4001,0,1,'2026-04-16 04:11:46','2026-04-17 04:37:59'),(6043,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 0001 para el vehículo de placa: TMH-037',NULL,1,2001,60523,1,1,'2026-04-16 04:14:04','2026-04-16 04:24:19'),(6044,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 0001 para el vehículo de placa: TMH-037',NULL,1,2001,60523,1,1,'2026-04-16 04:15:07','2026-04-16 04:24:20'),(6045,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: TMH-037',NULL,1,2001,4001,1,1,'2026-04-16 04:16:03','2026-08-17 19:13:22'),(6046,'DRIVER_EVENT','Se ha actualizado el conductor: Juan Perez ',NULL,1,2001,4001,1,1,'2026-04-16 04:16:39','2026-08-17 19:13:24'),(6047,'DRIVER_EVENT','Se ha actualizado el conductor: Juan Perez ',NULL,1,2001,4001,1,1,'2026-04-16 04:16:53','2026-08-17 19:13:25'),(6048,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $65.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558327,1,1,'2026-04-16 04:19:14','2026-08-17 19:13:26'),(6049,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $650.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558328,1,1,'2026-04-16 04:19:28','2026-08-17 19:13:28'),(6050,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $35.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558329,1,1,'2026-04-16 04:19:43','2026-08-17 19:13:31'),(6051,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $50.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558330,1,1,'2026-04-16 04:19:54','2026-08-17 19:13:32'),(6052,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $65.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558331,1,1,'2026-04-16 04:20:15','2026-08-17 19:13:33'),(6053,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $120.000 del vehículo de placa: TMH-037',NULL,1,2001,558332,1,1,'2026-04-16 04:21:23','2026-08-17 19:13:34'),(6054,'EXPENSE_EVENT','Se ha actualizado el Mantenimiento por valor de: $125.000 del vehículo de placa: TMH-037',NULL,1,2001,558332,1,1,'2026-04-16 04:21:41','2026-08-17 19:13:35'),(6055,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $600.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558328,1,1,'2026-04-16 04:22:28','2026-08-17 19:13:35'),(6056,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $60.000 para el viaje nro: 1 del vehículo de placa: TMH-037',NULL,1,2001,558333,1,1,'2026-04-16 04:25:12','2026-08-17 19:13:36'),(6057,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 0001 para el vehículo de placa: TMH-037',NULL,1,2001,60523,1,1,'2026-04-16 04:26:57','2026-08-17 19:13:37'),(6058,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 0001 para el vehículo de placa: TMH-037',NULL,1,2001,60523,1,1,'2026-04-16 04:27:49','2026-08-17 19:13:38'),(6059,'OWNER_EVENT','Se ha creado un nuevo propietario: John H. Hernandez Ortiz',NULL,1,NULL,2002,1,1,'2026-08-09 21:07:50','2026-08-17 01:59:21'),(6060,'OWNER_EVENT','Se ha actualizado el propietario: John H. Hernandez Ortiz',NULL,1,NULL,2002,0,1,'2026-08-09 21:10:17','2026-08-17 01:59:19'),(6061,'DRIVER_EVENT','Se ha creado un nuevo conductor: DIEGO HERNANDEZ',NULL,1,2002,4002,0,0,'2026-08-09 22:43:10','2026-08-09 22:43:10'),(6062,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: TFU-353',NULL,1,2002,4002,0,0,'2026-08-09 22:47:01','2026-08-09 22:47:01'),(6063,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: TFU-353',NULL,1,NULL,4002,1,0,'2026-08-09 22:47:02','2026-08-17 01:59:23'),(6064,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 2600100041104M para el vehículo de placa: TFU-353',NULL,1,2002,60524,0,0,'2026-08-09 23:21:16','2026-08-09 23:21:16'),(6065,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 2600100041104M para el vehículo de placa: TFU-353',NULL,1,2002,60524,0,0,'2026-08-09 23:22:18','2026-08-09 23:22:18'),(6066,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Jjj para el vehículo de placa: TMH-037',NULL,1,2001,60525,1,1,'2026-08-09 23:34:47','2026-08-17 19:13:39'),(6067,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $130.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558334,0,0,'2026-08-09 23:45:24','2026-08-09 23:45:24'),(6068,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $1.600.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558334,0,0,'2026-08-09 23:46:14','2026-08-09 23:46:14'),(6069,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $1.600.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558335,0,0,'2026-08-09 23:46:51','2026-08-09 23:46:51'),(6070,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $333.120 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558336,0,0,'2026-08-09 23:47:32','2026-08-09 23:47:32'),(6071,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $200.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558337,0,0,'2026-08-09 23:50:44','2026-08-09 23:50:44'),(6072,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $940.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558338,0,0,'2026-08-09 23:52:03','2026-08-09 23:52:03'),(6073,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $100.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558339,0,0,'2026-08-09 23:52:35','2026-08-09 23:52:35'),(6074,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $500.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558340,0,0,'2026-08-09 23:53:48','2026-08-09 23:53:48'),(6075,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $79.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558341,0,0,'2026-08-09 23:56:15','2026-08-09 23:56:15'),(6076,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $23.600 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558342,0,0,'2026-08-09 23:57:04','2026-08-09 23:57:04'),(6077,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $1 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558334,0,0,'2026-08-09 23:58:56','2026-08-09 23:58:56'),(6078,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $626.000 para el viaje nro: 1 del vehículo de placa: TFU-353',NULL,1,2002,558343,0,0,'2026-08-10 00:01:11','2026-08-10 00:01:11'),(6079,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 2600100041104M para el vehículo de placa: TFU-353',NULL,1,2002,60524,0,0,'2026-08-10 00:03:41','2026-08-10 00:03:41'),(6080,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $5.450.000 del vehículo de placa: TFU-353',NULL,1,2002,558344,0,0,'2026-08-10 00:08:16','2026-08-10 00:08:16'),(6081,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $940.000 del vehículo de placa: TFU-353',NULL,1,2002,558345,0,0,'2026-08-10 00:09:00','2026-08-10 00:09:00'),(6082,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Jjj para el vehículo de placa: TMH-037',NULL,1,2001,60525,1,1,'2026-08-11 16:53:44','2026-08-17 19:14:14'),(6083,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Jjj para el vehículo de placa: TMH-037',NULL,1,2001,60525,1,1,'2026-08-11 16:54:05','2026-08-17 19:14:15'),(6084,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Jjj para el vehículo de placa: TMH-037',NULL,1,2001,60525,1,1,'2026-08-13 02:32:30','2026-08-17 19:14:16'),(6085,'TRIP_EVENT','Se ha creado un nuevo viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60526,1,1,'2026-08-13 03:11:23','2026-08-17 19:14:16'),(6086,'TRIP_EVENT','Se ha actualizado el viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60526,1,1,'2026-08-13 03:13:56','2026-08-17 19:14:17'),(6087,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 2600100041104M para el vehículo de placa: TMH-037',NULL,1,2001,60527,1,1,'2026-08-13 03:17:03','2026-08-17 19:14:19'),(6088,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 2600100041104M para el vehículo de placa: TMH-037',NULL,1,2001,60527,1,1,'2026-08-13 03:36:32','2026-08-17 19:14:23'),(6089,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 12 para el vehículo de placa: TMH-037',NULL,1,2001,60528,1,1,'2026-08-13 03:37:40','2026-08-17 19:14:24'),(6090,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $150.000 para el viaje nro: 3 del vehículo de placa: TMH-037',NULL,1,2001,558346,1,1,'2026-08-13 04:43:53','2026-08-17 19:14:31'),(6091,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 12 para el vehículo de placa: TMH-037',NULL,1,2001,60528,1,1,'2026-08-13 05:41:22','2026-08-17 19:14:32'),(6092,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $125.400 para el viaje nro: 5 del vehículo de placa: TMH-037',NULL,1,2001,558347,1,1,'2026-08-13 06:02:57','2026-08-17 19:14:33'),(6093,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $125.000 para el viaje nro: 5 del vehículo de placa: TMH-037',NULL,1,2001,558347,1,1,'2026-08-13 06:03:20','2026-08-17 19:11:11'),(6094,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 52345 para el vehículo de placa: TMH-037',NULL,1,2001,60529,1,1,'2026-08-13 20:52:03','2026-08-17 19:11:12'),(6095,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $45.000 para el viaje nro: 5 del vehículo de placa: TMH-037',NULL,1,2001,558348,1,1,'2026-08-13 23:42:36','2026-08-17 19:11:13'),(6096,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto 52345 para el vehículo de placa: TMH-037',NULL,1,2001,60529,1,1,'2026-08-16 00:09:51','2026-08-17 19:11:14'),(6097,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test1 para el vehículo de placa: TMH-037',NULL,1,2001,60530,1,1,'2026-08-16 00:13:14','2026-08-17 19:11:19'),(6098,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test1 para el vehículo de placa: TMH-037',NULL,1,2001,60530,1,1,'2026-08-16 00:14:38','2026-08-17 19:11:24'),(6099,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $350.000 para el viaje nro: 7 del vehículo de placa: TMH-037',NULL,1,2001,558349,1,1,'2026-08-16 00:18:14','2026-08-17 19:11:19'),(6100,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $30.000 para el viaje nro: 7 del vehículo de placa: TMH-037',NULL,1,2001,558350,1,1,'2026-08-16 00:18:29','2026-08-17 19:11:25'),(6101,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 7 del vehículo de placa: TMH-037',NULL,1,2001,558351,1,1,'2026-08-16 00:18:40','2026-08-17 19:11:30'),(6102,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test1 para el vehículo de placa: TMH-037',NULL,1,2001,60530,1,1,'2026-08-16 00:20:26','2026-08-17 19:11:29'),(6103,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test 2 para el vehículo de placa: TMH-037',NULL,1,2001,60531,1,1,'2026-08-16 00:21:49','2026-08-17 19:11:41'),(6104,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $300.000 para el viaje nro: 8 del vehículo de placa: TMH-037',NULL,1,2001,558352,1,1,'2026-08-16 00:22:53','2026-08-17 19:11:42'),(6105,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $60.000 para el viaje nro: 8 del vehículo de placa: TMH-037',NULL,1,2001,558353,1,1,'2026-08-16 00:23:18','2026-08-17 19:11:59'),(6106,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $25.000 para el viaje nro: 8 del vehículo de placa: TMH-037',NULL,1,2001,558354,1,1,'2026-08-16 00:23:39','2026-08-17 19:11:43'),(6107,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $35.000 para el viaje nro: 8 del vehículo de placa: TMH-037',NULL,1,2001,558355,1,1,'2026-08-16 00:23:57','2026-08-17 19:11:58'),(6108,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 2 para el vehículo de placa: TMH-037',NULL,1,2001,60531,1,1,'2026-08-16 00:24:59','2026-08-17 19:11:52'),(6109,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 8 del vehículo de placa: TMH-037',NULL,1,2001,558356,1,1,'2026-08-16 00:26:27','2026-08-17 19:11:51'),(6110,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $60.000 para el viaje nro: 8 del vehículo de placa: TMH-037',NULL,1,2001,558357,1,1,'2026-08-16 00:26:41','2026-08-17 19:11:53'),(6111,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 2 para el vehículo de placa: TMH-037',NULL,1,2001,60531,1,1,'2026-08-16 00:27:50','2026-08-17 19:12:07'),(6112,'TRIP_EVENT','Se ha creado un nuevo viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60532,1,1,'2026-08-16 00:36:30','2026-08-17 19:11:57'),(6113,'TRIP_EVENT','Se ha actualizado el viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60532,1,1,'2026-08-16 00:42:15','2026-08-17 19:12:08'),(6114,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $32.000 para el viaje nro: 9 del vehículo de placa: TMH-037',NULL,1,2001,558358,1,1,'2026-08-16 00:42:52','2026-08-17 19:12:06'),(6115,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $168.000 para el viaje nro: 9 del vehículo de placa: TMH-037',NULL,1,2001,558359,1,1,'2026-08-16 00:43:22','2026-08-17 19:12:09'),(6116,'TRIP_EVENT','Se ha actualizado el viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60532,1,1,'2026-08-16 00:46:35','2026-08-17 19:12:05'),(6117,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test 4 para el vehículo de placa: TMH-037',NULL,1,2001,60533,1,1,'2026-08-16 02:04:33','2026-08-17 19:12:16'),(6118,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 4 para el vehículo de placa: TMH-037',NULL,1,2001,60533,1,1,'2026-08-16 02:05:12','2026-08-17 19:12:17'),(6119,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto TEst 5 para el vehículo de placa: TMH-037',NULL,1,2001,60534,1,1,'2026-08-16 02:05:53','2026-08-17 19:12:18'),(6120,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto TEst 5 para el vehículo de placa: TMH-037',NULL,1,2001,60534,1,1,'2026-08-16 02:09:33','2026-08-17 19:12:19'),(6121,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test 6 para el vehículo de placa: TMH-037',NULL,1,2001,60535,1,1,'2026-08-16 02:10:25','2026-08-17 19:12:20'),(6122,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 6 para el vehículo de placa: TMH-037',NULL,1,2001,60535,1,1,'2026-08-16 02:10:52','2026-08-17 19:12:29'),(6123,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test 7 para el vehículo de placa: TMH-037',NULL,1,2001,60536,1,1,'2026-08-16 02:12:18','2026-08-17 19:12:31'),(6124,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 7 para el vehículo de placa: TMH-037',NULL,1,2001,60536,1,1,'2026-08-16 02:16:51','2026-08-17 19:12:30'),(6125,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test 8 para el vehículo de placa: TMH-037',NULL,1,2001,60537,1,1,'2026-08-16 02:17:22','2026-08-17 19:12:32'),(6126,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 8 para el vehículo de placa: TMH-037',NULL,1,2001,60537,1,1,'2026-08-16 02:17:42','2026-08-17 19:12:34'),(6127,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto Test 9 para el vehículo de placa: TMH-037',NULL,1,2001,60538,1,1,'2026-08-16 02:18:36','2026-08-17 19:12:35'),(6128,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto Test 9 para el vehículo de placa: TMH-037',NULL,1,2001,60538,1,1,'2026-08-16 02:32:06','2026-08-17 19:12:42'),(6129,'TRIP_EVENT','Se ha creado un nuevo viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60539,1,1,'2026-08-16 02:33:21','2026-08-17 19:12:44'),(6130,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $6.600 para el viaje nro: 15 del vehículo de placa: TMH-037',NULL,1,2001,558360,1,1,'2026-08-16 03:24:02','2026-08-17 19:12:46'),(6131,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $7.500 para el viaje nro: 15 del vehículo de placa: TMH-037',NULL,1,2001,558360,1,1,'2026-08-16 03:24:23','2026-08-17 19:12:47'),(6132,'OWNER_EVENT','Se ha creado un nuevo propietario: William Burbano',NULL,1,NULL,2003,1,0,'2026-08-16 16:02:53','2026-08-17 01:59:24'),(6133,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $20.000 para el viaje nro: 16 del vehículo de placa: TMH-037',NULL,1,2001,558361,1,1,'2026-08-16 17:07:58','2026-08-17 19:12:48'),(6134,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 16 del vehículo de placa: TMH-037',NULL,1,2001,558362,1,1,'2026-08-16 17:08:24','2026-08-17 19:12:55'),(6135,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $250.000 para el viaje nro: 15 del vehículo de placa: TMH-037',NULL,1,2001,558363,1,1,'2026-08-16 17:09:45','2026-08-17 19:12:56'),(6136,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $25.000 para el viaje nro: 15 del vehículo de placa: TMH-037',NULL,1,2001,558364,1,1,'2026-08-16 17:09:55','2026-08-17 19:12:57'),(6137,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $380.000 para el viaje nro: 14 del vehículo de placa: TMH-037',NULL,1,2001,558365,1,1,'2026-08-16 17:10:55','2026-08-17 19:12:58'),(6138,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $95.000 para el viaje nro: 14 del vehículo de placa: TMH-037',NULL,1,2001,558366,1,1,'2026-08-16 17:11:06','2026-08-17 19:12:59'),(6139,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $75.000 para el viaje nro: 14 del vehículo de placa: TMH-037',NULL,1,2001,558367,1,1,'2026-08-16 17:25:11','2026-08-17 19:14:39'),(6140,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $75.000 para el viaje nro: 12 del vehículo de placa: TMH-037',NULL,1,2001,558368,1,1,'2026-08-16 17:25:32','2026-08-17 19:14:35'),(6141,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 12 del vehículo de placa: TMH-037',NULL,1,2001,558369,1,0,'2026-08-16 17:25:42','2026-08-17 19:12:53'),(6142,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $300.000 para el viaje nro: 10 del vehículo de placa: TMH-037',NULL,1,2001,558370,1,0,'2026-08-16 17:47:13','2026-08-17 19:13:13'),(6143,'OWNER_EVENT','Se ha creado un nuevo propietario: Test 1',NULL,1,NULL,2004,1,1,'2026-08-16 19:52:45','2026-08-21 20:16:02'),(6144,'DRIVER_EVENT','Se ha creado un nuevo conductor: Conductor 1',NULL,1,2004,4004,1,1,'2026-08-16 19:57:23','2026-08-18 02:28:46'),(6145,'DRIVER_EVENT','Se ha creado un nuevo conductor: Conductor 2',NULL,1,2004,4005,1,1,'2026-08-16 19:58:16','2026-08-18 02:28:48'),(6146,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: TRG-587',NULL,1,2004,4003,1,1,'2026-08-16 20:02:08','2026-08-18 02:28:46'),(6147,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: TGG-341',NULL,1,2004,4004,1,1,'2026-08-16 20:05:23','2026-08-18 02:28:50'),(6148,'DRIVER_EVENT','Se ha creado un nuevo conductor: Conductor 3',NULL,1,2004,4006,0,1,'2026-08-16 20:06:30','2026-08-18 02:28:48'),(6149,'TRIP_EVENT','Se ha actualizado el viaje sin manifiesto para el vehículo de placa: TMH-037',NULL,1,2001,60539,1,0,'2026-08-17 18:58:26','2026-08-17 19:13:12'),(6150,'DRIVER_EVENT','Se ha actualizado el conductor: Conductor 3',NULL,1,2004,4006,1,1,'2026-08-18 02:14:47','2026-08-27 03:23:36'),(6151,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: TRG-587',NULL,1,2004,4003,1,1,'2026-08-18 02:16:27','2026-08-27 03:23:36'),(6152,'DRIVER_EVENT','Se ha actualizado el conductor: Conductor 1',NULL,1,2004,4004,0,1,'2026-08-18 02:22:13','2026-08-21 16:41:27'),(6153,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto MF000001 para el vehículo de placa: TRG-587',NULL,1,2004,60540,0,1,'2026-08-18 02:26:09','2026-08-21 16:41:27'),(6154,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $250.000 para el viaje nro: 1 del vehículo de placa: TRG-587',NULL,1,2004,558371,0,1,'2026-08-18 02:31:36','2026-08-21 16:41:24'),(6155,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $162.000 para el viaje nro: 1 del vehículo de placa: TRG-587',NULL,1,2004,558372,0,1,'2026-08-18 02:31:51','2026-08-21 16:41:26'),(6156,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $60.000 para el viaje nro: 1 del vehículo de placa: TRG-587',NULL,1,2004,558373,0,1,'2026-08-18 02:32:37','2026-08-21 16:41:26'),(6157,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $80.000 para el viaje nro: 1 del vehículo de placa: TRG-587',NULL,1,2004,558374,0,1,'2026-08-18 02:35:49','2026-08-27 03:23:36'),(6158,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 1 del vehículo de placa: TRG-587',NULL,1,2004,558375,0,1,'2026-08-18 02:36:17','2026-08-21 16:41:29'),(6159,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $350.000 para el viaje nro: 1 del vehículo de placa: TRG-587',NULL,1,2004,558376,0,1,'2026-08-18 02:37:18','2026-08-27 03:23:36'),(6160,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto MF000001 para el vehículo de placa: TRG-587',NULL,1,2004,60540,0,1,'2026-08-18 02:38:01','2026-08-21 16:41:30'),(6161,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto MF00002 para el vehículo de placa: TRG-587',NULL,1,2004,60541,0,1,'2026-08-18 02:39:30','2026-08-21 16:41:36'),(6162,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $650.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558377,0,1,'2026-08-18 02:40:25','2026-08-21 16:41:38'),(6163,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558378,0,1,'2026-08-18 02:40:51','2026-08-21 16:41:32'),(6164,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $32.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558379,0,1,'2026-08-18 02:42:51','2026-08-21 16:41:33'),(6165,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $26.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558380,0,1,'2026-08-18 02:43:08','2026-08-21 16:41:35'),(6166,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $75.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558381,0,1,'2026-08-18 02:43:25','2026-08-21 16:41:37'),(6167,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558382,0,1,'2026-08-18 02:43:36','2026-08-21 16:41:39'),(6168,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558383,0,1,'2026-08-18 02:43:58','2026-08-21 16:41:40'),(6169,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto MF000001 para el vehículo de placa: TRG-587',NULL,1,2004,60540,0,1,'2026-08-18 02:44:23','2026-08-21 16:41:42'),(6170,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $125.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558384,0,1,'2026-08-18 02:45:27','2026-08-21 16:41:41'),(6171,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558385,0,1,'2026-08-18 02:45:37','2026-08-21 16:41:43'),(6172,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $740.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558386,0,1,'2026-08-18 02:45:47','2026-08-21 16:41:45'),(6173,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558387,0,1,'2026-08-18 02:46:02','2026-08-21 16:41:46'),(6174,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $320.000 del vehículo de placa: TRG-587',NULL,1,2004,558388,0,1,'2026-08-18 02:46:41','2026-08-21 16:41:47'),(6175,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $90.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558389,0,1,'2026-08-18 02:47:30','2026-08-21 16:41:48'),(6176,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $45.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558390,0,1,'2026-08-18 02:47:40','2026-08-21 16:41:49'),(6177,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $170.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558391,0,1,'2026-08-18 02:47:50','2026-08-21 16:41:50'),(6178,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $110.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558392,0,1,'2026-08-18 02:48:56','2026-08-21 16:41:50'),(6179,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $74.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558393,0,1,'2026-08-18 02:49:06','2026-08-21 16:41:51'),(6180,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $142.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558394,0,1,'2026-08-18 02:49:19','2026-08-21 16:41:52'),(6181,'TRIP_EVENT','Se ha actualizado el viaje con manifiesto MF00002 para el vehículo de placa: TRG-587',NULL,1,2004,60541,0,1,'2026-08-18 02:50:40','2026-08-21 16:41:52'),(6182,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto MF00003 para el vehículo de placa: TRG-587',NULL,1,2004,60542,0,1,'2026-08-18 02:52:21','2026-08-21 16:41:53'),(6183,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $935.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558395,0,1,'2026-08-18 02:52:46','2026-08-21 16:41:57'),(6184,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $48.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558396,0,1,'2026-08-18 02:52:58','2026-08-21 16:41:57'),(6185,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $121.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558397,0,1,'2026-08-18 02:53:06','2026-08-21 16:41:56'),(6186,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $320.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558398,0,1,'2026-08-18 02:53:19','2026-08-21 16:41:56'),(6187,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $240.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558399,0,1,'2026-08-18 02:53:31','2026-08-21 16:41:55'),(6188,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $320.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558400,0,1,'2026-08-18 02:56:03','2026-08-21 16:41:58'),(6189,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $92.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558401,0,1,'2026-08-18 02:56:16','2026-08-21 16:41:58'),(6190,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558402,0,1,'2026-08-18 02:56:26','2026-08-21 16:41:59'),(6191,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $24.800 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558403,0,1,'2026-08-18 02:56:35','2026-08-21 16:41:59'),(6192,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $250.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558404,0,1,'2026-08-18 02:58:16','2026-08-21 16:41:59'),(6193,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $145.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558405,0,1,'2026-08-18 02:58:28','2026-08-21 16:42:00'),(6194,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto MF1111 para el vehículo de placa: TGG-341',NULL,1,2004,60543,0,1,'2026-08-18 03:00:06','2026-08-21 16:42:00'),(6195,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: TGG-341',NULL,1,2004,4004,0,1,'2026-08-18 03:00:32','2026-08-21 16:42:01'),(6196,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $1.300.000 para el viaje nro: 1 del vehículo de placa: TGG-341',NULL,1,2004,558406,0,1,'2026-08-18 03:01:36','2026-08-27 03:23:36'),(6197,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $420.000 para el viaje nro: 1 del vehículo de placa: TGG-341',NULL,1,2004,558407,0,1,'2026-08-18 03:01:46','2026-08-21 16:42:04'),(6198,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $180.000 para el viaje nro: 1 del vehículo de placa: TGG-341',NULL,1,2004,558408,0,1,'2026-08-18 03:01:55','2026-08-21 16:42:03'),(6199,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $120.000 para el viaje nro: 1 del vehículo de placa: TGG-341',NULL,1,2004,558409,0,1,'2026-08-18 03:02:04','2026-08-27 03:23:36'),(6200,'DRIVER_EVENT','Se ha creado un nuevo conductor: José Burbano ',NULL,1,2002,4007,0,0,'2026-08-19 22:09:07','2026-08-19 22:09:07'),(6201,'VEHICLE_EVENT','Se ha creado un nuevo vehículo de placa: WRD-296',NULL,1,2002,4005,0,0,'2026-08-19 22:10:42','2026-08-19 22:10:42'),(6202,'VEHICLE_EVENT','Se ha actualizado el vehículo de placa: WRD-296',NULL,1,2002,4005,0,0,'2026-08-19 22:11:28','2026-08-19 22:11:28'),(6203,'SUBSCRIPTION_EXPIRATION','La suscripción de Test 1 vence en 10 días (31/08/2026). Al vencer no será posible ingresar a la aplicación. Contacta al administrador por WhatsApp para renovarla.',NULL,2,2004,2004,0,1,'2026-08-21 17:46:22','2026-08-21 16:47:12'),(6204,'OWNER_EVENT','Se ha actualizado el propietario: William Burbano',NULL,1,NULL,2003,0,1,'2026-08-21 16:53:26','2026-08-21 20:16:00'),(6205,'OWNER_EVENT','Se ha actualizado el propietario: William Burbano',NULL,1,NULL,2003,0,1,'2026-08-21 16:56:21','2026-08-21 20:15:59'),(6206,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,1,'2026-08-21 17:20:01','2026-08-21 20:15:59'),(6207,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,1,'2026-08-21 17:45:34','2026-08-21 20:15:58'),(6208,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,1,'2026-08-21 19:57:38','2026-08-21 20:15:57'),(6209,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,1,'2026-08-21 20:05:06','2026-08-21 20:15:57'),(6210,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,1,'2026-08-21 20:07:28','2026-08-21 20:15:56'),(6211,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,1,'2026-08-21 20:07:38','2026-08-21 20:15:55'),(6212,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,0,'2026-08-21 20:08:52','2026-08-21 20:08:52'),(6213,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,0,'2026-08-21 20:14:26','2026-08-21 20:14:26'),(6214,'TRIP_EVENT','Se ha creado un nuevo viaje con manifiesto 567 para el vehículo de placa: TMH-037',NULL,1,2001,60544,0,0,'2026-08-21 22:55:32','2026-08-21 22:55:32'),(6215,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $2.500.000 para el viaje nro: 17 del vehículo de placa: TMH-037',NULL,1,2001,558410,0,0,'2026-08-21 22:56:59','2026-08-21 22:56:59'),(6216,'OWNER_EVENT','Se ha creado un nuevo propietario: Julián Castro Solis',NULL,1,NULL,2005,0,0,'2026-08-25 16:16:03','2026-08-25 16:16:03'),(6217,'OWNER_EVENT','Se ha actualizado el propietario: Julián Castro Solis',NULL,1,NULL,2005,0,0,'2026-08-25 16:16:07','2026-08-25 16:16:07'),(6218,'EXPENSE_EVENT','Se ha actualizado el Gasto por valor de: $32.000 para el viaje nro: 2 del vehículo de placa: TRG-587',NULL,1,2004,558379,0,1,'2026-08-25 22:22:20','2026-08-27 03:23:36'),(6219,'EXPENSE_EVENT','Se ha registrado un nuevo Mantenimiento por valor de: $120.000 del vehículo de placa: TRG-587',NULL,1,2004,558411,0,1,'2026-08-25 22:41:01','2026-08-27 03:23:36'),(6220,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $95.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558412,0,1,'2026-08-25 22:49:38','2026-08-27 03:23:36'),(6221,'EXPENSE_EVENT','Se ha registrado un nuevo Gasto por valor de: $30.000 para el viaje nro: 3 del vehículo de placa: TRG-587',NULL,1,2004,558413,0,1,'2026-08-25 22:50:47','2026-08-27 03:23:34'),(6222,'OWNER_EVENT','Se ha actualizado el propietario: Test 1',NULL,1,NULL,2004,0,0,'2026-08-26 22:37:32','2026-08-26 22:37:32'),(6223,'OWNER_EVENT','Se ha creado un nuevo propietario: Nuevo Owner',NULL,1,NULL,2006,0,0,'2026-08-27 04:39:34','2026-08-27 04:39:34'),(6224,'OWNER_EVENT','Se ha creado un nuevo propietario: newTest',NULL,1,NULL,2007,0,0,'2026-08-27 04:46:21','2026-08-27 04:46:21');
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `owner`
--

DROP TABLE IF EXISTS `owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owner` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `photo` varchar(120) DEFAULT NULL,
  `document_type_id` int(11) NOT NULL,
  `document_number` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `email` varchar(100) NOT NULL,
  `cell_phone` varchar(20) NOT NULL,
  `city_id` int(11) DEFAULT NULL,
  `gender_id` int(11) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `age` int(11) GENERATED ALWAYS AS (timestampdiff(YEAR,`birthdate`,curdate())) VIRTUAL,
  `user_id` int(11) DEFAULT NULL,
  `max_vehicles` int(11) NOT NULL DEFAULT 3,
  `is_driver` tinyint(1) NOT NULL DEFAULT 0,
  `subscription_end_date` date DEFAULT NULL,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `document_number` (`document_number`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `document_type_id` (`document_type_id`),
  KEY `city_id` (`city_id`),
  KEY `gender_id` (`gender_id`),
  CONSTRAINT `owner_ibfk_1` FOREIGN KEY (`document_type_id`) REFERENCES `document_type` (`id`),
  CONSTRAINT `owner_ibfk_2` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`),
  CONSTRAINT `owner_ibfk_3` FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`),
  CONSTRAINT `owner_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2008 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `owner`
--

LOCK TABLES `owner` WRITE;
/*!40000 ALTER TABLE `owner` DISABLE KEYS */;
INSERT INTO `owner` (`id`, `photo`, `document_type_id`, `document_number`, `name`, `email`, `cell_phone`, `city_id`, `gender_id`, `birthdate`, `user_id`, `max_vehicles`, `is_driver`, `subscription_end_date`, `creation_date`, `update_date`) VALUES (2001,'https://truck.ccsoluciones.com.co/truck/images/owner/photo2001.webp?t=1776316075338',1,'87542142','Julián Castro Solis','julian@gmail.com','3025852365',32,1,'1984-04-14',6001,3,0,'2027-07-21','2026-04-16 05:04:49','2026-08-27 03:41:16'),(2002,'https://truck.ccsoluciones.com.co/truck/images/owner/photo2002.webp',1,'1088589009','John H. Hernandez Ortiz','ing.jhenry@gmail.com','3126709282',32,1,'1986-05-07',6003,3,0,'2027-07-21','2026-08-09 22:07:50','2026-08-27 03:41:17'),(2004,'',1,'4567456','Test 1','test@gmail.com','3147235739',5,1,'2008-08-06',6005,2,0,'2026-10-20','2026-08-16 20:52:45','2026-08-27 03:36:50'),(2005,'https://truck.ccsoluciones.com.co/truck/images/owner/photo2005.webp',1,'87513683','Julián Castro Solis','julianc477@gmail.com','3014929602',3,1,'1984-03-27',6009,3,0,'2027-08-25','2026-08-25 17:16:03','2026-08-27 03:41:17');
/*!40000 ALTER TABLE `owner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset`
--

DROP TABLE IF EXISTS `password_reset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `code` varchar(128) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  `attempts` int(11) NOT NULL DEFAULT 0,
  `reset_token` varchar(64) DEFAULT NULL,
  `expiration_date` datetime NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT current_timestamp(),
  `update_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_password_reset_token` (`reset_token`),
  KEY `idx_password_reset_user` (`user_id`),
  KEY `idx_password_reset_phone` (`phone`,`status`),
  CONSTRAINT `fk_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset`
--

LOCK TABLES `password_reset` WRITE;
/*!40000 ALTER TABLE `password_reset` DISABLE KEYS */;
INSERT INTO `password_reset` VALUES (1,6005,'+573147235739','363e29d04c9a3ca6b284af4c4823c04755e67cc4cc0a0f6b701ab9e1782a620e528eb6b6c70a863a14f8591d99235a564f7373c3e9d468e7d3bfbabe5d010ace','Cancelled',0,NULL,'2026-08-26 22:46:56','2026-08-26 22:36:56','2026-08-26 22:49:28'),(2,6005,'+573147235739','ab519293d75c66b78ef66b242ab5f7a040b8840ed621a5535ee5b48e482d8fa8f2d1016c41c21bfe6f1e6da5e2526547f773902e5971de49960af73343f4d39c','Cancelled',0,NULL,'2026-08-26 22:59:28','2026-08-26 22:49:28','2026-08-26 23:04:15'),(3,6005,'+573147235739','2f135f74e596c92f0db79cb0634eb08e994fa2e5d6cfc325ffe114ec664bd8dea319c66f454c4f5953f0ccb39af47b9cf45a4bd9a0dc483b7287663c1fc5fd1d','Cancelled',0,NULL,'2026-08-26 23:20:11','2026-08-26 23:04:15','2026-08-26 23:20:54'),(4,6005,'+573147235739','531162361b7d18677680ef66b2ad4ee0f51209798a761221d1bd577691cd7b4f7691d3aeafc2d253d23c7d37e3eb4cbb04e53d5ceaa78a1eed16be148d2c7190','Cancelled',0,NULL,'2026-08-26 23:36:29','2026-08-26 23:20:54','2026-08-26 23:22:31'),(5,6005,'+573147235739','b5382416b4d59a0ad9ba8b951a142714021699d4ffeb4cc25e49b41cda43ea6e1e6c1fe0978dadc50297d217d79dcef07265694cafa2f452e3f0699169b9d8e3','Used',0,NULL,'2026-08-26 23:37:58','2026-08-26 23:22:31','2026-08-26 23:22:59');
/*!40000 ALTER TABLE `password_reset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT current_timestamp(),
  `update_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Administrador','Administrador del sistema con todos los permisos','2026-02-28 16:15:07','2026-02-28 16:15:07'),(2,'Propietario','Usuario con permisos sobre viajes, vehiculos y gastos','2026-02-28 16:15:07','2026-02-28 16:15:07'),(3,'Conductor','Usuario con permisos sobre gastos','2026-02-28 16:15:07','2026-02-28 16:15:07');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_type`
--

DROP TABLE IF EXISTS `salary_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_type`
--

LOCK TABLES `salary_type` WRITE;
/*!40000 ALTER TABLE `salary_type` DISABLE KEYS */;
INSERT INTO `salary_type` VALUES (2,'Porcentaje'),(1,'Salario mensual');
/*!40000 ALTER TABLE `salary_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms`
--

DROP TABLE IF EXISTS `sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_provide_id` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) NOT NULL,
  `message_type` varchar(255) DEFAULT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `message_content` text DEFAULT NULL,
  `message_attachment` varchar(255) DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms`
--

LOCK TABLES `sms` WRITE;
/*!40000 ALTER TABLE `sms` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `medium` varchar(255) NOT NULL,
  `message_type` varchar(255) NOT NULL,
  `attachment_url_default` mediumtext DEFAULT NULL,
  `template_content` mediumtext NOT NULL,
  `template_subject` mediumtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `template`
--

LOCK TABLES `template` WRITE;
/*!40000 ALTER TABLE `template` DISABLE KEYS */;
INSERT INTO `template` VALUES (2,'WhatsApp','PASSWORD_RECOVERY',NULL,'? Hola ${name},\ntu código para recuperar la contraseña de CashTruck es:\n\n${code}\n\n⏳ Vence en ${minutes} minutos y solo se puede usar una vez.\n\n⚠️ Si no solicitaste este cambio, ignora este mensaje y comunícate con el administrador.','Recuperación de contraseña'),(3,'WhatsApp','WELCOME_OWNER',NULL,'? ¡Bienvenido a CashTruck! ??\n\nHola ${name}, ya puedes gestionar tus vehículos y controlar tus costos.\n\n? App: ${appUrl}\n? Usuario: ${email}\n? Contraseña: ${password}\n\n*Primeros pasos:*\n1️⃣ Crea tus conductores ?\n2️⃣ Registra tus vehículos ?\n3️⃣ Crea viajes asignando conductor y vehículo ?️\n4️⃣ Anota los gastos de cada viaje ?\n5️⃣ Registra los mantenimientos ?️\n6️⃣ Consulta tus rutas en el mapa ?\n7️⃣ Revisa tus reportes ?\n\n¿Dudas? Escríbenos por este medio ?','Bienvenido a CashTruck'),(4,'WhatsApp','WELCOME_OWNER_DRIVER',NULL,'? ¡Bienvenido a CashTruck! ??\n\nHola ${name}, ya puedes gestionar tus vehículos y controlar tus costos.\n\n? App: ${appUrl}\n? Usuario: ${email}\n? Contraseña: ${password}\n\n*Primeros pasos:*\n1️⃣ Registra tus vehículos ?\n2️⃣ Crea viajes asignando tu vehículo ?️\n3️⃣ Anota los gastos de cada viaje ?\n4️⃣ Registra los mantenimientos ?️\n5️⃣ Consulta tus rutas en el mapa ?\n6️⃣ Revisa tus reportes ?\n\n¿Dudas? Escríbenos por este medio ?','Bienvenido a CashTruck'),(5,'WhatsApp','SUBSCRIPTION_REMINDER',NULL,'⏳ Tu suscripción a CashTruck está por vencer\n\nHola ${name}, tu suscripción finaliza el *${endDate}*, dentro de ${days} días.\n\nPara no perder el acceso a tus viajes, vehículos, mantenimientos y reportes, comunícate con el administrador y renuévala. ?\n\n¿Necesitas ayuda? Escríbenos por este medio ?','Suscripción por vencer');
/*!40000 ALTER TABLE `template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip`
--

DROP TABLE IF EXISTS `trip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vehicle_id` bigint(20) NOT NULL,
  `driver_id` bigint(20) NOT NULL,
  `number_trip` int(11) NOT NULL,
  `manifest_number` varchar(100) NOT NULL,
  `company` varchar(100) DEFAULT NULL,
  `origin_id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `number_of_days` int(11) NOT NULL,
  `load_type` varchar(100) DEFAULT NULL,
  `freight` decimal(15,2) NOT NULL DEFAULT 0.00,
  `advance_payment` decimal(15,2) NOT NULL DEFAULT 0.00,
  `balance` decimal(15,2) GENERATED ALWAYS AS (`freight` - `advance_payment`) VIRTUAL,
  `paid_balance` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('Planeado','En Curso','Completado','Cancelado','Pendiente') DEFAULT 'Planeado',
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `trip_type` varchar(10) DEFAULT 'CARGADO',
  `return_destination_id` int(11) DEFAULT NULL,
  `current_leg` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `driver_id` (`driver_id`),
  KEY `destination_id` (`destination_id`),
  KEY `idx_trip_vehicle` (`vehicle_id`),
  KEY `idx_trip_route` (`origin_id`,`destination_id`),
  KEY `idx_trip_numbers` (`number_trip`,`manifest_number`),
  KEY `idx_trip_status` (`status`),
  CONSTRAINT `trip_ibfk_1` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`id`),
  CONSTRAINT `trip_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`id`),
  CONSTRAINT `trip_ibfk_3` FOREIGN KEY (`origin_id`) REFERENCES `city` (`id`),
  CONSTRAINT `trip_ibfk_4` FOREIGN KEY (`destination_id`) REFERENCES `city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60545 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip`
--

LOCK TABLES `trip` WRITE;
/*!40000 ALTER TABLE `trip` DISABLE KEYS */;
INSERT INTO `trip` (`id`, `vehicle_id`, `driver_id`, `number_trip`, `manifest_number`, `company`, `origin_id`, `destination_id`, `start_date`, `end_date`, `number_of_days`, `load_type`, `freight`, `advance_payment`, `paid_balance`, `status`, `creation_date`, `update_date`, `trip_type`, `return_destination_id`, `current_leg`) VALUES (60523,4001,4001,1,'0001','',26,2,'2026-04-16 00:14:03','2026-04-16 00:27:48',1,'',1560000.00,900000.00,1,'Completado','2026-04-16 05:14:04','2026-04-16 05:27:49','CARGADO',NULL,NULL),(60524,4002,4002,1,'2600100041104M','Logística Avanzada',26,3,'2026-08-08 19:21:15','2026-08-09 20:03:41',2,'General',5900000.00,4721000.00,1,'Completado','2026-08-10 00:21:16','2026-08-10 01:03:41','CARGADO',NULL,NULL),(60525,4001,4001,2,'Jjj','Ruta Rápida',64,26,'2026-08-09 19:34:46','2026-08-12 12:00:00',3,'Azucar',3500000.00,2500000.00,1,'Completado','2026-08-10 00:34:47','2026-08-13 03:32:30','CARGADO',NULL,NULL),(60526,4001,4001,3,'','',74,75,'2026-08-12 23:11:20','2026-08-12 12:00:00',1,'',0.00,0.00,1,'Completado','2026-08-13 04:11:23','2026-08-13 04:13:56','VACIO',NULL,NULL),(60527,4001,4001,4,'2600100041104M','',61,49,'2026-08-12 23:16:57','2026-08-12 12:00:00',1,'',6700000.00,4555554.00,1,'Completado','2026-08-13 04:17:03','2026-08-13 04:36:32','CARGADO',NULL,NULL),(60528,4001,4001,5,'12','',26,3,'2026-08-12 23:37:30','2026-08-13 12:00:00',1,'Azucar',5600000.00,1200000.00,0,'Pendiente','2026-08-13 04:37:40','2026-08-13 06:41:22','REDONDO',26,NULL),(60529,4001,4001,6,'52345','',76,12,'2026-08-13 16:52:02','2026-08-15 12:00:00',2,'',4500000.00,3450000.00,1,'Completado','2026-08-13 21:52:03','2026-08-16 01:09:51','CARGADO',NULL,NULL),(60530,4001,4001,7,'Test1','Particular',32,46,'2026-08-15 20:13:12','2026-08-15 12:00:00',1,'Papa',1350000.00,650000.00,0,'Pendiente','2026-08-16 01:13:14','2026-08-16 01:20:26','CARGADO',NULL,NULL),(60531,4001,4001,8,'Test 2','Interrapidisimo',3,2,'2026-08-15 20:21:47','2026-08-15 12:00:00',1,'Llantas',2350000.00,900000.00,1,'Completado','2026-08-16 01:21:49','2026-08-16 01:27:50','REDONDO',3,'IDA'),(60532,4001,4001,9,'','',3,37,'2026-08-15 20:36:28','2026-08-15 12:00:00',1,'',0.00,0.00,1,'Completado','2026-08-16 01:36:30','2026-08-16 01:46:35','VACIO',NULL,NULL),(60533,4001,4001,10,'Test 4','',37,32,'2026-08-15 22:04:30','2026-08-15 12:00:00',1,'',960000.00,500000.00,1,'Completado','2026-08-16 03:04:33','2026-08-16 03:05:12','CARGADO',NULL,NULL),(60534,4001,4001,11,'TEst 5','',26,3,'2026-08-15 22:05:51','2026-08-15 12:00:00',1,'',1520000.00,520000.00,0,'Pendiente','2026-08-16 03:05:53','2026-08-16 03:09:33','CARGADO',NULL,NULL),(60535,4001,4001,12,'Test 6','',3,32,'2026-08-15 22:10:23','2026-08-15 12:00:00',1,'',680000.00,250000.00,1,'Completado','2026-08-16 03:10:25','2026-08-16 03:10:52','CARGADO',NULL,NULL),(60536,4001,4001,13,'Test 7','',26,3,'2026-08-15 22:12:16','2026-08-15 12:00:00',1,'',750000.00,350000.00,1,'Completado','2026-08-16 03:12:17','2026-08-16 03:16:51','CARGADO',NULL,NULL),(60537,4001,4001,14,'Test 8','',3,32,'2026-08-15 22:17:20','2026-08-15 12:00:00',1,'',590000.00,290000.00,1,'Completado','2026-08-16 03:17:22','2026-08-16 03:17:42','CARGADO',NULL,NULL),(60538,4001,4001,15,'Test 9','',26,2,'2026-08-15 22:18:34','2026-08-15 12:00:00',1,'',1650000.00,650000.00,1,'Completado','2026-08-16 03:18:36','2026-08-16 03:32:06','CARGADO',NULL,NULL),(60539,4001,4001,16,'','',2,66,'2026-08-15 22:33:19','2026-08-17 12:00:00',2,'',0.00,0.00,1,'Completado','2026-08-16 03:33:21','2026-08-17 19:58:26','VACIO',NULL,NULL),(60540,4003,4004,1,'MF000001','Particular',26,3,'2026-08-17 22:26:09','2026-08-17 12:00:00',1,'Papa',2600000.00,1200000.00,1,'Completado','2026-08-18 03:26:09','2026-08-18 03:44:23','CARGADO',NULL,NULL),(60541,4003,4004,2,'MF00002','Corbeta',3,2,'2026-08-17 22:39:30','2026-08-17 12:00:00',1,'Azucar',6500000.00,3000000.00,1,'Completado','2026-08-18 03:39:30','2026-08-18 03:50:40','REDONDO',3,'IDA'),(60542,4003,4004,3,'MF00003','',3,4,'2026-08-17 22:52:20',NULL,0,'Contenedores',6200000.00,2500000.00,0,'En Curso','2026-08-18 03:52:21','2026-08-18 03:52:21','CARGADO',NULL,NULL),(60543,4004,4005,1,'MF1111','',26,5,'2026-08-17 23:00:05',NULL,0,'',8500000.00,4200000.00,0,'En Curso','2026-08-18 04:00:06','2026-08-18 04:00:06','CARGADO',NULL,NULL),(60544,4001,4001,17,'567','',26,4,'2026-08-21 18:55:31',NULL,0,'',13600000.00,9000000.00,0,'En Curso','2026-08-21 23:55:32','2026-08-21 23:55:32','CARGADO',NULL,NULL);
/*!40000 ALTER TABLE `trip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT current_timestamp(),
  `update_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_role` (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12506 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
INSERT INTO `user_role` VALUES (1,1,1,'2026-03-31 12:29:51','2026-03-31 12:29:51'),(12493,6001,2,'2026-04-16 00:04:49','2026-04-16 00:04:49'),(12494,6002,3,'2026-04-16 00:07:24','2026-04-16 00:07:24'),(12495,6003,2,'2026-08-09 17:07:50','2026-08-09 17:07:50'),(12498,6005,2,'2026-08-16 15:52:45','2026-08-16 15:52:45'),(12499,6006,3,'2026-08-16 15:57:23','2026-08-16 15:57:23'),(12500,6007,3,'2026-08-16 15:58:16','2026-08-16 15:58:16'),(12501,6008,3,'2026-08-16 16:06:30','2026-08-16 16:06:30'),(12502,6009,2,'2026-08-25 12:16:03','2026-08-25 12:16:03');
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` enum('Activo','Inactivo') DEFAULT 'Activo',
  `creation_date` datetime NOT NULL DEFAULT current_timestamp(),
  `update_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6012 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Daniel Castro S.','ingdanielc@hotmail.com','ddd5277dd4a9565a6fbe7e7b7d4d47bdc608363cfbff7ba13d169887ad26deae316e709664d5da9f6c88bfc0a6ac22a70087a4e6f9e6571c579a5ee498729b54','Activo','2026-03-31 12:08:23','2026-03-31 11:10:31'),(6001,'Julián Castro Solis','julian@gmail.com','fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe','Activo','2026-04-16 00:04:49','2026-04-16 00:08:09'),(6002,'Juan Perez ','juan@gmail.com','fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe','Activo','2026-04-16 00:07:24','2026-04-16 00:07:24'),(6003,'John H. Hernandez Ortiz','ing.jhenry@gmail.com','2f0c7da5508b153591fb83b8f0a416828d4a26a927597e0b74db7eda20952ab9372476a2473786695cd766fc69c2ea07d7924d3afdc05c8130291a95b38ee9d5','Activo','2026-08-09 17:07:50','2026-08-09 17:07:50'),(6005,'Test 1','test@gmail.com','b43f1d28a3dbf30070bf1ae7c88ee2784047fc86d7be8620c8510debbd8555b3ef0b96376a4dd494ae0561580274bcf7a3069f5c0beceff63d1237a13d4d72b7','Activo','2026-08-16 15:52:45','2026-08-26 23:22:59'),(6006,'Conductor 1','cond1@gmail.com','fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe','Activo','2026-08-16 15:57:23','2026-08-16 15:57:23'),(6007,'Conductor 2','cond2@gmail.com','fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe','Activo','2026-08-16 15:58:16','2026-08-16 15:58:16'),(6008,'Conductor 3','cond3@gmail.com','fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe','Activo','2026-08-16 16:06:30','2026-08-16 16:06:30'),(6009,'Julián Castro Solis','julianc477@gmail.com','8faae300719a589acd86611032588030449070abd8bfeaa511ef4a2d4a88783d1d080687f3261151f72dbf5db37ddda466c7d7d9242d1f6fd322d45e488f98d8','Activo','2026-08-25 12:16:03','2026-08-25 12:16:03');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle`
--

DROP TABLE IF EXISTS `vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `photo` varchar(120) DEFAULT NULL,
  `plate` varchar(10) NOT NULL,
  `current_driver_id` bigint(20) DEFAULT NULL,
  `vehicle_brand_id` int(11) NOT NULL,
  `model` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `color` varchar(30) DEFAULT NULL,
  `engine_number` varchar(50) DEFAULT NULL,
  `chassis_number` varchar(50) DEFAULT NULL,
  `number_of_axles` varchar(50) DEFAULT NULL,
  `status` enum('Activo','En Mantenimiento','Inactivo','Vendido') DEFAULT 'Activo',
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `plate` (`plate`),
  UNIQUE KEY `current_driver_id` (`current_driver_id`),
  KEY `vehicle_brand_id` (`vehicle_brand_id`),
  KEY `idx_vehicle_driver` (`current_driver_id`),
  KEY `idx_vehicle_status` (`status`),
  CONSTRAINT `vehicle_ibfk_1` FOREIGN KEY (`vehicle_brand_id`) REFERENCES `vehicle_brand` (`id`),
  CONSTRAINT `vehicle_ibfk_2` FOREIGN KEY (`current_driver_id`) REFERENCES `driver` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4006 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
INSERT INTO `vehicle` VALUES (4001,'https://truck.ccsoluciones.com.co/truck/images/vehicle/photo4001.webp','TMH-037',4001,2,'Eagle 4300',2010,'Blanco',NULL,NULL,'2','Activo','2026-04-16 05:11:44','2026-04-16 05:16:03'),(4002,'https://truck.ccsoluciones.com.co/truck/images/vehicle/photo4002.webp','TFU-353',4002,1,'T800',2012,'UVA',NULL,NULL,'2','Activo','2026-08-09 23:47:01','2026-08-09 23:47:02'),(4003,'https://truck.ccsoluciones.com.co/truck/images/vehicle/photo4003.webp','TRG-587',4004,1,'T800',2014,'Blanco','MOT01','CHA02','6','Activo','2026-08-16 21:02:08','2026-08-18 03:16:27'),(4004,'','TGG-341',4005,3,'Test',2019,'Negro','MOT02','CHS33','4','Activo','2026-08-16 21:05:23','2026-08-18 04:00:32'),(4005,'https://truck.ccsoluciones.com.co/truck/images/vehicle/photo4005.webp','WRD-296',4007,6,'Cargo',2006,'Negro',NULL,NULL,'2','Activo','2026-08-19 23:10:42','2026-08-19 23:11:29');
/*!40000 ALTER TABLE `vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_brand`
--

DROP TABLE IF EXISTS `vehicle_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_brand` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_brand`
--

LOCK TABLES `vehicle_brand` WRITE;
/*!40000 ALTER TABLE `vehicle_brand` DISABLE KEYS */;
INSERT INTO `vehicle_brand` VALUES (8,'Chevrolet'),(22,'DAF'),(7,'Dodge'),(13,'Dongfeng'),(6,'Ford'),(10,'Foton'),(3,'Freightliner'),(9,'Hino'),(16,'Hyundai'),(2,'International'),(23,'Iveco'),(11,'JAC'),(12,'JMC'),(1,'Kenworth'),(4,'Mack'),(18,'Mercedes-Benz'),(15,'Mitsubishi Fuso'),(5,'Peterbilt'),(21,'Renault'),(17,'Scania'),(14,'Sinotruk'),(19,'Volkswagen'),(20,'Volvo');
/*!40000 ALTER TABLE `vehicle_brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_owner`
--

DROP TABLE IF EXISTS `vehicle_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_owner` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vehicle_id` bigint(20) NOT NULL,
  `owner_id` bigint(20) NOT NULL,
  `ownership_percentage` decimal(5,2) DEFAULT 100.00,
  `start_date` date DEFAULT curdate(),
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `creation_date` timestamp NULL DEFAULT current_timestamp(),
  `update_date` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vehicle_id` (`vehicle_id`,`owner_id`),
  KEY `idx_owner_history` (`owner_id`),
  KEY `idx_vehicle_history` (`vehicle_id`),
  CONSTRAINT `vehicle_owner_ibfk_1` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`id`),
  CONSTRAINT `vehicle_owner_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `owner` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8236 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_owner`
--

LOCK TABLES `vehicle_owner` WRITE;
/*!40000 ALTER TABLE `vehicle_owner` DISABLE KEYS */;
INSERT INTO `vehicle_owner` VALUES (8231,4001,2001,100.00,'2026-04-16',NULL,1,'2026-04-16 05:11:44','2026-04-16 05:11:44'),(8232,4002,2002,100.00,'2026-08-09',NULL,1,'2026-08-09 23:47:01','2026-08-09 23:47:01'),(8233,4003,2004,100.00,'2026-08-16',NULL,1,'2026-08-16 21:02:08','2026-08-16 21:02:08'),(8234,4004,2004,100.00,'2026-08-16',NULL,1,'2026-08-16 21:05:23','2026-08-16 21:05:23'),(8235,4005,2002,100.00,'2026-08-19',NULL,1,'2026-08-19 23:10:42','2026-08-19 23:10:42');
/*!40000 ALTER TABLE `vehicle_owner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whatsapp`
--

DROP TABLE IF EXISTS `whatsapp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `whatsapp` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_provide_id` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) NOT NULL,
  `message_type` varchar(255) DEFAULT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `message_content` mediumtext DEFAULT NULL,
  `message_attachment` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whatsapp`
--

LOCK TABLES `whatsapp` WRITE;
/*!40000 ALTER TABLE `whatsapp` DISABLE KEYS */;
INSERT INTO `whatsapp` VALUES (1,'SM7214ac883dd9bab9ac14f578e0e2147a','+573147235739','PASSWORD_RECOVERY',1,'Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 693567  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'send','2026-08-26 22:36:56','2026-08-26 23:36:58'),(2,'SM66f32d88cf8122060ce9ca178bfc8be8','+573147235739','PASSWORD_RECOVERY',1,'Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 635528  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'send','2026-08-26 22:49:28','2026-08-26 23:49:30'),(3,'SM7f24c751187da482e87bd9cc83196011','+573147235739','PASSWORD_RECOVERY',1,'Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 982457  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'send','2026-08-26 23:04:15','2026-08-27 00:04:16'),(4,'SM414734f2efc8e8ba5b6b626e339afa22','+573147235739','PASSWORD_RECOVERY',1,'Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 946047  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'send','2026-08-26 23:20:54','2026-08-27 00:20:54'),(5,'SM6373ee80db235550533d20e422fbb0b0','+573147235739','PASSWORD_RECOVERY',1,'Hola Test 1, tu codigo para recuperar la contrasena de CashTruck es: 384381  Vence en 10 minutos y solo se puede usar una vez. Si no solicitaste este cambio, ignora este mensaje y comunicate con el administrador.',NULL,'send','2026-08-26 23:22:31','2026-08-27 00:22:32'),(6,'SMf301b0dbd331e6d39694cc9cdefa1543','+573147235739','WELCOME_OWNER',3,'? ¡Bienvenido a CashTruck! ??\n\nHola Nuevo Owner, ya puedes gestionar tus vehículos y controlar tus costos.\n\n? App: https://truck.ccsoluciones.com.co\n? Usuario: new@gmail.com\n? Contraseña: 12345678\n\n*Primeros pasos:*\n1️⃣ Crea tus conductores ?\n2️⃣ Registra tus vehículos ?\n3️⃣ Crea viajes asignando conductor y vehículo ?️\n4️⃣ Anota los gastos de cada viaje ?\n5️⃣ Registra los mantenimientos ?️\n6️⃣ Consulta tus rutas en el mapa ?\n7️⃣ Revisa tus reportes ?\n\n¿Dudas? Escríbenos por este medio ?',NULL,'send','2026-08-27 00:39:35','2026-08-27 01:39:36'),(7,'SMcfe6bf32c4966343344f7fee782efce3','+573147235739','WELCOME_OWNER_DRIVER',4,'? ¡Bienvenido a CashTruck! ??\n\nHola newTest, ya puedes gestionar tus vehículos y controlar tus costos.\n\n? App: https://truck.ccsoluciones.com.co\n? Usuario: new2@gmail.com\n? Contraseña: 12345678\n\n*Primeros pasos:*\n1️⃣ Registra tus vehículos ?\n2️⃣ Crea viajes asignando tu vehículo ?️\n3️⃣ Anota los gastos de cada viaje ?\n4️⃣ Registra los mantenimientos ?️\n5️⃣ Consulta tus rutas en el mapa ?\n6️⃣ Revisa tus reportes ?\n\n¿Dudas? Escríbenos por este medio ?',NULL,'send','2026-08-27 00:46:21','2026-08-27 01:46:21');
/*!40000 ALTER TABLE `whatsapp` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-27 19:33:38
