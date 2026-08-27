-- =====================================================
-- Chat / Support Conversation System
-- =====================================================
-- Customer ↔ Manager realtime chat (support/inquiry)
-- Không gắn với đơn hàng cụ thể.
-- Tái sử dụng polling mechanism từ complaint-realtime.js
-- =====================================================

-- Bảng Conversation: mỗi customer bắt đầu 1 conversation
CREATE TABLE IF NOT EXISTS `Conversation` (
    `ID`            INT          AUTO_INCREMENT PRIMARY KEY,
    `UserID`        INT          NOT NULL,
    `Status`        VARCHAR(30)  NOT NULL DEFAULT 'OPEN',   -- OPEN | IN_PROGRESS | CLOSED
    `LastMessage`   VARCHAR(500) NULL,
    `LastMessageAt` DATETIME     NULL,
    `AssignedTo`    INT          NULL,                        -- Staff/Manager assigned
    `ClosedBy`      INT          NULL,
    `ClosedAt`      DATETIME     NULL,
    `LastReadByManagerAt` DATETIME NULL,                      -- Manager lần cuối đọc (để tính unread badge)
    `CreatedAt`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `idx_Conversation_UserID_Open` (`UserID`, `Status`),
    KEY `idx_Conversation_AssignedTo` (`AssignedTo`),
    KEY `idx_Conversation_Status` (`Status`),
    KEY `idx_Conversation_LastMessageAt` (`LastMessageAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng ChatMessage: tin nhắn trong conversation
CREATE TABLE IF NOT EXISTS `ChatMessage` (
    `ID`             INT      AUTO_INCREMENT PRIMARY KEY,
    `ConversationID` INT      NOT NULL,
    `SenderID`       INT      NOT NULL,
    `SenderRole`     VARCHAR(30) NOT NULL,   -- CUSTOMER | STAFF | MANAGER | ADMIN
    `Content`        VARCHAR(2000) NOT NULL,
    `CreatedAt`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY `idx_ChatMessage_ConversationID_Created` (`ConversationID`, `CreatedAt`),
    KEY `idx_ChatMessage_SenderID` (`SenderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Permissions
INSERT IGNORE INTO `Permission` (`ID`, `Name`, `Description`) VALUES
    (33, 'CHAT_VIEW', 'View and manage chat conversations (Staff/Manager)'),
    (34, 'CHAT_MANAGE', 'Reply and close chat conversations (Staff/Manager)');

-- Gán quyền cho Manager (RoleID=2)
INSERT IGNORE INTO `Role_Permission` (`RoleID`, `PermissionID`) VALUES
    (2, 33), (2, 34);

-- Gán quyền cho Staff (RoleID=3)
INSERT IGNORE INTO `Role_Permission` (`RoleID`, `PermissionID`) VALUES
    (3, 33), (3, 34);
