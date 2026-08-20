USE `database_swp391`;

ALTER TABLE `Brand`
ADD CONSTRAINT `uk_Brand_Name` UNIQUE (`Name`);
