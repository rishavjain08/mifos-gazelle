-- Note that for Mifos Gazelle deployments databases are esablished in helm infra chart 
-- # create root user and grant rights
-- GRANT ALL ON *.* TO 'root'@'%';
-- USE `fineract_tenants`;
-- delete from tenants where id=2;
-- delete from tenant_server_connections where id=2;
-- delete from tenants where id=3;
-- delete from tenant_server_connections where id=3;
-- commit; 

--  CREATE DATABASE IF NOT EXISTS `gazelle1`;
INSERT INTO `tenant_server_connections` (`id`, `schema_name`, `schema_server`, `schema_server_port`, `schema_username`, `schema_password`, `auto_update` , `master_password_hash` ) VALUES
(2, 'gazelle1', 'fineractmysql', '3306', 'root', 'di0rPrAQlYKUBhGwjAqSelXZHVss9UrtEqXHS40mpmj4Nf6C7fC6ltFaTcMsgFZ3',  1,  '$2a$10$tpozPRJgMLPjI/Z8FC2uweHFVbo6zol5qB45PgrijUbotpZNPY6au' );

INSERT INTO `tenants` (`id`, `identifier`, `name`,  `timezone_id`, `country_id`, `joined_date`, `created_date`, `lastmodified_date`, `oltp_id`, `report_id` )
VALUES (2, 'gazelle1', 'Tenant1 for Gazelle', 'Asia/Kolkata', NULL, NULL, NULL, NULL, 2, 2 );
