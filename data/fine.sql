-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
--
-- Host: localhost    Database: finetoenglish
-- ------------------------------------------------------
-- Server version	8.0.31

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
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add estudiante',7,'add_estudiante'),(26,'Can change estudiante',7,'change_estudiante'),(27,'Can delete estudiante',7,'delete_estudiante'),(28,'Can view estudiante',7,'view_estudiante'),(29,'Can add representante',8,'add_representante'),(30,'Can change representante',8,'change_representante'),(31,'Can delete representante',8,'delete_representante'),(32,'Can view representante',8,'view_representante'),(33,'Can add codigo verificacion email',9,'add_codigoverificacionemail'),(34,'Can change codigo verificacion email',9,'change_codigoverificacionemail'),(35,'Can delete codigo verificacion email',9,'delete_codigoverificacionemail'),(36,'Can view codigo verificacion email',9,'view_codigoverificacionemail'),(37,'Can add matricula',10,'add_matricula'),(38,'Can change matricula',10,'change_matricula'),(39,'Can delete matricula',10,'delete_matricula'),(40,'Can view matricula',10,'view_matricula'),(41,'Can add componente',11,'add_componente'),(42,'Can change componente',11,'change_componente'),(43,'Can delete componente',11,'delete_componente'),(44,'Can view componente',11,'view_componente'),(45,'Can add nota',12,'add_nota'),(46,'Can change nota',12,'change_nota'),(47,'Can delete nota',12,'delete_nota'),(48,'Can view nota',12,'view_nota'),(49,'Can add datos pago matricula',13,'add_datospagomatricula'),(50,'Can change datos pago matricula',13,'change_datospagomatricula'),(51,'Can delete datos pago matricula',13,'delete_datospagomatricula'),(52,'Can view datos pago matricula',13,'view_datospagomatricula'),(53,'Can add docente',14,'add_docente'),(54,'Can change docente',14,'change_docente'),(55,'Can delete docente',14,'delete_docente'),(56,'Can view docente',14,'view_docente'),(57,'Can add entrega tarea',16,'add_entregatarea'),(58,'Can change entrega tarea',16,'change_entregatarea'),(59,'Can delete entrega tarea',16,'delete_entregatarea'),(60,'Can view entrega tarea',16,'view_entregatarea'),(61,'Can add asignacion tarea',15,'add_asignaciontarea'),(62,'Can change asignacion tarea',15,'change_asignaciontarea'),(63,'Can delete asignacion tarea',15,'delete_asignaciontarea'),(64,'Can view asignacion tarea',15,'view_asignaciontarea'),(65,'Can add asignacion docente componente',17,'add_asignaciondocentecomponente'),(66,'Can change asignacion docente componente',17,'change_asignaciondocentecomponente'),(67,'Can delete asignacion docente componente',17,'delete_asignaciondocentecomponente'),(68,'Can view asignacion docente componente',17,'view_asignaciondocentecomponente'),(69,'Can add Calificación final de tarea',18,'add_calificacionfinaltarea'),(70,'Can change Calificación final de tarea',18,'change_calificacionfinaltarea'),(71,'Can delete Calificación final de tarea',18,'delete_calificacionfinaltarea'),(72,'Can view Calificación final de tarea',18,'view_calificacionfinaltarea'),(73,'Can add anuncio',19,'add_anuncio'),(74,'Can change anuncio',19,'change_anuncio'),(75,'Can delete anuncio',19,'delete_anuncio'),(76,'Can view anuncio',19,'view_anuncio'),(77,'Can add comentario anuncio',20,'add_comentarioanuncio'),(78,'Can change comentario anuncio',20,'change_comentarioanuncio'),(79,'Can delete comentario anuncio',20,'delete_comentarioanuncio'),(80,'Can view comentario anuncio',20,'view_comentarioanuncio'),(81,'Can add imagen anuncio',21,'add_imagenanuncio'),(82,'Can change imagen anuncio',21,'change_imagenanuncio'),(83,'Can delete imagen anuncio',21,'delete_imagenanuncio'),(84,'Can view imagen anuncio',21,'view_imagenanuncio');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$600000$qKjbQzyS0oldFRxQU1QK9N$/YcAYGYgmk/jvL8g7/V7BS7JqV/abelO4LVyf702/hY=','2025-07-20 03:09:49.368251',1,'byron','','','',1,1,'2025-07-11 19:58:07.106382'),(2,'pbkdf2_sha256$600000$w80OGepJFzx0WQ3nAFCElG$Txpf4VL1lt0AMvSiXVHMeXtxm4BGl5QSbzBHVD4jmkc=',NULL,0,'bmvaldivieso','','','bmvaldivieso@gmail.com',0,1,'2025-07-11 21:54:21.292401'),(3,'pbkdf2_sha256$600000$9MUDyjUgDhfKYN8usxfHJJ$6ERdHFkNy/wayzeidvVfp+ly6a7sIt3QAzX63MqMhfM=','2025-07-20 03:13:10.747380',0,'rojasf','','','rojas@gmail.com',0,1,'2025-07-13 20:16:07.000000'),(4,'pbkdf2_sha256$600000$jFSVpxLcHebAgw57MgDQE3$JZ2ObjvjpLIfJkQblAHQXQm79g9brtwTDR6c5GkU4lE=',NULL,0,'carlos','','','',0,1,'2025-07-14 23:28:59.898905');
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
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2025-07-12 20:24:11.036478','1','Byron Marcelo Valdivieso Paucar',2,'[{\"changed\": {\"fields\": [\"Nivel estudio\", \"Programa academico\"]}}]',7,1),(2,'2025-07-12 20:32:32.549655','1','A1.1 English Express 1 (express) - 179.1',1,'[{\"added\": {}}]',11,1),(3,'2025-07-12 20:32:47.066969','1','A1.1 English Express 1 (express) - 179.1',2,'[]',11,1),(4,'2025-07-12 20:35:10.300609','1','A1.1 English Express 1 (express) - 2025A',2,'[{\"changed\": {\"fields\": [\"Precio\", \"Periodo\"]}}]',11,1),(5,'2025-07-12 21:09:09.241085','1','Matrícula de Byron Marcelo Valdivieso Paucar en A1.1 English Express 1',3,'',10,1),(6,'2025-07-12 21:09:52.705924','1','A1.1 English Express 1 (express) - 2025A',2,'[]',11,1),(7,'2025-07-12 21:10:46.579312','1','A1.1 English Express 1 (express) - 2025A',2,'[]',11,1),(8,'2025-07-12 21:10:51.469641','1','Byron Marcelo Valdivieso Paucar',2,'[]',7,1),(9,'2025-07-12 21:28:56.971836','2','Matrícula de Byron Marcelo Valdivieso Paucar en A1.1 English Express 1',3,'',10,1),(10,'2025-07-12 22:51:21.689590','3','Matrícula de Byron Marcelo Valdivieso Paucar en A1.1 English Express 1',3,'',10,1),(11,'2025-07-13 01:13:21.347778','2','A2.1 English Express 3 (express) - 2025A',1,'[{\"added\": {}}]',11,1),(12,'2025-07-13 20:16:07.917661','3','rojasf',1,'[{\"added\": {}}]',4,1),(13,'2025-07-13 20:16:42.806823','1','BURI ROJAS JORGE FERNANDO',1,'[{\"added\": {}}]',14,1),(14,'2025-07-13 20:17:31.406090','1','Byron Marcelo Valdivieso Paucar - A2.1 English Express 3 - Bimestre 1',1,'[{\"added\": {}}]',12,1),(15,'2025-07-13 20:18:08.189076','2','Byron Marcelo Valdivieso Paucar - A2.1 English Express 3 - Bimestre 2',1,'[{\"added\": {}}]',12,1),(16,'2025-07-13 20:18:37.292667','3','Byron Marcelo Valdivieso Paucar - A1.1 English Express 1 - Bimestre 1',1,'[{\"added\": {}}]',12,1),(17,'2025-07-13 20:18:58.178819','4','Byron Marcelo Valdivieso Paucar - A1.1 English Express 1 - Bimestre 2',1,'[{\"added\": {}}]',12,1),(18,'2025-07-14 16:41:25.004384','1','Tarea1',1,'[{\"added\": {}}]',15,1),(19,'2025-07-14 18:30:56.447537','2','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(20,'2025-07-14 18:30:59.225157','1','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(21,'2025-07-14 18:40:41.537887','3','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(22,'2025-07-14 19:22:10.680892','4','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(23,'2025-07-14 19:22:13.413147','5','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(24,'2025-07-14 23:29:00.752408','4','carlos',1,'[{\"added\": {}}]',4,1),(25,'2025-07-14 23:31:37.448088','2','Carlos Lopez',1,'[{\"added\": {}}]',7,1),(26,'2025-07-15 00:05:47.627017','5','Matrícula de Carlos Lopez en A1.1 English Express 1',3,'',10,1),(27,'2025-07-15 20:23:27.154722','2','Tarea 2',1,'[{\"added\": {}}]',15,1),(28,'2025-07-18 18:36:43.724576','6','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(29,'2025-07-18 18:43:46.397905','10','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(30,'2025-07-18 18:43:49.303272','9','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea 2',3,'',16,1),(31,'2025-07-18 18:43:51.985944','8','Entrega 1 - Carlos Lopez - Tarea1',3,'',16,1),(32,'2025-07-18 18:43:54.529191','7','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(33,'2025-07-18 18:55:39.707396','12','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(34,'2025-07-18 19:01:02.003024','11','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(35,'2025-07-18 19:01:04.814013','13','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(36,'2025-07-18 19:13:26.137422','14','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(37,'2025-07-18 19:13:28.952696','15','Entrega 2 - Byron Marcelo Valdivieso Paucar - Tarea1',3,'',16,1),(38,'2025-07-18 20:49:30.872856','18','Entrega 1 - Byron Marcelo Valdivieso Paucar - Tarea 2',3,'',16,1),(39,'2025-07-18 22:43:17.556688','3','rojasf',2,'[{\"changed\": {\"fields\": [\"password\"]}}]',4,1),(40,'2025-07-18 22:46:38.694477','3','rojasf',2,'[{\"changed\": {\"fields\": [\"Email address\"]}}]',4,1),(41,'2025-07-19 16:40:52.775742','1','BURI ROJAS JORGE FERNANDO → A1.1 English Express 1',1,'[{\"added\": {}}]',17,1),(42,'2025-07-19 16:40:57.664784','2','BURI ROJAS JORGE FERNANDO → A2.1 English Express 3',1,'[{\"added\": {}}]',17,1),(43,'2025-07-19 20:14:44.183810','1','Byron Marcelo Valdivieso Paucar → Tarea1: 0.0',1,'[{\"added\": {}}]',18,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(19,'mySql','anuncio'),(17,'mySql','asignaciondocentecomponente'),(15,'mySql','asignaciontarea'),(18,'mySql','calificacionfinaltarea'),(9,'mySql','codigoverificacionemail'),(20,'mySql','comentarioanuncio'),(11,'mySql','componente'),(13,'mySql','datospagomatricula'),(14,'mySql','docente'),(16,'mySql','entregatarea'),(7,'mySql','estudiante'),(21,'mySql','imagenanuncio'),(10,'mySql','matricula'),(12,'mySql','nota'),(8,'mySql','representante'),(6,'sessions','session');
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
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2025-07-11 19:57:29.975496'),(2,'auth','0001_initial','2025-07-11 19:57:30.145951'),(3,'admin','0001_initial','2025-07-11 19:57:30.191970'),(4,'admin','0002_logentry_remove_auto_add','2025-07-11 19:57:30.197074'),(5,'admin','0003_logentry_add_action_flag_choices','2025-07-11 19:57:30.201220'),(6,'contenttypes','0002_remove_content_type_name','2025-07-11 19:57:30.233203'),(7,'auth','0002_alter_permission_name_max_length','2025-07-11 19:57:30.253131'),(8,'auth','0003_alter_user_email_max_length','2025-07-11 19:57:30.265573'),(9,'auth','0004_alter_user_username_opts','2025-07-11 19:57:30.270357'),(10,'auth','0005_alter_user_last_login_null','2025-07-11 19:57:30.293135'),(11,'auth','0006_require_contenttypes_0002','2025-07-11 19:57:30.296255'),(12,'auth','0007_alter_validators_add_error_messages','2025-07-11 19:57:30.304221'),(13,'auth','0008_alter_user_username_max_length','2025-07-11 19:57:30.329441'),(14,'auth','0009_alter_user_last_name_max_length','2025-07-11 19:57:30.353400'),(15,'auth','0010_alter_group_name_max_length','2025-07-11 19:57:30.364662'),(16,'auth','0011_update_proxy_permissions','2025-07-11 19:57:30.371680'),(17,'auth','0012_alter_user_first_name_max_length','2025-07-11 19:57:30.397069'),(18,'mySql','0001_initial','2025-07-11 19:57:30.482288'),(19,'mySql','0002_codigoverificacionemail','2025-07-11 19:57:30.490487'),(20,'mySql','0003_matricula','2025-07-11 19:57:30.519717'),(21,'sessions','0001_initial','2025-07-11 19:57:30.535415'),(22,'mySql','0004_componente_remove_matricula_cuotas_pagar_and_more','2025-07-12 20:22:14.701771'),(23,'mySql','0005_matricula_cuotas','2025-07-12 21:25:11.066102'),(24,'mySql','0006_datospagomatricula','2025-07-12 21:34:28.176399'),(25,'mySql','0007_rename_fecha_pago_datospagomatricula_fecha_registro_and_more','2025-07-12 22:05:53.566071'),(26,'mySql','0008_alter_nota_unique_together_nota_bimestre_and_more','2025-07-13 19:11:46.735593'),(27,'mySql','0009_asignaciontarea_entregatarea','2025-07-14 16:39:52.561629'),(28,'mySql','0010_docente_imagen_perfil','2025-07-18 22:40:12.741740'),(29,'mySql','0011_asignaciondocentecomponente','2025-07-19 16:40:30.151054'),(30,'mySql','0012_calificacionfinaltarea','2025-07-19 19:13:58.450760'),(31,'mySql','0013_anuncio_imagenanuncio_comentarioanuncio','2025-07-20 00:18:48.751464');
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
INSERT INTO `django_session` VALUES ('9biimevxx7nmag9d8ivtc6lwbppjhwhg','.eJxVjMsOwiAQRf-FtSEgw0xx6d5vIMOjUjWQlHZl_HdD0oVu7znnvoXnfSt-73n1SxIXYcTpdwscn7kOkB5c703GVrd1CXIo8qBd3lrKr-vh_h0U7mXUhKgpuzBbnIjs2ThNE4CKBrJGFRxnDsmBAQKGmTBY5sgakJRRKD5fvmg27Q:1ucurD:ojs_9P7SIv85YbrRMcU7E0JdwBr35XLE8GT8paYwTuU','2025-08-01 23:51:15.433191'),('bu4v34akj68kkfiyayvv377oc6t2yqtr','.eJxVjEEOgjAQRe_StWk6hcKMS_ecoZlpi0VNSSisjHcXEha6fe_9_1aetzX7rabFT1FdFajLLxMOz1QOER9c7rMOc1mXSfSR6NNWPcwxvW5n-3eQueZ9LTRG6oCCbZJg64yzvSMDY2eFJAExUItIaAT7xhkMAUQEjd0hsFWfL8OsNsc:1ubQC8:pVXgTdOp3nfXpdn30-nCjk5ttAWZy3HTpdC5sImIc-I','2025-07-28 20:54:40.945717'),('ksumfm6nzd8fnesbwha7l4z0d0oolaru','.eJxVjMsOwiAQRf-FtSEgw0xx6d5vIMOjUjWQlHZl_HdD0oVu7znnvoXnfSt-73n1SxIXYcTpdwscn7kOkB5c703GVrd1CXIo8qBd3lrKr-vh_h0U7mXUhKgpuzBbnIjs2ThNE4CKBrJGFRxnDsmBAQKGmTBY5sgakJRRKD5fvmg27Q:1udKUA:CfDGUn8m7wNhL1erPL2QvneCjWe2k8BwcFA6VRKoNQ4','2025-08-03 03:13:10.750885');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_anuncio`
--

DROP TABLE IF EXISTS `mysql_anuncio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_anuncio` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) NOT NULL,
  `contenido` longtext NOT NULL,
  `fecha_creacion` datetime(6) NOT NULL,
  `publicada` tinyint(1) NOT NULL,
  `componente_id` bigint NOT NULL,
  `docente_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_anuncio_componente_id_925de786_fk_mySql_componente_id` (`componente_id`),
  KEY `mySql_anuncio_docente_id_0f6f089a_fk_mySql_docente_id` (`docente_id`),
  CONSTRAINT `mySql_anuncio_componente_id_925de786_fk_mySql_componente_id` FOREIGN KEY (`componente_id`) REFERENCES `mysql_componente` (`id`),
  CONSTRAINT `mySql_anuncio_docente_id_0f6f089a_fk_mySql_docente_id` FOREIGN KEY (`docente_id`) REFERENCES `mysql_docente` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_anuncio`
--

LOCK TABLES `mysql_anuncio` WRITE;
/*!40000 ALTER TABLE `mysql_anuncio` DISABLE KEYS */;
INSERT INTO `mysql_anuncio` VALUES (5,'Anuncio 1','deber','2025-07-20 01:31:18.338111',1,1,1);
/*!40000 ALTER TABLE `mysql_anuncio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_asignaciondocentecomponente`
--

DROP TABLE IF EXISTS `mysql_asignaciondocentecomponente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_asignaciondocentecomponente` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fecha_asignacion` datetime(6) NOT NULL,
  `componente_id` bigint NOT NULL,
  `docente_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mySql_asignaciondocentec_docente_id_componente_id_7ec42d4d_uniq` (`docente_id`,`componente_id`),
  KEY `mySql_asignaciondoce_componente_id_2535013c_fk_mySql_com` (`componente_id`),
  CONSTRAINT `mySql_asignaciondoce_componente_id_2535013c_fk_mySql_com` FOREIGN KEY (`componente_id`) REFERENCES `mysql_componente` (`id`),
  CONSTRAINT `mySql_asignaciondoce_docente_id_8fc1697c_fk_mySql_doc` FOREIGN KEY (`docente_id`) REFERENCES `mysql_docente` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_asignaciondocentecomponente`
--

LOCK TABLES `mysql_asignaciondocentecomponente` WRITE;
/*!40000 ALTER TABLE `mysql_asignaciondocentecomponente` DISABLE KEYS */;
INSERT INTO `mysql_asignaciondocentecomponente` VALUES (1,'2025-07-19 16:40:52.775060',1,1),(2,'2025-07-19 16:40:57.663846',2,1);
/*!40000 ALTER TABLE `mysql_asignaciondocentecomponente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_asignaciontarea`
--

DROP TABLE IF EXISTS `mysql_asignaciontarea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_asignaciontarea` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) NOT NULL,
  `descripcion` longtext NOT NULL,
  `fecha_entrega` datetime(6) NOT NULL,
  `intentos_maximos` int unsigned NOT NULL,
  `publicada` tinyint(1) NOT NULL,
  `componente_id` bigint NOT NULL,
  `docente_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_asignaciontare_componente_id_45c9b20e_fk_mySql_com` (`componente_id`),
  KEY `mySql_asignaciontarea_docente_id_6cf4992c_fk_mySql_docente_id` (`docente_id`),
  CONSTRAINT `mySql_asignaciontare_componente_id_45c9b20e_fk_mySql_com` FOREIGN KEY (`componente_id`) REFERENCES `mysql_componente` (`id`),
  CONSTRAINT `mySql_asignaciontarea_docente_id_6cf4992c_fk_mySql_docente_id` FOREIGN KEY (`docente_id`) REFERENCES `mysql_docente` (`id`),
  CONSTRAINT `mysql_asignaciontarea_chk_1` CHECK ((`intentos_maximos` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_asignaciontarea`
--

LOCK TABLES `mysql_asignaciontarea` WRITE;
/*!40000 ALTER TABLE `mysql_asignaciontarea` DISABLE KEYS */;
INSERT INTO `mysql_asignaciontarea` VALUES (1,'Tarea1','Subir archivos.','2025-07-16 18:00:00.000000',2,1,1,1),(2,'Tarea 2','Subir los archivos correspondientes.','2025-07-24 18:00:00.000000',3,1,1,1),(5,'Tarea 1','H','2025-07-29 12:00:00.000000',2,1,2,1),(7,'Tarea 3','hola','2025-07-27 12:00:00.000000',2,1,1,1);
/*!40000 ALTER TABLE `mysql_asignaciontarea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_calificacionfinaltarea`
--

DROP TABLE IF EXISTS `mysql_calificacionfinaltarea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_calificacionfinaltarea` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nota_final` double NOT NULL,
  `fecha_actualizacion` datetime(6) NOT NULL,
  `estudiante_id` bigint NOT NULL,
  `tarea_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mySql_calificacionfinalt_estudiante_id_tarea_id_68e95378_uniq` (`estudiante_id`,`tarea_id`),
  KEY `mySql_calificacionfi_tarea_id_8a734574_fk_mySql_asi` (`tarea_id`),
  CONSTRAINT `mySql_calificacionfi_estudiante_id_8c8a405f_fk_mySql_est` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`),
  CONSTRAINT `mySql_calificacionfi_tarea_id_8a734574_fk_mySql_asi` FOREIGN KEY (`tarea_id`) REFERENCES `mysql_asignaciontarea` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_calificacionfinaltarea`
--

LOCK TABLES `mysql_calificacionfinaltarea` WRITE;
/*!40000 ALTER TABLE `mysql_calificacionfinaltarea` DISABLE KEYS */;
INSERT INTO `mysql_calificacionfinaltarea` VALUES (1,9,'2025-07-19 21:44:01.018179',1,1),(2,0,'2025-07-19 23:36:43.499102',1,7);
/*!40000 ALTER TABLE `mysql_calificacionfinaltarea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_codigoverificacionemail`
--

DROP TABLE IF EXISTS `mysql_codigoverificacionemail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_codigoverificacionemail` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `correo` varchar(254) NOT NULL,
  `codigo` varchar(6) NOT NULL,
  `creado_en` datetime(6) NOT NULL,
  `expiracion` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_codigoverificacionemail`
--

LOCK TABLES `mysql_codigoverificacionemail` WRITE;
/*!40000 ALTER TABLE `mysql_codigoverificacionemail` DISABLE KEYS */;
/*!40000 ALTER TABLE `mysql_codigoverificacionemail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_comentarioanuncio`
--

DROP TABLE IF EXISTS `mysql_comentarioanuncio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_comentarioanuncio` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `texto` longtext NOT NULL,
  `fecha_comentario` datetime(6) NOT NULL,
  `anuncio_id` bigint NOT NULL,
  `estudiante_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_comentarioanuncio_anuncio_id_ebf2d6eb_fk_mySql_anuncio_id` (`anuncio_id`),
  KEY `mySql_comentarioanun_estudiante_id_7c325367_fk_mySql_est` (`estudiante_id`),
  CONSTRAINT `mySql_comentarioanun_estudiante_id_7c325367_fk_mySql_est` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`),
  CONSTRAINT `mySql_comentarioanuncio_anuncio_id_ebf2d6eb_fk_mySql_anuncio_id` FOREIGN KEY (`anuncio_id`) REFERENCES `mysql_anuncio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_comentarioanuncio`
--

LOCK TABLES `mysql_comentarioanuncio` WRITE;
/*!40000 ALTER TABLE `mysql_comentarioanuncio` DISABLE KEYS */;
/*!40000 ALTER TABLE `mysql_comentarioanuncio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_componente`
--

DROP TABLE IF EXISTS `mysql_componente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_componente` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `programa_academico` varchar(50) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `periodo` varchar(50) NOT NULL,
  `horario` varchar(100) NOT NULL,
  `cupos_disponibles` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `mysql_componente_chk_1` CHECK ((`cupos_disponibles` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_componente`
--

LOCK TABLES `mysql_componente` WRITE;
/*!40000 ALTER TABLE `mysql_componente` DISABLE KEYS */;
INSERT INTO `mysql_componente` VALUES (1,'A1.1 English Express 1','express',179.10,'2025A','19:00 - 21:00',10),(2,'A2.1 English Express 3','express',180.00,'2025A','19:00 - 21:00',15);
/*!40000 ALTER TABLE `mysql_componente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_datospagomatricula`
--

DROP TABLE IF EXISTS `mysql_datospagomatricula`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_datospagomatricula` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `metodo_pago` varchar(20) NOT NULL,
  `referencia` varchar(100) DEFAULT NULL,
  `id_depositante` varchar(100) DEFAULT NULL,
  `nombre_tarjeta` varchar(100) DEFAULT NULL,
  `numero_tarjeta` varchar(30) DEFAULT NULL,
  `fecha_registro` datetime(6) NOT NULL,
  `componente_id` bigint NOT NULL,
  `estudiante_id` bigint NOT NULL,
  `cvv` varchar(10) DEFAULT NULL,
  `fecha_deposito` varchar(50) DEFAULT NULL,
  `monto` varchar(50) DEFAULT NULL,
  `vencimiento` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_datospagomatri_componente_id_f71599a1_fk_mySql_com` (`componente_id`),
  KEY `mySql_datospagomatri_estudiante_id_de0c5aac_fk_mySql_est` (`estudiante_id`),
  CONSTRAINT `mySql_datospagomatri_componente_id_f71599a1_fk_mySql_com` FOREIGN KEY (`componente_id`) REFERENCES `mysql_componente` (`id`),
  CONSTRAINT `mySql_datospagomatri_estudiante_id_de0c5aac_fk_mySql_est` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_datospagomatricula`
--

LOCK TABLES `mysql_datospagomatricula` WRITE;
/*!40000 ALTER TABLE `mysql_datospagomatricula` DISABLE KEYS */;
INSERT INTO `mysql_datospagomatricula` VALUES (1,'deposito','457896','1245789638','','','2025-07-13 00:06:30.664576',1,1,'','12/07/2025','170',''),(2,'deposito','124585','458596','','','2025-07-14 23:33:32.225462',1,2,'','08/07/2025','140','');
/*!40000 ALTER TABLE `mysql_datospagomatricula` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_docente`
--

DROP TABLE IF EXISTS `mysql_docente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_docente` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombres_apellidos` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `celular` varchar(15) NOT NULL,
  `user_id` int NOT NULL,
  `imagen_perfil` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `celular` (`celular`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `mySql_docente_user_id_89a5d908_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_docente`
--

LOCK TABLES `mysql_docente` WRITE;
/*!40000 ALTER TABLE `mysql_docente` DISABLE KEYS */;
INSERT INTO `mysql_docente` VALUES (1,'BURI ROJAS JORGE FERNANDO','rojas@gmail.com','0985126548',3,NULL);
/*!40000 ALTER TABLE `mysql_docente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_entregatarea`
--

DROP TABLE IF EXISTS `mysql_entregatarea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_entregatarea` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `intento_numero` int unsigned NOT NULL,
  `fecha_entrega` datetime(6) NOT NULL,
  `entregado` tinyint(1) NOT NULL,
  `calificacion` double DEFAULT NULL,
  `observaciones` longtext NOT NULL,
  `asignacion_id` bigint NOT NULL,
  `estudiante_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_entregatarea_asignacion_id_a0c71f9b_fk_mySql_asi` (`asignacion_id`),
  KEY `mySql_entregatarea_estudiante_id_29ade25f_fk_mySql_estudiante_id` (`estudiante_id`),
  CONSTRAINT `mySql_entregatarea_asignacion_id_a0c71f9b_fk_mySql_asi` FOREIGN KEY (`asignacion_id`) REFERENCES `mysql_asignaciontarea` (`id`),
  CONSTRAINT `mySql_entregatarea_estudiante_id_29ade25f_fk_mySql_estudiante_id` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`),
  CONSTRAINT `mysql_entregatarea_chk_1` CHECK ((`intento_numero` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_entregatarea`
--

LOCK TABLES `mysql_entregatarea` WRITE;
/*!40000 ALTER TABLE `mysql_entregatarea` DISABLE KEYS */;
INSERT INTO `mysql_entregatarea` VALUES (16,1,'2025-07-18 19:13:46.491303',1,8,'h',1,1),(17,2,'2025-07-18 19:15:55.674027',1,9,'Good',1,1),(19,1,'2025-07-18 20:49:57.527189',1,NULL,'',2,1);
/*!40000 ALTER TABLE `mysql_entregatarea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_estudiante`
--

DROP TABLE IF EXISTS `mysql_estudiante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_estudiante` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tipo_identificacion` varchar(20) NOT NULL,
  `identificacion` varchar(30) NOT NULL,
  `nombres_apellidos` varchar(150) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `genero` varchar(1) NOT NULL,
  `ocupacion` varchar(20) NOT NULL,
  `nivel_estudio` varchar(20) NOT NULL,
  `lugar_estudio_trabajo` varchar(150) NOT NULL,
  `direccion` longtext NOT NULL,
  `email` varchar(254) NOT NULL,
  `celular` varchar(15) NOT NULL,
  `telefono_convencional` varchar(15) DEFAULT NULL,
  `parroquia` varchar(20) NOT NULL,
  `programa_academico` varchar(30) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identificacion` (`identificacion`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `celular` (`celular`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `mySql_estudiante_user_id_2f61b0b1_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_estudiante`
--

LOCK TABLES `mysql_estudiante` WRITE;
/*!40000 ALTER TABLE `mysql_estudiante` DISABLE KEYS */;
INSERT INTO `mysql_estudiante` VALUES (1,'cedula','1125638954','Byron Marcelo Valdivieso Paucar','2003-07-17','M','estudiante','universidad','Zamora','Zamora','bmvaldivieso@gmail.com','0985964588','55632578','san_sebastian','express',2),(2,'cedula','1245789663','Carlos Lopez','1999-07-14','M','estudiante','universidad','Zamora','Zamora','carlosmlo381@gmail.com','0985457520','45865921','san_sebastian','express',4);
/*!40000 ALTER TABLE `mysql_estudiante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_imagenanuncio`
--

DROP TABLE IF EXISTS `mysql_imagenanuncio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_imagenanuncio` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `imagen` varchar(100) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `anuncio_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_imagenanuncio_anuncio_id_90d23fa5_fk_mySql_anuncio_id` (`anuncio_id`),
  CONSTRAINT `mySql_imagenanuncio_anuncio_id_90d23fa5_fk_mySql_anuncio_id` FOREIGN KEY (`anuncio_id`) REFERENCES `mysql_anuncio` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_imagenanuncio`
--

LOCK TABLES `mysql_imagenanuncio` WRITE;
/*!40000 ALTER TABLE `mysql_imagenanuncio` DISABLE KEYS */;
INSERT INTO `mysql_imagenanuncio` VALUES (6,'anuncios/imagenes/mapa_YN14d25.png','',5);
/*!40000 ALTER TABLE `mysql_imagenanuncio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_matricula`
--

DROP TABLE IF EXISTS `mysql_matricula`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_matricula` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `metodo_pago` varchar(50) NOT NULL,
  `medio_entero` varchar(50) NOT NULL,
  `fecha_matricula` date NOT NULL,
  `estudiante_id` bigint NOT NULL,
  `activa` tinyint(1) NOT NULL,
  `costo_matricula` decimal(10,2) NOT NULL,
  `estado` varchar(20) NOT NULL,
  `observaciones` longtext,
  `componente_cursado_id` bigint DEFAULT NULL,
  `cuotas` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mySql_matricula_estudiante_id_331caa67_fk_mySql_estudiante_id` (`estudiante_id`),
  KEY `mySql_matricula_componente_cursado_i_4905ad73_fk_mySql_com` (`componente_cursado_id`),
  CONSTRAINT `mySql_matricula_componente_cursado_i_4905ad73_fk_mySql_com` FOREIGN KEY (`componente_cursado_id`) REFERENCES `mysql_componente` (`id`),
  CONSTRAINT `mySql_matricula_estudiante_id_331caa67_fk_mySql_estudiante_id` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_matricula`
--

LOCK TABLES `mysql_matricula` WRITE;
/*!40000 ALTER TABLE `mysql_matricula` DISABLE KEYS */;
INSERT INTO `mysql_matricula` VALUES (4,'deposito','pagina_web','2025-07-12',1,1,179.10,'confirmada',NULL,1,'1');
/*!40000 ALTER TABLE `mysql_matricula` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_nota`
--

DROP TABLE IF EXISTS `mysql_nota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_nota` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `docente_id` bigint DEFAULT NULL,
  `inasistencias` int unsigned NOT NULL,
  `fecha_registro` datetime(6) NOT NULL,
  `componente_id` bigint NOT NULL,
  `estudiante_id` bigint NOT NULL,
  `bimestre` int NOT NULL,
  `grupales` decimal(5,2) NOT NULL,
  `individuales` decimal(5,2) NOT NULL,
  `lecciones` decimal(5,2) NOT NULL,
  `tareas` decimal(5,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mySql_nota_estudiante_id_componente_id_bimestre_e7ba86f8_uniq` (`estudiante_id`,`componente_id`,`bimestre`),
  KEY `mySql_nota_componente_id_3210bdfd_fk_mySql_componente_id` (`componente_id`),
  KEY `mySql_nota_estudiante_id_95705fad` (`estudiante_id`),
  KEY `mySql_nota_docente_id_eb00bdd5` (`docente_id`),
  CONSTRAINT `mySql_nota_componente_id_3210bdfd_fk_mySql_componente_id` FOREIGN KEY (`componente_id`) REFERENCES `mysql_componente` (`id`),
  CONSTRAINT `mySql_nota_docente_id_eb00bdd5_fk_mySql_docente_id` FOREIGN KEY (`docente_id`) REFERENCES `mysql_docente` (`id`),
  CONSTRAINT `mySql_nota_estudiante_id_95705fad_fk_mySql_estudiante_id` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`),
  CONSTRAINT `mysql_nota_chk_1` CHECK ((`inasistencias` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_nota`
--

LOCK TABLES `mysql_nota` WRITE;
/*!40000 ALTER TABLE `mysql_nota` DISABLE KEYS */;
INSERT INTO `mysql_nota` VALUES (1,1,3,'2025-07-13 20:17:31.404638',2,1,1,95.00,75.00,90.00,80.00),(2,1,1,'2025-07-13 20:18:08.187964',2,1,2,70.00,85.00,80.00,80.00),(3,1,0,'2025-07-13 20:18:37.291582',1,1,1,90.00,70.00,80.00,75.00),(4,1,1,'2025-07-13 20:18:58.177525',1,1,2,80.00,90.00,80.00,80.00);
/*!40000 ALTER TABLE `mysql_nota` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mysql_representante`
--

DROP TABLE IF EXISTS `mysql_representante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mysql_representante` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `emitir_factura_al_estudiante` tinyint(1) NOT NULL,
  `tipo_identificacion` varchar(20) NOT NULL,
  `identificacion` varchar(30) NOT NULL,
  `razon_social` varchar(150) NOT NULL,
  `direccion` longtext NOT NULL,
  `email` varchar(254) NOT NULL,
  `celular` varchar(15) NOT NULL,
  `telefono_convencional` varchar(15) DEFAULT NULL,
  `sexo` varchar(1) NOT NULL,
  `estado_civil` varchar(20) NOT NULL,
  `origen_ingresos` varchar(30) NOT NULL,
  `parroquia` varchar(20) NOT NULL,
  `estudiante_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identificacion` (`identificacion`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `celular` (`celular`),
  UNIQUE KEY `estudiante_id` (`estudiante_id`),
  CONSTRAINT `mySql_representante_estudiante_id_d384fc1b_fk_mySql_est` FOREIGN KEY (`estudiante_id`) REFERENCES `mysql_estudiante` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mysql_representante`
--

LOCK TABLES `mysql_representante` WRITE;
/*!40000 ALTER TABLE `mysql_representante` DISABLE KEYS */;
INSERT INTO `mysql_representante` VALUES (1,1,'cedula','1125638954','Byron Marcelo Valdivieso Paucar','Zamora','bmvaldivieso@gmail.com','0985964588','55632578','M','soltero','empleado_publico','san_sebastian',1);
/*!40000 ALTER TABLE `mysql_representante` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-19 22:54:13
