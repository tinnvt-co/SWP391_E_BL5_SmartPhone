-- =====================================================
-- Complaint Flow
-- =====================================================
-- Allows customers to file a complaint after an order is
-- DELIVERED but before they mark it COMPLETED. The complaint
-- is resolved through a chatbox thread between customer and
-- manager. Real-time delivery is handled separately by the
-- ComplaintRealtimeServlet.
--
-- A complaint blocks the COMPLETED action and unlocks the
-- review / refund flow only after the customer closes the
-- complaint (or after manager resolves it).
-- =====================================================

CREATE TABLE IF NOT EXISTS `Complaint` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `TransactionID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `Category` VARCHAR(50) NOT NULL,
  `CustomReason` VARCHAR(500) NULL,
  `Description` VARCHAR(2000) NULL,
  `Status` VARCHAR(50) NOT NULL DEFAULT 'OPEN',
  `Resolution` VARCHAR(50) NULL,
  `ResolutionNote` VARCHAR(1000) NULL,
  `Assigned_to` INT NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `Closed_at` TIMESTAMP NULL,
  `Closed_by` INT NULL,
  PRIMARY KEY (`ID`),
  KEY `idx_Complaint_TransactionID_Status` (`TransactionID`, `Status`),
  KEY `idx_Complaint_UserID` (`UserID`),
  KEY `idx_Complaint_Status` (`Status`),
  KEY `idx_Complaint_Assigned_to` (`Assigned_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ComplaintMessage` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `ComplaintID` INT NOT NULL,
  `SenderID` INT NOT NULL,
  `SenderRole` VARCHAR(20) NOT NULL,
  `Content` VARCHAR(2000) NOT NULL,
  `Created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_ComplaintMessage_ComplaintID_Created` (`ComplaintID`, `Created_at`),
  KEY `idx_ComplaintMessage_SenderID` (`SenderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Complaint`
  ADD CONSTRAINT `fk_Complaint_TransactionID`
  FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Complaint`
  ADD CONSTRAINT `fk_Complaint_UserID`
  FOREIGN KEY (`UserID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Complaint`
  ADD CONSTRAINT `fk_Complaint_Assigned_to`
  FOREIGN KEY (`Assigned_to`) REFERENCES `User` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `Complaint`
  ADD CONSTRAINT `fk_Complaint_Closed_by`
  FOREIGN KEY (`Closed_by`) REFERENCES `User` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `ComplaintMessage`
  ADD CONSTRAINT `fk_ComplaintMessage_ComplaintID`
  FOREIGN KEY (`ComplaintID`) REFERENCES `Complaint` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ComplaintMessage`
  ADD CONSTRAINT `fk_ComplaintMessage_SenderID`
  FOREIGN KEY (`SenderID`) REFERENCES `User` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Permissions for complaint flow.
INSERT INTO `Permisson` (`ID`, `Name`) VALUES
  (31, 'COMPLAINT_MANAGE'),
  (32, 'COMPLAINT_VIEW')
ON DUPLICATE KEY UPDATE `Name` = VALUES(`Name`);

-- Grant COMPLAINT_MANAGE to Manager (RoleID 2) and COMPLAINT_VIEW to Staff (RoleID 3).
INSERT IGNORE INTO `Permisson_Role` (`PermissonID`, `RoleID`) VALUES
  (31, 2),
  (32, 3);
