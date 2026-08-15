-- ============================================================================
-- Review / Feedback system migration
-- ============================================================================
-- Target DB: SmartPhone store
-- App tables are created without AUTO_INCREMENT on INT PKs, so this file
-- keeps that convention. Apply with the same MySQL user that owns the schema.
-- ============================================================================

-- 1. Add TransactionID to Feedback so we can tie a review to the order that
--    authorised it (and lock ownership to the buyer). Safe to re-run.
SET @col_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Feedback'
                      AND COLUMN_NAME = 'TransactionID');
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE `Feedback` ADD COLUMN `TransactionID` INT NULL AFTER `ProductVariantID`',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2. FK Feedback.TransactionID -> Transaction.ID (defensive; ignore if existed).
SET @fk_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
                   WHERE CONSTRAINT_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'Feedback'
                     AND CONSTRAINT_NAME = 'fk_Feedback_TransactionID');
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE `Feedback` ADD CONSTRAINT `fk_Feedback_TransactionID`
        FOREIGN KEY (`TransactionID`) REFERENCES `Transaction` (`ID`)
        ON DELETE CASCADE ON UPDATE CASCADE',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3. One review per (user, variant, transaction). Drops the duplicates that
--    slipped in before the constraint existed.
SET @idx_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Feedback'
                      AND INDEX_NAME = 'uq_Feedback_user_variant_tx');
SET @sql := IF(@idx_exists = 0,
    'ALTER TABLE `Feedback` ADD CONSTRAINT `uq_Feedback_user_variant_tx`
        UNIQUE (`UserID`, `ProductVariantID`, `TransactionID`)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 4. Soft-delete flag so a customer can withdraw their review without
--    breaking the manager's reply history.
SET @col_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Feedback'
                      AND COLUMN_NAME = 'IsDeleted');
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE `Feedback` ADD COLUMN `IsDeleted` TINYINT(1) NOT NULL DEFAULT 0 AFTER `Updated_at`',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 5. Helpful index for product-detail lookups by variant.
SET @idx_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Feedback'
                      AND INDEX_NAME = 'idx_Feedback_variant_created');
SET @sql := IF(@idx_exists = 0,
    'CREATE INDEX `idx_Feedback_variant_created`
        ON `Feedback` (`ProductVariantID`, `Created_at`)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 6. Helpful index for manager replies by feedback.
SET @idx_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Answer'
                      AND INDEX_NAME = 'idx_Answer_feedback_created');
SET @sql := IF(@idx_exists = 0,
    'CREATE INDEX `idx_Answer_feedback_created`
        ON `Answer` (`FeedbackID`, `Created_at`)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
