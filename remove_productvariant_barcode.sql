USE `database_swp391`;

ALTER TABLE `ProductVariant`
    DROP INDEX `uk_ProductVariant_Barcode`,
    DROP COLUMN `Barcode`;
