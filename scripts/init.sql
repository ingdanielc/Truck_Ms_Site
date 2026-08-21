-- Se ejecuta en la base de datos del VPS

SHOW DATABASES;
CREATE DATABASE cashTruck;

ALTER DATABASE cashTruck 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

CREATE USER 'cashTruck'@'%' IDENTIFIED BY 'cashTruck2026';
GRANT ALL PRIVILEGES ON *.* TO 'cashTruck'@'%' WITH GRANT OPTION; -- Se ejecuta como root
 