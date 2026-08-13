-- Apply once on the live DB so Discount can use AUTO_INCREMENT.
-- Safe to re-run: each ALTER is idempotent via information_schema guard.

SET @needs_auto := (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'Discount' AND column_name = 'ID'
      AND extra NOT LIKE '%auto_increment%'
);
SET @sql := IF(@needs_auto > 0,
    'ALTER TABLE `Discount` MODIFY `ID` INT NOT NULL AUTO_INCREMENT',
    'SELECT "Discount.ID already auto_increment" AS msg');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @has_status := (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'Discount' AND column_name = 'Status'
);
SET @sql := IF(@has_status > 0,
    'ALTER TABLE `Discount` DROP COLUMN `Status`',
    'SELECT "Discount.Status already dropped" AS msg');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
