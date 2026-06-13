-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: aerobase
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.2

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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Aereo`
--

LOCK TABLES `Aereo` WRITE;
/*!40000 ALTER TABLE `Aereo` DISABLE KEYS */;
INSERT INTO `Aereo` VALUES (1,'Airbus A320',180,'AZA'),(2,'Boeing 737-800',189,'RYR'),(3,'Airbus A319',156,'EZY'),(10,'Airbus A321',220,'DLH'),(11,'Airbus A220',148,'AFR');
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
INSERT INTO `Aeroporto` VALUES ('AMS','Amsterdam Schiphol','Amsterdam','Paesi Bassi','EHAM'),('BCN','Barcellona El Prat','Barcellona','Spagna','LEBL'),('BER','Berlino Brandenburg','Berlino','Germania','EDDB'),('BGY','Bergamo Orio al Serio','Milano','Italia','LIME'),('BLQ','Bologna Guglielmo Marconi','Bologna','Italia','LIPE'),('CDG','Parigi Charles de Gaulle','Parigi','Francia','LFPG'),('CIA','Roma Ciampino','Roma','Italia','LIRA'),('CTA','Catania Fontanarossa','Catania','Italia','LICC'),('FCO','Roma Fiumicino','Roma','Italia','LIRF'),('LGW','Londra Gatwick','Londra','Regno Unito','EGKK'),('LHR','Londra Heathrow','Londra','Regno Unito','EGLL'),('LIN','Milano Linate','Milano','Italia','LIML'),('LIS','Lisbona Humberto Delgado','Lisbona','Portogallo','LPPT'),('MAD','Madrid Barajas','Madrid','Spagna','LEMD'),('MXP','Milano Malpensa','Milano','Italia','LIMC'),('NAP','Napoli Capodichino','Napoli','Italia','LIRN'),('ORY','Parigi Orly','Parigi','Francia','LFPO'),('PMO','Palermo Falcone Borsellino','Palermo','Italia','LICJ'),('TRN','Torino Caselle','Torino','Italia','LIMF'),('VCE','Venezia Marco Polo','Venezia','Italia','LIPZ'),('ZRH','Zurigo Kloten','Zurigo','Svizzera','LSZH');
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
  `peso_kg` decimal(5,2) DEFAULT NULL,
  `tipo` enum('cabina','stiva','speciale') NOT NULL,
  `username_passeggero` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `codice_operatore` varchar(20) DEFAULT NULL,
  `stato` enum('prenotato','imbarcato','consegnato','smarrito','ritrovato') NOT NULL DEFAULT 'prenotato',
  `data_aggiornamento` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_bagaglio`),
  KEY `fk_bag_prenotazione` (`username_passeggero`,`id_volo`),
  KEY `fk_bag_operatore` (`codice_operatore`),
  KEY `idx_bagaglio_stato` (`stato`),
  CONSTRAINT `fk_bag_operatore` FOREIGN KEY (`codice_operatore`) REFERENCES `Operatore` (`codice_operatore`) ON DELETE SET NULL,
  CONSTRAINT `fk_bag_prenotazione` FOREIGN KEY (`username_passeggero`, `id_volo`) REFERENCES `Prenotazione` (`username_passeggero`, `id_volo`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Bagaglio`
--

LOCK TABLES `Bagaglio` WRITE;
/*!40000 ALTER TABLE `Bagaglio` DISABLE KEYS */;
INSERT INTO `Bagaglio` VALUES (70,8.50,'cabina','giulia1',100,'BAG-FCO','prenotato','2026-06-13 14:59:58'),(71,21.30,'stiva','luca1',101,'BAG-FCO','imbarcato','2026-06-13 14:59:58');
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
INSERT INTO `Compagnia_Aerea` VALUES ('AFR','Air France','Francia'),('AZA','ITA Airways','Italia'),('DLH','Lufthansa','Germania'),('EZY','easyJet','Regno Unito'),('RYR','Ryanair','Irlanda');
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
  `codice_aeroporto` char(3) NOT NULL,
  `terminal` varchar(10) NOT NULL,
  `internazionale` tinyint(1) NOT NULL DEFAULT '0',
  `area_imbarco` varchar(20) NOT NULL DEFAULT 'Area A',
  PRIMARY KEY (`codice_gate`),
  KEY `idx_gate_aeroporto` (`codice_aeroporto`),
  CONSTRAINT `fk_gate_aeroporto` FOREIGN KEY (`codice_aeroporto`) REFERENCES `Aeroporto` (`codice_iata`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Gate`
--

LOCK TABLES `Gate` WRITE;
/*!40000 ALTER TABLE `Gate` DISABLE KEYS */;
INSERT INTO `Gate` VALUES ('FCO-A10','FCO','T1',0,'Area A'),('FCO-E22','FCO','T3',1,'Area E');
/*!40000 ALTER TABLE `Gate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Gestione_Volo`
--

DROP TABLE IF EXISTS `Gestione_Volo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Gestione_Volo` (
  `id_gestione` int NOT NULL AUTO_INCREMENT,
  `codice_operatore` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `timestamp_modifica` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_operazione` enum('modifica_stato','modifica_gate','modifica_aereo') NOT NULL,
  PRIMARY KEY (`id_gestione`),
  KEY `id_volo` (`id_volo`),
  KEY `idx_gestione_operatore_volo` (`codice_operatore`,`id_volo`),
  CONSTRAINT `Gestione_Volo_ibfk_1` FOREIGN KEY (`codice_operatore`) REFERENCES `Operatore` (`codice_operatore`) ON DELETE CASCADE,
  CONSTRAINT `Gestione_Volo_ibfk_2` FOREIGN KEY (`id_volo`) REFERENCES `Volo` (`id_volo`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Gestione_Volo`
--

LOCK TABLES `Gestione_Volo` WRITE;
/*!40000 ALTER TABLE `Gestione_Volo` DISABLE KEYS */;
INSERT INTO `Gestione_Volo` VALUES (90,'VOL-FCO',100,'2026-06-13 17:00:20','modifica_gate'),(91,'VOL-ZRH',101,'2026-06-13 17:00:20','modifica_stato');
/*!40000 ALTER TABLE `Gestione_Volo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Metodo_Pagamento`
--

DROP TABLE IF EXISTS `Metodo_Pagamento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Metodo_Pagamento` (
  `id_metodo` int NOT NULL AUTO_INCREMENT,
  `username_passeggero` varchar(20) NOT NULL,
  `intestatario` varchar(255) NOT NULL,
  `ultime_cifre` char(4) NOT NULL,
  `mese_scadenza` int NOT NULL,
  `anno_scadenza` int NOT NULL,
  `token_pagamento` varchar(255) NOT NULL,
  `data_registrazione` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_metodo`),
  KEY `fk_pagamento_passeggero` (`username_passeggero`),
  CONSTRAINT `fk_pagamento_passeggero` FOREIGN KEY (`username_passeggero`) REFERENCES `Passeggero` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_anno_scadenza` CHECK ((`anno_scadenza` >= 2026)),
  CONSTRAINT `chk_mese_scadenza` CHECK ((`mese_scadenza` between 1 and 12))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Metodo_Pagamento`
--

LOCK TABLES `Metodo_Pagamento` WRITE;
/*!40000 ALTER TABLE `Metodo_Pagamento` DISABLE KEYS */;
INSERT INTO `Metodo_Pagamento` VALUES (30,'giulia1','Giulia Bianchi','4242',12,2028,'tok_giulia_001','2026-06-13 15:00:09'),(31,'luca1','Luca Verdi','1881',5,2029,'tok_luca_001','2026-06-13 15:00:09');
/*!40000 ALTER TABLE `Metodo_Pagamento` ENABLE KEYS */;
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
  `codice_aeroporto` char(3) NOT NULL,
  `id_user` int NOT NULL,
  PRIMARY KEY (`codice_operatore`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `cellulare` (`cellulare`),
  UNIQUE KEY `id_user` (`id_user`),
  KEY `fk_operatore_aeroporto` (`codice_aeroporto`),
  CONSTRAINT `fk_operatore_aeroporto` FOREIGN KEY (`codice_aeroporto`) REFERENCES `Aeroporto` (`codice_iata`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_operatore_user` FOREIGN KEY (`id_user`) REFERENCES `auth_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Operatore`
--

LOCK TABLES `Operatore` WRITE;
/*!40000 ALTER TABLE `Operatore` DISABLE KEYS */;
INSERT INTO `Operatore` VALUES ('ADM-DEMO','Admin','Demo','admin.demo@aerobase.it','3450000101','admin','FCO',25),('ADM-FCO','Admin','Fiumicino','admin.fco@aerobase.it','3450000001','admin','FCO',2),('BAG-DEMO','Operatore','Bagagli Demo','bagagli.demo@aerobase.it','3000000103','operatore_bagagli','FCO',27),('BAG-FCO','Operatore','Bagagli','bagagli.fco@aerobase.it','3000000003','operatore_bagagli','FCO',4),('VOL-DEMO','Operatore','Voli Demo','voli.demo@aerobase.it','3000000102','operatore_voli','FCO',26),('VOL-FCO','Operatore','Voli','voli.fco@aerobase.it','3000000002','operatore_voli','FCO',3),('VOL-ZRH','Elena','Marini','operatore.zrh@aerobase.it','3009998888','operatore_voli','FCO',22);
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
  `id_user` int NOT NULL,
  `codice_carta_identita` varchar(30) NOT NULL,
  `codice_fiscale` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `id_user` (`id_user`),
  UNIQUE KEY `numero_passaporto` (`numero_passaporto`),
  UNIQUE KEY `cellulare` (`cellulare`),
  UNIQUE KEY `codice_fiscale` (`codice_fiscale`),
  CONSTRAINT `fk_passeggero_user` FOREIGN KEY (`id_user`) REFERENCES `auth_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Passeggero`
--

LOCK TABLES `Passeggero` WRITE;
/*!40000 ALTER TABLE `Passeggero` DISABLE KEYS */;
INSERT INTO `Passeggero` VALUES ('cliente_demo','Cliente','Demo','cliente.demo@mail.com','YA0000000','3330000111','Italiana',24,'CI0000000','DMCcln00a00h501z'),('giulia1','Giulia','Bianchi','giulia.bianchi@mail.com','YA1234567','3331112222','Italiana',20,'CA1234567','BNCGLI01A41H501Z'),('luca1','Luca','Verdi','luca.verdi@mail.com','YA7654321','3334445555','Italiana',21,'CA7654321','VRDLCU99B12F205X');
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
  `stato_pagamento` enum('non_pagato','pagato','rimborsato') DEFAULT 'non_pagato',
  PRIMARY KEY (`username_passeggero`,`id_volo`),
  UNIQUE KEY `id_prenotazione` (`id_prenotazione`),
  KEY `fk_pren_volo` (`id_volo`),
  KEY `idx_prenotazione_data_acquisto` (`data_acquisto`),
  CONSTRAINT `fk_pren_passeggero` FOREIGN KEY (`username_passeggero`) REFERENCES `Passeggero` (`username`) ON DELETE CASCADE,
  CONSTRAINT `fk_pren_volo` FOREIGN KEY (`id_volo`) REFERENCES `Volo` (`id_volo`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Prenotazione`
--

LOCK TABLES `Prenotazione` WRITE;
/*!40000 ALTER TABLE `Prenotazione` DISABLE KEYS */;
INSERT INTO `Prenotazione` VALUES (50,'giulia1',100,'2026-06-13 14:59:33','12A','economy','pagato'),(51,'luca1',101,'2026-06-13 14:59:33','4C','business','non_pagato');
/*!40000 ALTER TABLE `Prenotazione` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Transazione`
--

DROP TABLE IF EXISTS `Transazione`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Transazione` (
  `id_transazione` int NOT NULL AUTO_INCREMENT,
  `username_passeggero` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `importo` decimal(8,2) NOT NULL,
  `id_transazione_esterno` varchar(100) NOT NULL,
  `metodo_usato` varchar(50) DEFAULT NULL,
  `stato` enum('in_attesa','completato','fallito') DEFAULT 'in_attesa',
  `data_pagamento` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_transazione`),
  UNIQUE KEY `id_transazione_esterno` (`id_transazione_esterno`),
  KEY `fk_transazione_prenotazione` (`username_passeggero`,`id_volo`),
  CONSTRAINT `fk_transazione_prenotazione` FOREIGN KEY (`username_passeggero`, `id_volo`) REFERENCES `Prenotazione` (`username_passeggero`, `id_volo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Transazione`
--

LOCK TABLES `Transazione` WRITE;
/*!40000 ALTER TABLE `Transazione` DISABLE KEYS */;
/*!40000 ALTER TABLE `Transazione` ENABLE KEYS */;
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
  `prezzo` decimal(8,2) NOT NULL DEFAULT '0.00',
  `tipo_volo` enum('nazionale','internazionale') NOT NULL DEFAULT 'nazionale',
  PRIMARY KEY (`id_volo`),
  UNIQUE KEY `numero_volo` (`numero_volo`),
  KEY `fk_volo_aereo` (`id_aereo`),
  KEY `fk_volo_gate` (`codice_gate`),
  KEY `fk_volo_destinazione` (`destinazione`),
  KEY `fk_volo_partenza` (`partenza`),
  KEY `idx_volo_orario_partenza` (`orario_partenza`),
  KEY `idx_volo_stato` (`stato`),
  CONSTRAINT `fk_volo_aereo` FOREIGN KEY (`id_aereo`) REFERENCES `Aereo` (`id_aereo`) ON DELETE CASCADE,
  CONSTRAINT `fk_volo_destinazione` FOREIGN KEY (`destinazione`) REFERENCES `Aeroporto` (`codice_iata`),
  CONSTRAINT `fk_volo_gate` FOREIGN KEY (`codice_gate`) REFERENCES `Gate` (`codice_gate`) ON DELETE SET NULL,
  CONSTRAINT `fk_volo_partenza` FOREIGN KEY (`partenza`) REFERENCES `Aeroporto` (`codice_iata`),
  CONSTRAINT `chk_orari_volo` CHECK ((`orario_arrivo` > `orario_partenza`)),
  CONSTRAINT `chk_ritardo_minuti` CHECK ((`ritardo_minuti` >= 0)),
  CONSTRAINT `chk_rotta` CHECK ((`partenza` <> `destinazione`))
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Volo`
--

LOCK TABLES `Volo` WRITE;
/*!40000 ALTER TABLE `Volo` DISABLE KEYS */;
INSERT INTO `Volo` VALUES (100,'DLH100','2026-07-01 09:00:00','2026-07-01 10:45:00','FCO','ZRH',10,'FCO-E22','in_orario',0,129.90,'internazionale'),(101,'AFR220','2026-07-02 14:30:00','2026-07-02 17:05:00','FCO','LIS',11,'FCO-E22','in_ritardo',25,159.50,'internazionale'),(102,'AZA501','2026-07-03 08:15:00','2026-07-03 09:25:00','FCO','LIN',1,'FCO-A10','in_orario',0,89.00,'nazionale');
/*!40000 ALTER TABLE `Volo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Volo_Internazionale`
--

DROP TABLE IF EXISTS `Volo_Internazionale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Volo_Internazionale` (
  `id_volo` int NOT NULL,
  `richiede_passaporto` tinyint(1) NOT NULL DEFAULT '1',
  `tipo_visto` varchar(50) DEFAULT NULL,
  `validita_minima_passaporto_mesi` tinyint unsigned NOT NULL DEFAULT '6',
  `fuso_orario_destinazione` varchar(50) DEFAULT NULL,
  `certificazioni_sanitarie_richieste` text,
  PRIMARY KEY (`id_volo`),
  CONSTRAINT `fk_volo_internazionale_volo` FOREIGN KEY (`id_volo`) REFERENCES `Volo` (`id_volo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Volo_Internazionale`
--

LOCK TABLES `Volo_Internazionale` WRITE;
/*!40000 ALTER TABLE `Volo_Internazionale` DISABLE KEYS */;
INSERT INTO `Volo_Internazionale` VALUES (100,1,NULL,6,'Europe/Zurich',NULL),(101,1,NULL,6,'Europe/Lisbon',NULL);
/*!40000 ALTER TABLE `Volo_Internazionale` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_vi_before_insert` BEFORE INSERT ON `Volo_Internazionale` FOR EACH ROW BEGIN
  IF EXISTS (
    SELECT 1 FROM Volo_Nazionale
    WHERE id_volo = NEW.id_volo
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Il volo e gia nazionale';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Volo
    WHERE id_volo = NEW.id_volo
      AND tipo_volo = 'internazionale'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Il tipo_volo deve essere internazionale';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Volo_Nazionale`
--

DROP TABLE IF EXISTS `Volo_Nazionale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Volo_Nazionale` (
  `id_volo` int NOT NULL,
  `agevolazioni_statali` tinyint(1) NOT NULL DEFAULT '0',
  `tipo_agevolazione` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_volo`),
  CONSTRAINT `fk_volo_nazionale_volo` FOREIGN KEY (`id_volo`) REFERENCES `Volo` (`id_volo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Volo_Nazionale`
--

LOCK TABLES `Volo_Nazionale` WRITE;
/*!40000 ALTER TABLE `Volo_Nazionale` DISABLE KEYS */;
INSERT INTO `Volo_Nazionale` VALUES (102,1,'Residenti e studenti');
/*!40000 ALTER TABLE `Volo_Nazionale` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_vn_before_insert` BEFORE INSERT ON `Volo_Nazionale` FOR EACH ROW BEGIN
  IF EXISTS (
    SELECT 1 FROM Volo_Internazionale
    WHERE id_volo = NEW.id_volo
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Il volo e gia internazionale';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Volo
    WHERE id_volo = NEW.id_volo
      AND tipo_volo = 'nazionale'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Il tipo_volo deve essere nazionale';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$1200000$QAGdVuteIwyKIzewT9bvzJ$njaZzWrbp6I1pmzMn/Y2OwApFInGmC7X6WGiuLvfa1I=','2026-05-11 07:28:12.790044',0,'mario1','','','mariorossi@mail.com',0,1,'2026-05-01 20:50:00.204224'),(2,'pbkdf2_sha256$1200000$dUSWgta7VPdCfs12F0x1kK$Jd2zrErvAVshpd1os8ht3PJb9sVO8psTeESvKo1zRyw=','2026-05-11 07:28:25.546987',0,'admin_fco','','','admin.fco@aerobase.it',0,1,'2026-05-02 12:55:36.102156'),(3,'pbkdf2_sha256$1200000$Od97OXVozVF33uZjTZx55Y$T3Vrdr0REWnGr8r9RmtMhvxznAIY3ZyYJJ3HLi7h72s=',NULL,0,'voli_fco','','','voli.fco@aerobase.it',0,1,'2026-05-02 12:55:44.430646'),(4,'pbkdf2_sha256$1200000$HP1HRCpRQ1o1qo0jHPU5Ex$7JG/Qm3V/PO6UuTvzQRs8yAATZp0xQXODYQADLweffA=','2026-05-08 12:29:18.187099',0,'bagagli_fco','','','bagagli.fco@aerobase.it',0,1,'2026-05-02 12:55:54.313013'),(20,'!',NULL,0,'giulia1','','','giulia.bianchi@mail.com',0,1,'2026-06-13 16:59:05.000000'),(21,'!',NULL,0,'luca1','','','luca.verdi@mail.com',0,1,'2026-06-13 16:59:05.000000'),(22,'!',NULL,0,'op_zrh','','','operatore.zrh@aerobase.it',1,1,'2026-06-13 16:59:05.000000'),(24,'pbkdf2_sha256$1200000$wLzD3q6cLFbGObLui0BiVd$xliWPLByKCMyQ3Ay2b/UNFugHd69s/hanNHjuj1gZJw=','2026-06-13 17:35:38.496785',0,'cliente_demo','','','cliente.demo@mail.com',0,1,'2026-06-13 17:29:30.770308'),(25,'pbkdf2_sha256$1200000$0dfmRgc7mD6LTvMovOxkyW$sB6ca3pwHNpi2VIuKMZdYJ2dMn69b71I4YjdN5sjueY=',NULL,0,'admin_demo','','','admin.demo@aerobase.it',0,1,'2026-06-13 17:38:01.341822'),(26,'pbkdf2_sha256$1200000$n1LPdOMAWUflEkUW2cWdxa$nzYgvK/ihYRuzoZJmZnSKmHho/HN4cN+H+sUcIbp+dM=',NULL,0,'voli_demo','','','voli.demo@aerobase.it',0,1,'2026-06-13 17:38:01.954793'),(27,'pbkdf2_sha256$1200000$kWd9P3QdkSG9JGHHznkk2W$UmZpqGwWc0igX9RraBFj/HdnBACNtBPC5Y143WW1HfM=',NULL,0,'bagagli_demo','','','bagagli.demo@aerobase.it',0,1,'2026-06-13 17:38:02.524327');
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
INSERT INTO `django_session` VALUES ('a9okzj75mfmhdi988e658e4eqqrcss2i','.eJxVjEEOwiAQRe_C2hCgU3Bcuu8ZmhkYpGpoUtqV8e7apAvd_vfef6mRtrWMW5NlnJK6KKtOvxtTfEjdQbpTvc06znVdJta7og_a9DAneV4P9--gUCvfOvYWPSTK1nDnIPc9hsDggMQAn6HzAQ1k9AbEo-04oHDIFLNgsN6p9wfDBDcn:1wKXsC:7rURxdO_gN8drY5HI7bk85MsVHsrVfaqNaJl0jOKJYY','2026-05-20 08:44:52.218423'),('ls0d9poxkylsdjqyl77jma7ebwdvnz21','.eJxVjEEOwiAQRe_C2pDCAB1duu8ZCAODVA0kpV0Z765NutDtf-_9l_BhW4vfOi9-TuIitBGn35FCfHDdSbqHemsytrouM8ldkQftcmqJn9fD_TsooZdvTWyVBpM5AmVEBYyozehiRIOWHZkEGZSOyZGmbGBQyYKy5wHVqBHE-wMFEzdJ:1wYSGg:Gn2qf792ksJxe7fJaAhXBLmlu-WJpfKLU5R-dt3mGVQ','2026-06-27 17:35:38.504846'),('pkx1kv81ecxyagz614ul6my13e3sgo9b','.eJxVjMsOwiAQRf-FtSE8Bhlcuu83kAGmUjU0Ke3K-O_apAvd3nPOfYlI21rj1nmJUxEXocXpd0uUH9x2UO7UbrPMc1uXKcldkQftcpgLP6-H-3dQqddvjbY4ZEc5BA_FKqu1sjbYfC7AHpGTSjAGUAYCcvbICtA7BQZMojGL9we9Tzby:1wML3k:5SV3vpnE_-zDxQsWb7lYGLVCx8FOBXC7It-8Y-2Qijg','2026-05-25 07:28:12.037588');
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

-- Dump completed on 2026-06-13 19:38:12
