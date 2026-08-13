USE `database_swp391`;

INSERT INTO `Category` (`ID`, `Name`, `Description`, `Status`) VALUES
(1, 'High-end', 'Phones priced from 20,000,000 VND', 'ACTIVE'),
(2, 'Upper mid-range', 'Phones priced from 13,000,000 to under 20,000,000 VND', 'ACTIVE'),
(3, 'Mid-range', 'Phones priced from 7,000,000 to under 13,000,000 VND', 'ACTIVE'),
(4, 'Budget', 'Phones priced under 7,000,000 VND', 'ACTIVE')
ON DUPLICATE KEY UPDATE
  `Name` = VALUES(`Name`),
  `Description` = VALUES(`Description`),
  `Status` = 'ACTIVE';

UPDATE `Product` p
JOIN (
  SELECT `ProductID`, MIN(`Selling_price`) AS `MinimumPrice`
  FROM `ProductVariant`
  WHERE `Status` = 'ACTIVE'
  GROUP BY `ProductID`
) pv ON pv.`ProductID` = p.`ID`
SET p.`CategoryID` = CASE
  WHEN pv.`MinimumPrice` >= 20000000 THEN 1
  WHEN pv.`MinimumPrice` >= 13000000 THEN 2
  WHEN pv.`MinimumPrice` >= 7000000 THEN 3
  ELSE 4
END;
