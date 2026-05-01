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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Aereo`
--

LOCK TABLES `Aereo` WRITE;
/*!40000 ALTER TABLE `Aereo` DISABLE KEYS */;
/*!40000 ALTER TABLE `Aereo` ENABLE KEYS */;
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
  UNIQUE KEY `id_user` (`id_user`)
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
  UNIQUE KEY `id_user` (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Passeggero`
--

LOCK TABLES `Passeggero` WRITE;
/*!40000 ALTER TABLE `Passeggero` DISABLE KEYS */;
/*!40000 ALTER TABLE `Passeggero` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Prenotazione`
--

DROP TABLE IF EXISTS `Prenotazione`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Prenotazione` (
  `username_passeggero` varchar(20) NOT NULL,
  `id_volo` int NOT NULL,
  `data_acquisto` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `posto` char(5) NOT NULL,
  `classe` enum('economy','business','first') NOT NULL,
  PRIMARY KEY (`username_passeggero`,`id_volo`),
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
  `destinazione` char(3) NOT NULL,
  `id_aereo` int NOT NULL,
  `codice_gate` varchar(10) DEFAULT NULL,
  `stato` enum('in_orario','in_ritardo','imbarco','partito','cancellato') NOT NULL DEFAULT 'in_orario',
  PRIMARY KEY (`id_volo`),
  UNIQUE KEY `numero_volo` (`numero_volo`),
  KEY `fk_volo_aereo` (`id_aereo`),
  KEY `fk_volo_gate` (`codice_gate`),
  CONSTRAINT `fk_volo_aereo` FOREIGN KEY (`id_aereo`) REFERENCES `Aereo` (`id_aereo`) ON DELETE CASCADE,
  CONSTRAINT `fk_volo_gate` FOREIGN KEY (`codice_gate`) REFERENCES `Gate` (`codice_gate`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Volo`
--

LOCK TABLES `Volo` WRITE;
/*!40000 ALTER TABLE `Volo` DISABLE KEYS */;
/*!40000 ALTER TABLE `Volo` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-01  0:10:04
