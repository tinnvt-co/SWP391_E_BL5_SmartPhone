USE `database_swp391`;

SET @OLD_SQL_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

-- Temporary values avoid collisions while every existing SKU is replaced.
UPDATE `ProductVariant`
SET `SKU` = CONCAT('TMP-SKU-', `ID`);

-- Final format: PV-[ProductID]-[ProductVariantID].
UPDATE `ProductVariant`
SET `SKU` = CONCAT(
    'PV-',
    `ProductID`,
    '-',
    `ID`
);

COMMIT;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;

SELECT `ID`, `ProductID`, `SKU`
FROM `ProductVariant`
ORDER BY `ID`;
