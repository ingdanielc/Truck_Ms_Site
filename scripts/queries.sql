-- ---------------------------------------------------------------------------------------------------------
-- Consultas basicas
-- ---------------------------------------------------------------------------------------------------------

Use cashTruck;
SET SQL_SAFE_UPDATES = 0;
SELECT curdate();
SELECT CURRENT_TIMESTAMP();

SELECT * FROM document_type;
SELECT * FROM city;
SELECT * FROM gender;

SELECT * FROM owner;
SELECT * FROM users;
SELECT * FROM user_role;
SELECT * FROM roles;
SELECT * FROM driver;
SELECT * FROM vehicle;
SELECT * FROM vehicle_owner;
SELECT * FROM trip;
SELECT * FROM trip limit 200;
SELECT count(*) FROM trip where status = 'En Curso';
SELECT * FROM trip where vehicle_id in (199, 200) limit 200; -- ownerId = 100
SELECT * FROM vehicle_owner WHERE owner_id = 100;
SELECT * FROM trip where destination_id = 61 limit 1200; -- ownerId = 100

select * from vehicle_owner 
where vehicle_id in (SELECT vehicle_id FROM trip where destination_id = 61);

SELECT count(1) FROM user_role;
SELECT * FROM vehicle WHERE status = 'En Mantenimiento' ;
UPDATE vehicle set status = 'Activo' WHERE status = 'En Mantenimiento' ;

SELECT NOW();

SELECT * FROM users;

SELECT * FROM expense_type;
SELECT * FROM expense_category where expense_type_id <> 4;

SELECT * FROM expense_category where expense_type_id <> 4 and id = 23;
#UPDATE expense_category 
#SET name = 'Impuesto 4x1000'
#where expense_type_id <> 4 and id = 23;

SELECT * FROM expense;
-- DELETE FROM expense_category;
-- ALTER TABLE expense_category AUTO_INCREMENT = 1;

SELECT * FROM notification;
SELECT * FROM driver_locations;

-- Seguridad
SELECT * FROM users;

SELECT * FROM roles;
SELECT * FROM user_role;


-- Notifications
SELECT * FROM audit;
-- DELETE FROM audit WHERE id >= 1;

SELECT * FROM template;
-- DELETE FROM template WHERE id >= 1;

SELECT * FROM whatsapp;
-- DELETE FROM whatsapp WHERE id = 1;

SELECT * FROM email;
-- DELETE FROM email WHERE id = 1;

SELECT * FROM password_reset;
