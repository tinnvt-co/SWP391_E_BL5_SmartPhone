CREATE DATABASE IF NOT EXISTS `database_swp391`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `database_swp391`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Category`;
DROP TABLE IF EXISTS `Product`;
DROP TABLE IF EXISTS `Inventory`;
DROP TABLE IF EXISTS `Brand`;
DROP TABLE IF EXISTS `Supplier`;
DROP TABLE IF EXISTS `Supplier_Product`;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS `Role`;
DROP TABLE IF EXISTS `Permisson`;
DROP TABLE IF EXISTS `Permisson_Role`;
DROP TABLE IF EXISTS `Wishlist`;
DROP TABLE IF EXISTS `Cart`;
DROP TABLE IF EXISTS `Transaction`;
DROP TABLE IF EXISTS `Transaction_Product`;
DROP TABLE IF EXISTS `Feedback`;
DROP TABLE IF EXISTS `Answer`;
DROP TABLE IF EXISTS `ReturnRequest`;
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
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Product` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(50) NOT NULL UNIQUE,
  `Description` VARCHAR(255) NULL,
  `Release_Year` INT NULL,
  `Rating` DECIMAL(2,1) NULL,
  `warranty_months` INT NOT NULL,
  `Barcode` VARCHAR(255) NOT NULL,
  `SKU` VARCHAR(255) NOT NULL,
  `Selling_price` DECIMAL(12,2) NOT NULL,
  `Latest_cost` DECIMAL(12,2) NOT NULL,
  `Image` VARCHAR(255) NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CategoryID` INT NOT NULL,
  `BrandID` INT NOT NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Inventory` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `ProductID` INT NOT NULL,
  `Amount` INT NOT NULL,
  `Min_amount` INT NULL,
  `Max_amount` INT NULL,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uk_Inventory_ProductID` (`ProductID`)
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
 
CREATE TABLE `Supplier_Product` (
  `SupplierID` INT NOT NULL,
  `ProductID` INT NOT NULL,
  PRIMARY KEY (`SupplierID`, `ProductID`)
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
  `ProductID` INT NOT NULL,
  PRIMARY KEY (`UserID`, `ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Cart` (
  `UserID` INT NOT NULL,
  `ProductID` INT NOT NULL,
  `Amount` INT NOT NULL,
  PRIMARY KEY (`UserID`, `ProductID`)
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
 
CREATE TABLE `Transaction_Product` (
  `TransactionID` INT NOT NULL,
  `ProductID` INT NOT NULL,
  `Amount` DECIMAL(12,2) NOT NULL,
  `Discount_rate` DECIMAL(5,2) NULL,
  `Discount_amount` DECIMAL(12,2) NULL,
  `Total` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`TransactionID`, `ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
CREATE TABLE `Feedback` (
  `ID` INT NOT NULL,
  `Rating` INT NOT NULL,
  `Content` VARCHAR(255) NOT NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `UserID` INT NOT NULL,
  `ProductID` INT NOT NULL,
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
 
CREATE TABLE `ReturnRequest_Product` (
  `ReturnRequestID` INT NOT NULL,
  `ProductID` INT NOT NULL,
  PRIMARY KEY (`ReturnRequestID`, `ProductID`)
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
ALTER TABLE `Inventory` ADD CONSTRAINT `fk_Inventory_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Supplier_Product` ADD CONSTRAINT `fk_Supplier_Product_SupplierID` FOREIGN KEY (`SupplierID`) REFERENCES `Supplier` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Supplier_Product` ADD CONSTRAINT `fk_Supplier_Product_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `User` ADD CONSTRAINT `fk_User_RoleID` FOREIGN KEY (`RoleID`) REFERENCES `Role` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Permisson_Role` ADD CONSTRAINT `fk_Permisson_Role_PermissonID` FOREIGN KEY (`PermissonID`) REFERENCES `Permisson` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Permisson_Role` ADD CONSTRAINT `fk_Permisson_Role_RoleID` FOREIGN KEY (`RoleID`) REFERENCES `Role` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Wishlist` ADD CONSTRAINT `fk_Wishlist_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Wishlist` ADD CONSTRAINT `fk_Wishlist_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Cart` ADD CONSTRAINT `fk_Cart_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Cart` ADD CONSTRAINT `fk_Cart_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_SupplierID` FOREIGN KEY (`SupplierID`) REFERENCES `Supplier` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_Updated_by` FOREIGN KEY (`Updated_by`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_ Reference_transactionID` FOREIGN KEY (`Reference_transactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction` ADD CONSTRAINT `fk_Transaction_DeliveryInfoID` FOREIGN KEY (`DeliveryInfoID`) REFERENCES `DeliveryInfo` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction_Product` ADD CONSTRAINT `fk_Transaction_Product_TransactionID` FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Transaction_Product` ADD CONSTRAINT `fk_Transaction_Product_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Feedback` ADD CONSTRAINT `fk_Feedback_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Feedback` ADD CONSTRAINT `fk_Feedback_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Answer` ADD CONSTRAINT `fk_Answer_FeedbackID` FOREIGN KEY (`FeedbackID`) REFERENCES `Feedback` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Answer` ADD CONSTRAINT `fk_Answer_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest` ADD CONSTRAINT `fk_ReturnRequest_UserID` FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest` ADD CONSTRAINT `fk_ReturnRequest_TransactionID` FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest_Product` ADD CONSTRAINT `fk_ReturnRequest_Product_ReturnRequestID` FOREIGN KEY (`ReturnRequestID`) REFERENCES `ReturnRequest` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ReturnRequest_Product` ADD CONSTRAINT `fk_ReturnRequest_Product_ProductID` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
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
CREATE INDEX `idx_Feedback_product_created` ON `Feedback` (`ProductID`, `Created_at`);
CREATE INDEX `idx_ReturnRequest_status` ON `ReturnRequest` (`Status`, `Created_at`);

INSERT INTO `Category` (`ID`, `Name`, `Description`, `Status`) VALUES
(1, 'Smartphone', 'Mobile phones and smartphones', 'ACTIVE'),
(2, 'Accessory', 'Phone accessories', 'ACTIVE'),
(3, 'Tablet', 'Tablet devices', 'ACTIVE');

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

INSERT INTO `Product` (`ID`, `Name`, `Description`, `Release_Year`, `Rating`, `warranty_months`, `Barcode`, `SKU`, `Selling_price`, `Latest_cost`, `Image`, `CategoryID`, `BrandID`, `Status`) VALUES
(1, 'iPhone 15 Pro Max 256GB', 'Apple flagship smartphone', 2023, 5, 12, '893000000001', 'IP15PM-256-TITAN', 29990000, 26000000, '/assets/images/products/iphone-15-pro-max.jpg', 1, 1, 'ACTIVE'),
(2, 'Samsung Galaxy S24 Ultra 256GB', 'Samsung flagship smartphone', 2024, 5, 12, '893000000002', 'SSS24U-256-BLACK', 26990000, 23000000, '/assets/images/products/samsung-galaxy-s24-ultra.jpg', 1, 2, 'ACTIVE'),
(3, 'Xiaomi 14 256GB', 'Xiaomi high performance smartphone', 2024, 4, 12, '893000000003', 'XIAOMI14-256-BLACK', 18990000, 16000000, '/assets/images/products/xiaomi-14.jpg', 1, 3, 'ACTIVE'),
(4, 'Oppo Reno 11 5G', 'Oppo camera phone', 2024, 4, 12, '893000000004', 'OPPORENO11-256-GREEN', 10990000, 9000000, '/assets/images/products/oppo-reno-11.jpg', 1, 4, 'ACTIVE'),
(5, 'AirPods Pro 2', 'Apple wireless earbuds', 2023, 5, 12, '893000000005', 'AIRPODSPRO2-WHITE', 5990000, 4700000, '/assets/images/products/airpods-pro-2.jpg', 2, 1, 'ACTIVE');

INSERT INTO `Inventory` (`ID`, `ProductID`, `Amount`, `Min_amount`, `Max_amount`, `Status`) VALUES
(1, 1, 20, 5, 100, 'ACTIVE'),
(2, 2, 15, 5, 100, 'ACTIVE'),
(3, 3, 30, 5, 100, 'ACTIVE'),
(4, 4, 25, 5, 100, 'ACTIVE'),
(5, 5, 40, 10, 150, 'ACTIVE');

INSERT INTO `Supplier_Product` (`SupplierID`, `ProductID`) VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (3, 5);

INSERT INTO `Cart` (`UserID`, `ProductID`, `Amount`) VALUES
(4, 1, 1),
(4, 5, 2);

INSERT INTO `Wishlist` (`UserID`, `ProductID`) VALUES
(4, 2),
(4, 3),
(6, 1);

INSERT INTO `Transaction` (`ID`, `UserID`, `Total_price`, `Type`, `Status`, `SupplierID`, `Paid_amount`, `Change_amount`, `Method`, `Updated_by`, `Reference_transactionID`) VALUES
(1, 4, 32980000, 'ORDER', 'PAID', NULL, 32980000, 0, 'BANK_TRANSFER', 3, NULL),
(2, 6, 26990000, 'ORDER', 'CANCEL_REQUESTED', NULL, 26990000, 0, 'VNPAY', 3, NULL),
(3, 2, 134950000, 'IMPORT', 'COMPLETED', 1, 134950000, 0, 'BANK_TRANSFER', 2, NULL),
(4, 6, 26990000, 'REFUND', 'PENDING', NULL, 0, 0, 'ORIGINAL_PAYMENT', 2, 2);

INSERT INTO `Transaction_Product` (`TransactionID`, `ProductID`, `Amount`, `Discount_rate`, `Discount_amount`, `Total`) VALUES
(1, 1, 1, 10, 2999000, 26991000),
(1, 5, 1, 0, 0, 5990000),
(2, 2, 1, 5, 1349500, 25640500),
(3, 1, 5, 0, 0, 130000000),
(3, 5, 1, 0, 0, 4700000),
(4, 2, 1, 0, 0, 26990000);

INSERT INTO `DeliveryInfo` (`ID`, `UserID`, `Recipient_name`, `Recipient_phone`, `Delivery_address`, `Status`) VALUES
(1, 4, 'Demo Customer', '0900000004', 'Thu Duc, Ho Chi Minh City', 'ACTIVE'),
(2, 6, 'Chị Kim Tuyến', '0900000303', 'Quan 7, Ho Chi Minh City', 'ACTIVE');

INSERT INTO `Feedback` (`ID`, `Rating`, `Content`, `UserID`, `ProductID`) VALUES
(1, 5, 'Máy đẹp, chạy mượt, pin tốt.', 4, 1),
(2, 4, 'ốp này có đồ cầm ở sau lưng phải không', 6, 5);

INSERT INTO `Answer` (`ID`, `FeedbackID`, `Content`, `UserID`) VALUES
(1, 1, 'Cảm ơn bạn đã tin tưởng shop.', 2),
(2, 2, 'Chào chị Tuyến, dạ shop kiểm tra và liên hệ mình qua sdt *****303 trong 60p ạ.', 2);

INSERT INTO `ReturnRequest` (`ID`, `Status`, `Description`, `Image`, `UserID`, `TransactionID`) VALUES
(1, 'REQUESTED', 'Khách đã thanh toán và muốn hủy đơn trước khi giao hàng.', NULL, 6, 2);

INSERT INTO `ReturnRequest_Product` (`ReturnRequestID`, `ProductID`) VALUES
(1, 2);
