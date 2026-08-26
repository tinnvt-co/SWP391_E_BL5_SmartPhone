-- =====================================================
-- Cancel Order Request Flow
-- =====================================================
-- Allows customers to request cancellation of an order while it has
-- not yet been delivered. Staff approves/rejects the request.
-- =====================================================

CREATE TABLE IF NOT EXISTS `CancelRequest` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `TransactionID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `Reason` VARCHAR(100) NOT NULL,
  `CustomReason` VARCHAR(500) NULL,
  `BankName` VARCHAR(80) NULL,
  `BankAccountNumber` VARCHAR(40) NULL,
  `BankAccountHolder` VARCHAR(80) NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  `StaffNote` VARCHAR(500) NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Processed_by` INT NULL,
  `Processed_at` TIMESTAMP NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_CancelRequest_Transaction_Active` (`TransactionID`, `Status`),
  KEY `idx_CancelRequest_UserID` (`UserID`),
  KEY `idx_CancelRequest_Status` (`Status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `CancelRequest`
  ADD CONSTRAINT `fk_CancelRequest_TransactionID`
  FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `CancelRequest`
  ADD CONSTRAINT `fk_CancelRequest_UserID`
  FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `CancelRequest`
  ADD CONSTRAINT `fk_CancelRequest_Processed_by`
  FOREIGN KEY (`Processed_by`) REFERENCES `User` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE;
