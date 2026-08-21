-- Run this file once on an existing database_swp391 database.
USE `database_swp391`;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Product_Category`;

ALTER TABLE `Product`
  DROP FOREIGN KEY `fk_Product_CategoryID`;

DROP INDEX `idx_Product_category_status` ON `Product`;

ALTER TABLE `Product`
  DROP COLUMN `CategoryID`;

DELETE FROM `Category`;
ALTER TABLE `Category` AUTO_INCREMENT = 1;

INSERT INTO `Category` (`ID`, `Name`, `Description`, `Status`) VALUES
(1, 'AI Phone', 'Phones with AI-powered features', 'ACTIVE'),
(2, 'Gaming Phone', 'Phones optimized for mobile gaming', 'ACTIVE'),
(3, 'Foldable Phone', 'Foldable and flip smartphones', 'ACTIVE'),
(4, 'Camera Phone', 'Phones focused on camera quality', 'ACTIVE'),
(5, 'Long Battery Phone', 'Phones focused on long battery life', 'ACTIVE');

CREATE TABLE `Product_Category` (
  `ProductID` INT NOT NULL,
  `CategoryID` INT NOT NULL,
  PRIMARY KEY (`ProductID`, `CategoryID`),
  CONSTRAINT `fk_ProductCategory_ProductID`
    FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ProductCategory_CategoryID`
    FOREIGN KEY (`CategoryID`) REFERENCES `Category` (`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX `idx_ProductCategory_category_product`
  ON `Product_Category` (`CategoryID`, `ProductID`);

INSERT IGNORE INTO `Product_Category` (`ProductID`, `CategoryID`)
SELECT `ID`, 1 FROM `Product` WHERE `Release_Year` >= 2024;

INSERT IGNORE INTO `Product_Category` (`ProductID`, `CategoryID`)
SELECT `ID`, 2 FROM `Product`
WHERE `Name` REGEXP 'POCO|ROG|RedMagic|Black Shark|Gaming|GT';

INSERT IGNORE INTO `Product_Category` (`ProductID`, `CategoryID`)
SELECT `ID`, 3 FROM `Product`
WHERE `Name` REGEXP 'Fold|Flip|Find N|Mix Fold';

INSERT IGNORE INTO `Product_Category` (`ProductID`, `CategoryID`)
SELECT `ID`, 4 FROM `Product`
WHERE `Name` REGEXP 'Pro|Ultra|Find X|Note';

INSERT IGNORE INTO `Product_Category` (`ProductID`, `CategoryID`)
SELECT `ID`, 5 FROM `Product`
WHERE `Name` REGEXP 'Galaxy M|Galaxy A|Redmi|POCO|OPPO A';

SET FOREIGN_KEY_CHECKS = 1;
