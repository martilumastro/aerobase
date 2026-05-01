-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: aerobase
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Aereo`
--

DROP TABLE IF EXISTS `Aereo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Aereo` (
  `id_aereo` int NOT NULL AUTO_INCREMENT,
  `modello` varchar(50) NOT NULL,
  `capacita_passeggeri` int NOT NULL,
  `codice_vettore` char(3) NOT NULL,
  PRIMARY KEY (`id_aereo`),
  KEY `fk_aereo_compagnia` (`codice_vettore`),
  CONSTRAINT `fk_aereo_compagnia` FOREIGN KEY (`codice_vettore`) REFERENCES `Compagnia_Aerea` (`codice_vettore`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Aereo_chk_1` CHECK ((`capacita_passeggeri` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Aereo`
--

LOCK TABLES `Aereo` WRITE;
/*!40000 ALTER TABLE `Aereo` DISABLE KEYS */;
INSERT INTO `Aereo` VALUES (1,'Airbus A320',180,'AZA'),(2,'Boeing 737-800',189,'RYR'),(3,'Airbus A319',156,'EZY');
/*!40000 ALTER TABLE `Aereo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Aeroporto`
--

DROP TABLE IF EXISTS `Aeroporto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Aeroporto` (
  `codice_iata` char(3) NOT NULL,
  `nome_aeroporto` varchar(100) NOT NULL,
  `citta` varchar(80) NOT NULL,
  `nazione` varchar(80) NOT NULL,
  `codice_icao` char(4) DEFAULT NULL,
  PRIMARY KEY (`codice_iata`),
  UNIQUE KEY `codice_icao` (`codice_icao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Aeroporto`
--

LOCK TABLES `Aeroporto` WRITE;
/*!40000 ALTER TABLE `Aeroporto` DISABLE KEYS */;
INSERT INTO `Aeroporto` VALUES ('AMS','Amsterdam Schiphol','Amsterdam','Paesi Bassi','EHAM'),('BCN','Barcellona El Prat','Barcellona','Spagna','LEBL'),('BER','Berlino Brandenburg','Berlino','Germania','EDDB'),('BGY','Bergamo Orio al Serio','Milano','Italia','LIME'),('BLQ','Bologna Guglielmo Marconi','Bologna','Italia','LIPE'),('CDG','Parigi Charles de Gaulle','Parigi','Francia','LFPG'),('CIA','Roma Ciampino','Roma','Italia','LIRA'),('CTA','Catania Fontanarossa','Catania','Italia','LICC'),('FCO','Roma Fiumicino','Roma','Italia','LIRF'),('LGW','Londra Gatwick','Londra','Regno Unito','EGKK'),('LHR','Londra Heathrow','Londra','Regno Unito','EGLL'),('LIN','Milano Linate','Milano','Italia','LIML'),('MAD','Madrid Barajas','Madrid','Spagna','LEMD'),('MXP','Milano Malpensa','Milano','Italia','LIMC'),('NAP','Napoli Capodichino','Napoli','Italia','LIRN'),('ORY','Parigi Orly','Parigi','Francia','LFPO'),('PMO','Palermo Falcone Borsellino','Palermo','Italia','LICJ'),('TRN','Torino Caselle','Torino','Italia','LIMF'),('VCE','Venezia Marco Polo','Venezia','Italia','LIPZ');
/*!40000 ALTER TABLE `Aeroporto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Bagaglio`
--

DROP TABLE IF EXISTS `Bagaglio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Bagaglio` (
  `id_bagaglio` int NOT NULL AUTO_INCREMENT,
  `peso_kg` decimal(5,2) NOT NULL,
  `tipo` enum('cabina','stiva','speciale') NOT NULL,
  `username_passeggero` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `codice_operatore` varchar(20) NOT NULL,
  PRIMARY KEY (`id_bagaglio`),
  KEY `fk_bag_prenotazione` (`username_passeggero`,`id_volo`),
  KEY `fk_bag_operatore` (`codice_operatore`),
  CONSTRAINT `fk_bag_operatore` FOREIGN KEY (`codice_operatore`) REFERENCES `Operatore` (`codice_operatore`) ON DELETE CASCADE,
  CONSTRAINT `fk_bag_prenotazione` FOREIGN KEY (`username_passeggero`, `id_volo`) REFERENCES `Prenotazione` (`username_passeggero`, `id_volo`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Bagaglio`
--

LOCK TABLES `Bagaglio` WRITE;
/*!40000 ALTER TABLE `Bagaglio` DISABLE KEYS */;
/*!40000 ALTER TABLE `Bagaglio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Compagnia_Aerea`
--

DROP TABLE IF EXISTS `Compagnia_Aerea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Compagnia_Aerea` (
  `codice_vettore` char(3) NOT NULL,
  `nome_compagnia` varchar(50) NOT NULL,
  `nazione` varchar(50) NOT NULL,
  PRIMARY KEY (`codice_vettore`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Compagnia_Aerea`
--

LOCK TABLES `Compagnia_Aerea` WRITE;
/*!40000 ALTER TABLE `Compagnia_Aerea` DISABLE KEYS */;
INSERT INTO `Compagnia_Aerea` VALUES ('AZA','ITA Airways','Italia'),('EZY','easyJet','Regno Unito'),('RYR','Ryanair','Irlanda');
/*!40000 ALTER TABLE `Compagnia_Aerea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Gate`
--

DROP TABLE IF EXISTS `Gate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Gate` (
  `codice_gate` varchar(10) NOT NULL,
  `terminal` varchar(10) NOT NULL,
  PRIMARY KEY (`codice_gate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Gate`
--

LOCK TABLES `Gate` WRITE;
/*!40000 ALTER TABLE `Gate` DISABLE KEYS */;
INSERT INTO `Gate` VALUES ('A12','T1'),('B04','T1'),('C18','T2');
/*!40000 ALTER TABLE `Gate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Gestione_Volo`
--

DROP TABLE IF EXISTS `Gestione_Volo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Gestione_Volo` (
  `codice_operatore` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `timestamp_modifica` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_operazione` enum('modifica_stato','modifica_gate','modifica_aereo') NOT NULL,
  PRIMARY KEY (`codice_operatore`,`id_volo`),
  KEY `id_volo` (`id_volo`),
  CONSTRAINT `Gestione_Volo_ibfk_1` FOREIGN KEY (`codice_operatore`) REFERENCES `Operatore` (`codice_operatore`) ON DELETE CASCADE,
  CONSTRAINT `Gestione_Volo_ibfk_2` FOREIGN KEY (`id_volo`) REFERENCES `Volo` (`id_volo`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Gestione_Volo`
--

LOCK TABLES `Gestione_Volo` WRITE;
/*!40000 ALTER TABLE `Gestione_Volo` DISABLE KEYS */;
/*!40000 ALTER TABLE `Gestione_Volo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Operatore`
--

DROP TABLE IF EXISTS `Operatore`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Operatore` (
  `codice_operatore` varchar(20) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `cognome` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `cellulare` varchar(20) NOT NULL,
  `ruolo` enum('admin','operatore_voli','operatore_bagagli') NOT NULL,
  `id_user` int DEFAULT NULL,
  PRIMARY KEY (`codice_operatore`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `cellulare` (`cellulare`),
  UNIQUE KEY `id_user` (`id_user`),
  CONSTRAINT `fk_operatore_user` FOREIGN KEY (`id_user`) REFERENCES `auth_user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Operatore`
--

LOCK TABLES `Operatore` WRITE;
/*!40000 ALTER TABLE `Operatore` DISABLE KEYS */;
/*!40000 ALTER TABLE `Operatore` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Passeggero`
--

DROP TABLE IF EXISTS `Passeggero`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Passeggero` (
  `username` varchar(20) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `cognome` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `numero_passaporto` varchar(20) DEFAULT NULL,
  `cellulare` varchar(20) DEFAULT NULL,
  `nazionalita` varchar(50) NOT NULL,
  `id_user` int DEFAULT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `numero_passaporto` (`numero_passaporto`),
  UNIQUE KEY `cellulare` (`cellulare`),
  UNIQUE KEY `id_user` (`id_user`),
  CONSTRAINT `fk_passeggero_user` FOREIGN KEY (`id_user`) REFERENCES `auth_user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Passeggero`
--

LOCK TABLES `Passeggero` WRITE;
/*!40000 ALTER TABLE `Passeggero` DISABLE KEYS */;
INSERT INTO `Passeggero` VALUES ('mario1','Mario','Rossi','mariorossi@mail.com',NULL,NULL,'Italiana',1);
/*!40000 ALTER TABLE `Passeggero` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Prenotazione`
--

DROP TABLE IF EXISTS `Prenotazione`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Prenotazione` (
  `id_prenotazione` int NOT NULL AUTO_INCREMENT,
  `username_passeggero` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `data_acquisto` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `posto` char(5) NOT NULL,
  `classe` enum('economy','business','first') NOT NULL,
  PRIMARY KEY (`username_passeggero`,`id_volo`),
  UNIQUE KEY `id_prenotazione` (`id_prenotazione`),
  KEY `fk_pren_volo` (`id_volo`),
  CONSTRAINT `fk_pren_passeggero` FOREIGN KEY (`username_passeggero`) REFERENCES `Passeggero` (`username`) ON DELETE CASCADE,
  CONSTRAINT `fk_pren_volo` FOREIGN KEY (`id_volo`) REFERENCES `Volo` (`id_volo`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Prenotazione`
--

LOCK TABLES `Prenotazione` WRITE;
/*!40000 ALTER TABLE `Prenotazione` DISABLE KEYS */;
/*!40000 ALTER TABLE `Prenotazione` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Volo`
--

DROP TABLE IF EXISTS `Volo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Volo` (
  `id_volo` int NOT NULL AUTO_INCREMENT,
  `numero_volo` varchar(10) NOT NULL,
  `orario_partenza` datetime NOT NULL,
  `orario_arrivo` datetime NOT NULL,
  `partenza` char(3) NOT NULL,
  `destinazione` char(3) NOT NULL,
  `id_aereo` int NOT NULL,
  `codice_gate` varchar(10) DEFAULT NULL,
  `stato` enum('in_orario','in_ritardo','imbarco','partito','cancellato') NOT NULL DEFAULT 'in_orario',
  `ritardo_minuti` int NOT NULL DEFAULT '0',
  `prezzo` decimal(8,2) NOT NULL,
  PRIMARY KEY (`id_volo`),
  UNIQUE KEY `numero_volo` (`numero_volo`),
  KEY `fk_volo_aereo` (`id_aereo`),
  KEY `fk_volo_gate` (`codice_gate`),
  KEY `fk_volo_destinazione` (`destinazione`),
  KEY `fk_volo_partenza` (`partenza`),
  CONSTRAINT `fk_volo_aereo` FOREIGN KEY (`id_aereo`) REFERENCES `Aereo` (`id_aereo`) ON DELETE CASCADE,
  CONSTRAINT `fk_volo_destinazione` FOREIGN KEY (`destinazione`) REFERENCES `Aeroporto` (`codice_iata`) ON UPDATE CASCADE,
  CONSTRAINT `fk_volo_gate` FOREIGN KEY (`codice_gate`) REFERENCES `Gate` (`codice_gate`) ON DELETE SET NULL,
  CONSTRAINT `fk_volo_partenza` FOREIGN KEY (`partenza`) REFERENCES `Aeroporto` (`codice_iata`) ON UPDATE CASCADE,
  CONSTRAINT `chk_ritardo_minuti` CHECK ((`ritardo_minuti` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Volo`
--

LOCK TABLES `Volo` WRITE;
/*!40000 ALTER TABLE `Volo` DISABLE KEYS */;
INSERT INTO `Volo` VALUES (1,'AZ1001','2026-05-03 23:26:47','2026-05-04 00:41:47','FCO','MXP',1,NULL,'in_orario',0,89.90),(2,'AZ1002','2026-05-04 23:26:47','2026-05-05 00:36:47','FCO','LIN',1,NULL,'in_orario',0,95.50),(3,'RY2201','2026-05-05 23:26:47','2026-05-06 01:06:47','CIA','BCN',2,NULL,'in_orario',0,64.99),(4,'EZY3301','2026-05-06 23:26:47','2026-05-07 01:11:47','MXP','CDG',3,NULL,'in_orario',0,78.00),(5,'AZ4401','2026-05-07 23:26:47','2026-05-08 01:26:47','FCO','AMS',1,NULL,'in_orario',0,122.00);
/*!40000 ALTER TABLE `Volo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',3,'add_permission'),(6,'Can change permission',3,'change_permission'),(7,'Can delete permission',3,'delete_permission'),(8,'Can view permission',3,'view_permission'),(9,'Can add group',2,'add_group'),(10,'Can change group',2,'change_group'),(11,'Can delete group',2,'delete_group'),(12,'Can view group',2,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$1200000$QAGdVuteIwyKIzewT9bvzJ$njaZzWrbp6I1pmzMn/Y2OwApFInGmC7X6WGiuLvfa1I=','2026-05-01 21:00:21.605577',0,'mario1','','','mariorossi@mail.com',0,1,'2026-05-01 20:50:00.204224');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(2,'auth','group'),(3,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-04-30 23:35:34.886714'),(2,'auth','0001_initial','2026-04-30 23:35:36.223425'),(3,'admin','0001_initial','2026-04-30 23:35:36.524106'),(4,'admin','0002_logentry_remove_auto_add','2026-04-30 23:35:36.540171'),(5,'admin','0003_logentry_add_action_flag_choices','2026-04-30 23:35:36.580529'),(6,'contenttypes','0002_remove_content_type_name','2026-04-30 23:35:36.784614'),(7,'auth','0002_alter_permission_name_max_length','2026-04-30 23:35:36.925390'),(8,'auth','0003_alter_user_email_max_length','2026-04-30 23:35:36.967120'),(9,'auth','0004_alter_user_username_opts','2026-04-30 23:35:36.980927'),(10,'auth','0005_alter_user_last_login_null','2026-04-30 23:35:37.095264'),(11,'auth','0006_require_contenttypes_0002','2026-04-30 23:35:37.101776'),(12,'auth','0007_alter_validators_add_error_messages','2026-04-30 23:35:37.116286'),(13,'auth','0008_alter_user_username_max_length','2026-04-30 23:35:37.248183'),(14,'auth','0009_alter_user_last_name_max_length','2026-04-30 23:35:37.389889'),(15,'auth','0010_alter_group_name_max_length','2026-04-30 23:35:37.429594'),(16,'auth','0011_update_proxy_permissions','2026-04-30 23:35:37.444384'),(17,'auth','0012_alter_user_first_name_max_length','2026-04-30 23:35:37.583335'),(18,'sessions','0001_initial','2026-04-30 23:35:37.673859');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('qbzs9r63xcybxu7ef99pu6f3g0qmw356','.eJxVjEEOwiAQRe_C2hCgU3Bcuu8ZmhkYpGpoUtqV8e7apAvd_vfef6mRtrWMW5NlnJK6KKtOvxtTfEjdQbpTvc06znVdJta7og_a9DAneV4P9--gUCvfOvYWPSTK1nDnIPc9hsDggMQAn6HzAQ1k9AbEo-04oHDIFLNgsN6p9wfDBDcn:1wIuyD:GVlXqyyP4Y3gc983h1WSrrhOvXysqerR0wy5qoxbtWA','2026-05-15 21:00:21.619934');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-01 23:27:59
