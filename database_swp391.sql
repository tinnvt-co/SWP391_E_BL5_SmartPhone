CREATE DATABASE IF NOT EXISTS `database_swp391`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 -- DROP DATABASE `database_swp391`
USE `database_swp391`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Category`;
DROP TABLE IF EXISTS `ProductVariant`;
DROP TABLE IF EXISTS `Product`;
DROP TABLE IF EXISTS `Inventory`;
DROP TABLE IF EXISTS `Brand`;
DROP TABLE IF EXISTS `Supplier`;
DROP TABLE IF EXISTS `Supplier_ProductVariant`;
DROP TABLE IF EXISTS `Supplier_Product`;
DROP TABLE IF EXISTS `PasswordResetToken`;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS `Role`;
DROP TABLE IF EXISTS `Permisson`;
DROP TABLE IF EXISTS `Permisson_Role`;
DROP TABLE IF EXISTS `Wishlist`;
DROP TABLE IF EXISTS `Cart`;
DROP TABLE IF EXISTS `Transaction`;
DROP TABLE IF EXISTS `Transaction_ProductVariant`;
DROP TABLE IF EXISTS `Transaction_Product`;
DROP TABLE IF EXISTS `Feedback`;
DROP TABLE IF EXISTS `Answer`;
DROP TABLE IF EXISTS `ReturnRequest`;
DROP TABLE IF EXISTS `ReturnRequest_ProductVariant`;
DROP TABLE IF EXISTS `ReturnRequest_Product`;
DROP TABLE IF EXISTS `DeliveryInfo`;
DROP TABLE IF EXISTS `Discount`;
DROP TABLE IF EXISTS `Discount_Product`;
DROP TABLE IF EXISTS `TransactionStatusHistory`;
DROP TABLE IF EXISTS `DeliveryStatusHistory`;

CREATE TABLE `Category` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(25) NOT NULL,
  `Description` VARCHAR(255) NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_Category_Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Product` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(50) NOT NULL UNIQUE,
  `Description` VARCHAR(255) NULL,
  `Release_Year` INT NULL,
  `Rating` DECIMAL(2,1) NULL,
  `warranty_months` INT NOT NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CategoryID` INT NOT NULL,
  `BrandID` INT NOT NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `ProductVariant` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `ProductID` INT NOT NULL,
  `RAM_GB` INT NOT NULL,
  `Storage_GB` INT NOT NULL,
  `ColorName` VARCHAR(50) NOT NULL,
  `ColorHex` VARCHAR(7) NOT NULL,
  `Barcode` VARCHAR(255) NOT NULL,
  `SKU` VARCHAR(255) NOT NULL,
  `Selling_price` DECIMAL(12,2) NOT NULL,
  `Latest_cost` DECIMAL(12,2) NOT NULL,
  `Image` VARCHAR(255) NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_ProductVariant_option` (`ProductID`, `RAM_GB`, `Storage_GB`, `ColorName`),
  UNIQUE KEY `uk_ProductVariant_Image` (`Image`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Inventory` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `ProductVariantID` INT NOT NULL,
  `Amount` INT NOT NULL,
  `Min_amount` INT NULL,
  `Max_amount` INT NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_Inventory_VariantID` (`ProductVariantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Brand` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(50) NOT NULL,
  `Description` VARCHAR(255) NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Supplier` (
  `ID` INT NOT NULL,
  `Name` VARCHAR(50) NOT NULL,
  `Address` VARCHAR(255) NOT NULL,
  `Phone` VARCHAR(255) NOT NULL,
  `Description` VARCHAR(255) NULL,
  `Note` VARCHAR(255) NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Supplier_ProductVariant` (
  `SupplierID` INT NOT NULL,
  `ProductVariantID` INT NOT NULL,
  PRIMARY KEY (`SupplierID`, `ProductVariantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 

CREATE TABLE `User` (
  `ID` INT NOT NULL,
  `Username` VARCHAR(255) NOT NULL,
  `Password` VARCHAR(20) NOT NULL,
  `Name` VARCHAR(255) NOT NULL,
  `Phone` VARCHAR(255) NOT NULL,
  `Address` VARCHAR(255) NOT NULL,
  `Image` VARCHAR(255) NULL,
  `Age` INT NULL,
  `Email` VARCHAR(255) NOT NULL,
  `RoleID` INT NOT NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `PasswordResetToken` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `UserID` INT NOT NULL,
  `Token` VARCHAR(64) NOT NULL,
  `Expires_at` DATETIME NOT NULL,
  `Used_at` DATETIME NULL,
  `Created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_PasswordResetToken_Token` (`Token`),
  KEY `idx_PasswordResetToken_UserID` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Role` (
  `ID` INT NOT NULL,
  `Name` VARCHAR(255) NOT NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Permisson` (
  `ID` INT NOT NULL,
  `Name`VARCHAR(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 

CREATE TABLE `Permisson_Role` (
  `PermissonID` INT NOT NULL,
  `RoleID` INT NOT NULL,
  PRIMARY KEY (`PermissonID`, `RoleID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Wishlist` (
  `UserID` INT NOT NULL,
  `ProductVariantID` INT NOT NULL,
  PRIMARY KEY (`UserID`, `ProductVariantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Cart` (
  `UserID` INT NOT NULL,
  `ProductVariantID` INT NOT NULL,
  `Amount` INT NOT NULL,
  PRIMARY KEY (`UserID`, `ProductVariantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Transaction` (
  `ID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `Total_price` DECIMAL(12,2) NOT NULL,
  `Type` VARCHAR(255) NOT NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  `SupplierID` INT NULL,
  `Paid_amount` DECIMAL(12,2) NULL,
  `Change_amount` DECIMAL(12,2) NULL,
  `Method` VARCHAR(255) NOT NULL,
  `Updated_by` INT NOT NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Reference_transactionID` INT,
  `DeliveryInfoID` INT,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Transaction_ProductVariant` (
  `TransactionID` INT NOT NULL,
  `ProductVariantID` INT NOT NULL,
  `Amount` INT NOT NULL,
  `UnitPrice` DECIMAL(12,2) NOT NULL,
  `Discount_rate` DECIMAL(5,2) NULL,
  `Discount_amount` DECIMAL(12,2) NULL,
  `Total` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`TransactionID`, `ProductVariantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Feedback` (
  `ID` INT NOT NULL,
  `Rating` INT NOT NULL,
  `Content` VARCHAR(255) NOT NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `UserID` INT NOT NULL,
  `ProductVariantID` INT NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Answer` (
  `ID` INT NOT NULL,
  `FeedbackID` INT NOT NULL,
  `Content` VARCHAR(255) NOT NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UserID` INT NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `ReturnRequest` (
  `ID` INT NOT NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  `Description` VARCHAR(255) NOT NULL,
  `Image` VARCHAR(255) NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UserID` INT NOT NULL,
  `TransactionID` INT NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `ReturnRequest_ProductVariant` (
  `ReturnRequestID` INT NOT NULL,
  `ProductVariantID` INT NOT NULL,
  PRIMARY KEY (`ReturnRequestID`, `ProductVariantID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `DeliveryInfo` (
  `ID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `Recipient_name` VARCHAR(255) NOT NULL,
  `Recipient_phone` VARCHAR(255) NOT NULL,
  `Delivery_address` VARCHAR(255) NOT NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Discount` (
  `ID` INT NOT NULL,
  `Name` VARCHAR(255) NULL,
  `Description` VARCHAR(255) NULL,
  `Rate` DECIMAL(10,2) NOT NULL,
  `Start` TIMESTAMP NOT NULL,
  `End` TIMESTAMP NOT NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 

CREATE TABLE `Discount_Product` (
  `DiscountID` INT NOT NULL,
  `ProductID` INT NOT NULL,
  PRIMARY KEY (`DiscountID`, `ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 

CREATE TABLE `TransactionStatusHistory` (
  `ID` INT NOT NULL,
  `TransactionID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `Updated_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 

CREATE TABLE `DeliveryStatusHistory` (
  `ID` INT NOT NULL,
  `Updated_at` TIMESTAMP NOT NULL,
  `UserID` INT NOT NULL,
  `DeliveryInfoID` INT NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- =====================================================
-- FOREIGN KEY CONSTRAINTS
-- =====================================================
 
ALTER TABLE `Product` ADD CONSTRAINT `fk_Product_CategoryID` FOREIGN KEY (`CategoryID`) REFERENCES `Category` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Product` ADD CONSTRAINT `fk_Product_BrandID` FOREIGN KEY (`BrandID`) REFERENCES `Brand` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ProductVariant` ADD CONSTRAINT `fk_ProductVariant_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Inventory` ADD CONSTRAINT `fk_Inventory_VariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Supplier_ProductVariant` ADD CONSTRAINT `fk_Supplier_ProductVariant_SupplierID` FOREIGN KEY (`SupplierID`) REFERENCES `Supplier` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Supplier_ProductVariant` ADD CONSTRAINT `fk_Supplier_ProductVariant_ProductVariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `User` ADD CONSTRAINT `fk_User_RoleID` FOREIGN KEY (`RoleID`) REFERENCES `Role` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `PasswordResetToken` ADD CONSTRAINT `fk_PasswordResetToken_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Permisson_Role` ADD CONSTRAINT `fk_Permisson_Role_PermissonID` FOREIGN KEY (`PermissonID`) REFERENCES `Permisson` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Permisson_Role` ADD CONSTRAINT `fk_Permisson_Role_RoleID` FOREIGN KEY (`RoleID`) REFERENCES `Role` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Wishlist` ADD CONSTRAINT `fk_Wishlist_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Wishlist` ADD CONSTRAINT `fk_Wishlist_ProductVariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Cart` ADD CONSTRAINT `fk_Cart_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Cart` ADD CONSTRAINT `fk_Cart_ProductVariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_SupplierID` FOREIGN KEY (`SupplierID`) REFERENCES `Supplier` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_Updated_by` FOREIGN KEY (`Updated_by`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_ Reference_transactionID` FOREIGN KEY (`Reference_transactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_DeliveryInfoID` FOREIGN KEY (`DeliveryInfoID`) REFERENCES `DeliveryInfo` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction_ProductVariant` ADD CONSTRAINT `fk_Transaction_ProductVariant_TransactionID` FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction_ProductVariant` ADD CONSTRAINT `fk_Transaction_ProductVariant_ProductVariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE `Feedback` ADD CONSTRAINT `fk_Feedback_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Feedback` ADD CONSTRAINT `fk_Feedback_ProductVariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Answer` ADD CONSTRAINT `fk_Answer_FeedbackID` FOREIGN KEY (`FeedbackID`) REFERENCES `Feedback` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Answer` ADD CONSTRAINT `fk_Answer_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest` ADD CONSTRAINT `fk_ReturnRequest_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest` ADD CONSTRAINT `fk_ReturnRequest_TransactionID` FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest_ProductVariant` ADD CONSTRAINT `fk_ReturnRequest_ProductVariantID_ReturnRequestID` FOREIGN KEY (`ReturnRequestID`) REFERENCES `ReturnRequest` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest_ProductVariant` ADD CONSTRAINT `fk_ReturnRequest_ProductVariantID_ProductVariantID` FOREIGN KEY (`ProductVariantID`) REFERENCES `ProductVariant` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE `DeliveryInfo` ADD CONSTRAINT `fk_DeliveryInfo_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Discount_Product` ADD CONSTRAINT `fk_Discount_Product_DiscountID` FOREIGN KEY (`DiscountID`) REFERENCES `Discount` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Discount_Product` ADD CONSTRAINT `fk_Discount_Product_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `TransactionStatusHistory` ADD CONSTRAINT `fk_TransactionStatusHistory_TransactionID` FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `TransactionStatusHistory` ADD CONSTRAINT `fk_TransactionStatusHistory_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `DeliveryStatusHistory` ADD CONSTRAINT `fk_DeliveryStatusHistory_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `DeliveryStatusHistory` ADD CONSTRAINT `fk_DeliveryStatusHistory_DeliveryInfoID` FOREIGN KEY (`DeliveryInfoID`) REFERENCES `DeliveryInfo` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
 
SET FOREIGN_KEY_CHECKS = 1;

CREATE INDEX `idx_Product_category_status` ON `Product` (`CategoryID`, `Status`);
CREATE INDEX `idx_Product_brand_status` ON `Product` (`BrandID`, `Status`);
CREATE INDEX `idx_Transaction_user_status` ON `Transaction` (`UserID`, `Status`);
CREATE INDEX `idx_Feedback_productVatiant_created` ON `Feedback` (`ProductVariantID`, `Created_at`);
CREATE INDEX `idx_ReturnRequest_status` ON `ReturnRequest` (`Status`, `Created_at`);

INSERT INTO `Category` (`ID`, `Name`, `Description`, `Status`) VALUES
(1, 'High-end', 'Phones priced from 20,000,000 VND', 'ACTIVE'),
(2, 'Upper mid-range', 'Phones priced from 13,000,000 to under 20,000,000 VND', 'ACTIVE'),
(3, 'Mid-range', 'Phones priced from 7,000,000 to under 13,000,000 VND', 'ACTIVE'),
(4, 'Budget', 'Phones priced under 7,000,000 VND', 'ACTIVE');

INSERT INTO `Brand` (`ID`, `Name`, `Description`, `Status`) VALUES
(1, 'Apple', 'Apple iPhone and iPad products', 'ACTIVE'),
(2, 'Samsung', 'Samsung Galaxy products', 'ACTIVE'),
(3, 'Xiaomi', 'Xiaomi smartphone products', 'ACTIVE'),
(4, 'Oppo', 'Oppo smartphone products', 'ACTIVE');

INSERT INTO `Supplier` (`ID`, `Name`, `Address`, `Phone`, `Description`, `Note`, `Status`) VALUES
(1, 'FPT Trading', 'Ho Chi Minh City', '02873002345', 'Official smartphone distributor', 'Main supplier', 'ACTIVE'),
(2, 'Digiworld', 'Ha Noi', '02473002345', 'Mobile device supplier', 'Backup supplier', 'ACTIVE'),
(3, 'Petrosetco', 'Da Nang', '023673002345', 'Accessory and device supplier', 'Regional supplier', 'ACTIVE');

INSERT INTO `Role` (`ID`, `Name`, `Status`) VALUES
(1, 'Admin', 'ACTIVE'),
(2, 'Manager', 'ACTIVE'),
(3, 'Staff', 'ACTIVE'),
(4, 'Customer', 'ACTIVE'),
(5, 'Shipper', 'ACTIVE');

INSERT INTO `Permisson` (`ID`, `Name`) VALUES
(1, 'USER_VIEW_LIST'),
(2, 'USER_TOGGLE_STATUS'),
(3, 'ROLE_VIEW_LIST'),
(4, 'ROLE_VIEW_PERMISSIONS'),
(5, 'ROLE_UPDATE'),
(6, 'ROLE_TOGGLE_STATUS'),
(7, 'ROLE_EDIT_PERMISSIONS'),
(8, 'PRODUCT_MANAGE'),
(9, 'CATEGORY_MANAGE'),
(10, 'BRAND_MANAGE'),
(11, 'INVENTORY_MANAGE'),
(12, 'DISCOUNT_MANAGE'),
(13, 'SALES_STATS_VIEW'),
(14, 'REVENUE_VIEW'),
(15, 'ORDER_STATS_VIEW'),
(16, 'ORDER_VIEW'),
(17, 'ORDER_UPDATE_STATUS'),
(18, 'SUPPLIER_MANAGE'),
(19, 'REFUND_MANAGE'),
(20, 'FEEDBACK_REPLY'),
(21, 'PROFILE_UPDATE'),
(22, 'WISHLIST_MANAGE'),
(23, 'CHECKOUT'),
(24, 'ORDER_HISTORY_VIEW'),
(25, 'FEEDBACK_SEND'),
(26, 'FEEDBACK_VIEW'),
(27, 'DELIVERY_STATUS_VIEW'),
(28, 'ORDER_CANCEL'),
(29, 'DELIVERY_ORDER_VIEW'),
(30, 'DELIVERY_STATUS_UPDATE');

INSERT INTO `Permisson_Role` (`PermissonID`, `RoleID`) VALUES
(1,1),(2,1),(3,1),(4,1),(5,1),(6,1),(7,1),
(8,2),(9,2),(10,2),(11,2),(12,2),(13,2),(14,2),(15,2),(16,2),(18,2),(19,2),(20,2),
(16,3),(17,3),(20,3),
(21,4),(22,4),(23,4),(24,4),(25,4),(26,4),(27,4),(28,4),
(29,5),(30,5);

INSERT INTO `User` (`ID`, `Username`, `Password`, `Name`, `Phone`, `Address`, `Image`, `Age`, `Email`, `RoleID`, `Status`) VALUES
(1, 'admin', '123456', 'System Admin', '0900000001', 'Ho Chi Minh City', NULL, 30, 'admin@swp.com', 1, 'ACTIVE'),
(2, 'manager', '123456', 'Store Manager', '0900000002', 'Ha Noi', NULL, 32, 'manager@swp.com', 2, 'ACTIVE'),
(3, 'staff', '123456', 'Order Staff', '0900000003', 'Da Nang', NULL, 25, 'staff@swp.com', 3, 'ACTIVE'),
(4, 'customer', '123456', 'Demo Customer', '0900000004', 'Thu Duc, Ho Chi Minh City', NULL, 22, 'customer@swp.com', 4, 'ACTIVE'),
(5, 'shipper', '123456', 'Demo Shipper', '0900000005', 'Binh Thanh, Ho Chi Minh City', NULL, 28, 'shipper@swp.com', 5, 'ACTIVE'),
(6, 'kimtuyen', '123456', 'Chị Kim Tuyến', '0900000303', 'Quan 7, Ho Chi Minh City', NULL, 29, 'kimtuyen@example.com', 4, 'ACTIVE');

INSERT INTO `Product` (`ID`, `Name`, `Description`, `Release_Year`, `Rating`, `warranty_months`, `CategoryID`, `BrandID`, `Status`) VALUES
(1, 'iPhone 15 Pro Max', 'Apple flagship smartphone', 2023, 5, 12, 1, 1, 'ACTIVE'),
(2, 'Samsung Galaxy S24 Ultra', 'Samsung flagship smartphone', 2024, 5, 12, 1, 2, 'ACTIVE'),
(3, 'Xiaomi 14', 'Xiaomi high performance smartphone', 2024, 4, 12, 2, 3, 'ACTIVE'),
(4, 'Oppo Reno 11 5G', 'Oppo camera phone', 2024, 4, 12, 3, 4, 'ACTIVE'),
(5, 'iPhone 14', 'Apple smartphone with selectable memory and colors', 2022, 5, 12, 2, 1, 'ACTIVE');

INSERT INTO `Product` (`ID`, `Name`, `Description`, `Release_Year`, `Rating`, `warranty_months`, `CategoryID`, `BrandID`, `Status`)
WITH RECURSIVE `Sequence50` AS (
  SELECT 1 AS `Number`
  UNION ALL SELECT `Number` + 1 FROM `Sequence50` WHERE `Number` < 50
),
`SeedBrand` AS (
  SELECT 1 AS `BrandID`, 'Apple' AS `BrandName`
  UNION ALL SELECT 2, 'Samsung'
  UNION ALL SELECT 3, 'Xiaomi'
  UNION ALL SELECT 4, 'OPPO'
)
SELECT 5 + ((`SeedBrand`.`BrandID` - 1) * 50) + `Sequence50`.`Number`,
  CONCAT(`SeedBrand`.`BrandName`, ' Phone ', LPAD(`Sequence50`.`Number`, 2, '0')),
  CONCAT(`SeedBrand`.`BrandName`, ' smartphone with selectable memory and colors'),
  2022 + (`Sequence50`.`Number` MOD 5), 4 + (`Sequence50`.`Number` MOD 2), 12,
  CASE
    WHEN `SeedBrand`.`BrandID` = 1 THEN 1
    WHEN `SeedBrand`.`BrandID` = 2 THEN 1
    WHEN `SeedBrand`.`BrandID` = 3 THEN 2
    ELSE 3
  END,
  `SeedBrand`.`BrandID`, 'ACTIVE'
FROM `SeedBrand` CROSS JOIN `Sequence50`;

INSERT INTO `ProductVariant`
(`ProductID`, `RAM_GB`, `Storage_GB`, `ColorName`, `ColorHex`, `Barcode`, `SKU`, `Selling_price`, `Latest_cost`, `Image`, `Status`)
WITH
`MemoryOption` AS (
  SELECT 1 AS `OptionNo`, 8 AS `RAM_GB`, 128 AS `Storage_GB`, 0 AS `ExtraPrice`
  UNION ALL SELECT 2, 12, 256, 2500000
  UNION ALL SELECT 3, 12, 512, 5000000
),
`ColorOption` AS (
  SELECT 'Black' AS `ColorName`, '#24262B' AS `ColorHex`
  UNION ALL SELECT 'Silver', '#D7D8DA'
  UNION ALL SELECT 'Blue', '#6F89A8'
  UNION ALL SELECT 'Pink', '#D8A7B1'
)
SELECT p.ID, m.RAM_GB, m.Storage_GB, c.ColorName, c.ColorHex,
  CONCAT('894', LPAD(p.ID, 3, '0'), LPAD(m.RAM_GB, 2, '0'), LPAD(m.Storage_GB, 3, '0'),
         LPAD(m.OptionNo, 2, '0'), UPPER(c.ColorName)),
  CONCAT(
    CASE p.BrandID WHEN 1 THEN 'APL' WHEN 2 THEN 'SAM' WHEN 3 THEN 'XIA' ELSE 'OPP' END,
    '-', p.ID, '-', m.RAM_GB, 'R-', m.Storage_GB, 'G-', UPPER(c.ColorName)
  ),
  CASE p.ID
    WHEN 1 THEN 29990000
    WHEN 2 THEN 26990000
    WHEN 3 THEN 18990000
    WHEN 4 THEN 10990000
    WHEN 5 THEN 15990000
    ELSE
      CASE p.BrandID
        WHEN 1 THEN 15990000
        WHEN 2 THEN 11990000
        WHEN 3 THEN 7990000
        ELSE 5990000
      END
  END + m.ExtraPrice,
  FLOOR((
    CASE p.ID
      WHEN 1 THEN 29990000
      WHEN 2 THEN 26990000
      WHEN 3 THEN 18990000
      WHEN 4 THEN 10990000
      WHEN 5 THEN 15990000
      ELSE
        CASE p.BrandID
          WHEN 1 THEN 15990000
          WHEN 2 THEN 11990000
          WHEN 3 THEN 7990000
          ELSE 5990000
        END
    END + m.ExtraPrice
  ) * 0.82),
  CASE
    WHEN p.ID BETWEEN 1 AND 5 THEN CONCAT(
      CASE p.ID
        WHEN 1 THEN 'iphone-15-pro-max'
        WHEN 2 THEN 'samsung-galaxy-s24-ultra'
        WHEN 3 THEN 'xiaomi-14'
        WHEN 4 THEN 'oppo-reno-11'
        WHEN 5 THEN 'iphone-14'
      END,
      '-', LOWER(c.ColorName), '-', m.Storage_GB, 'gb.webp'
    )
    ELSE NULL
  END,
  'ACTIVE'
FROM `Product` p CROSS JOIN `MemoryOption` m CROSS JOIN `ColorOption` c;

INSERT INTO `Inventory` (`ProductVariantID`, `Amount`, `Min_amount`, `Max_amount`, `Status`)
SELECT pv.ID, 8 + ((pv.ProductID + pv.ID) MOD 13), 2, 50, 'ACTIVE'
FROM `ProductVariant` pv;

INSERT INTO `Supplier_ProductVariant` (`SupplierID`, `ProductVariantID`)
SELECT
  CASE pv.ProductID
    WHEN 1 THEN 1
    WHEN 2 THEN 1
    WHEN 3 THEN 2
    WHEN 4 THEN 2
    WHEN 5 THEN 3
  END,
  pv.ID
FROM `ProductVariant` pv
WHERE pv.ProductID BETWEEN 1 AND 5;

INSERT INTO `Cart` (`UserID`, `ProductVariantID`, `Amount`)
SELECT 4, pv.ID, 1 FROM `ProductVariant` pv
WHERE pv.ProductID=1 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Black'
UNION ALL
SELECT 4, pv.ID, 2 FROM `ProductVariant` pv
WHERE pv.ProductID=5 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Silver';

INSERT INTO `Wishlist` (`UserID`, `ProductVariantID`)
SELECT 4, pv.ID FROM `ProductVariant` pv
WHERE pv.ProductID=2 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Black'
UNION ALL
SELECT 4, pv.ID FROM `ProductVariant` pv
WHERE pv.ProductID=3 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Black'
UNION ALL
SELECT 6, pv.ID FROM `ProductVariant` pv
WHERE pv.ProductID=1 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Black';

INSERT INTO `Transaction` (`ID`, `UserID`, `Total_price`, `Type`, `Status`, `SupplierID`, `Paid_amount`, `Change_amount`, `Method`, `Updated_by`, `Reference_transactionID`) VALUES
(1, 4, 32980000, 'ORDER', 'PAID', NULL, 32980000, 0, 'BANK_TRANSFER', 3, NULL),
(2, 6, 26990000, 'ORDER', 'CANCEL_REQUESTED', NULL, 26990000, 0, 'VNPAY', 3, NULL),
(3, 2, 134950000, 'IMPORT', 'COMPLETED', 1, 134950000, 0, 'BANK_TRANSFER', 2, NULL),
(4, 6, 26990000, 'REFUND', 'PENDING', NULL, 0, 0, 'ORIGINAL_PAYMENT', 2, 2);

INSERT INTO `Transaction_ProductVariant` (`TransactionID`, `ProductVariantID`, `Amount`, `UnitPrice`, `Discount_rate`, `Discount_amount`, `Total`)
SELECT 1, pv.ID, 1, pv.Selling_price, 10, pv.Selling_price*0.10, pv.Selling_price*0.90 FROM `ProductVariant` pv WHERE pv.ProductID=1 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Black'
UNION ALL
SELECT 1, pv.ID, 1, pv.Selling_price, 0, 0, pv.Selling_price FROM `ProductVariant` pv WHERE pv.ProductID=5 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Silver'
UNION ALL
SELECT 2, pv.ID, 1, pv.Selling_price, 5, pv.Selling_price*0.05, pv.Selling_price*0.95 FROM `ProductVariant` pv WHERE pv.ProductID=2 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Blue'
UNION ALL
SELECT 3, pv.ID, 5, pv.Selling_price, 0, 0, pv.Selling_price*5 FROM `ProductVariant` pv WHERE pv.ProductID=1 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Black'
UNION ALL
SELECT 3, pv.ID, 1, pv.Selling_price, 0, 0, pv.Selling_price FROM `ProductVariant` pv WHERE pv.ProductID=5 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Black'
UNION ALL
SELECT 4, pv.ID, 1, pv.Selling_price, 0, 0, pv.Selling_price FROM `ProductVariant` pv WHERE pv.ProductID=2 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Blue';

INSERT INTO `DeliveryInfo` (`ID`, `UserID`, `Recipient_name`, `Recipient_phone`, `Delivery_address`, `Status`) VALUES
(1, 4, 'Demo Customer', '0900000004', 'Thu Duc, Ho Chi Minh City', 'ACTIVE'),
(2, 6, 'Chị Kim Tuyến', '0900000303', 'Quan 7, Ho Chi Minh City', 'ACTIVE');

INSERT INTO `Feedback` (`ID`, `Rating`, `Content`, `UserID`, `ProductVariantID`)
SELECT 1, 5, 'Máy đẹp, chạy mượt, pin tốt.', 4, pv.ID
FROM `ProductVariant` pv
WHERE pv.ProductID=1 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Black'
UNION ALL
SELECT 2, 4, 'Sản phẩm dùng tốt.', 6, pv.ID
FROM `ProductVariant` pv
WHERE pv.ProductID=5 AND pv.RAM_GB=8 AND pv.Storage_GB=128 AND pv.ColorName='Silver';

INSERT INTO `Answer` (`ID`, `FeedbackID`, `Content`, `UserID`) VALUES
(1, 1, 'Cảm ơn bạn đã tin tưởng shop.', 2),
(2, 2, 'Chào chị Tuyến, dạ shop kiểm tra và liên hệ mình qua sdt *****303 trong 60p ạ.', 2);

INSERT INTO `ReturnRequest` (`ID`, `Status`, `Description`, `Image`, `UserID`, `TransactionID`) VALUES
(1, 'REQUESTED', 'Khách đã thanh toán và muốn hủy đơn trước khi giao hàng.', NULL, 6, 2);

INSERT INTO `ReturnRequest_ProductVariant` (`ReturnRequestID`, `ProductVariantID`)
SELECT 1, pv.ID FROM `ProductVariant` pv
WHERE pv.ProductID=2 AND pv.RAM_GB=12 AND pv.Storage_GB=256 AND pv.ColorName='Blue';
