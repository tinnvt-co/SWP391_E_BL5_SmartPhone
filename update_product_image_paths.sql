USE `database_swp391`;

UPDATE `ProductVariant` pv
JOIN `Product` p ON p.ID = pv.ProductID
SET pv.Image = CASE
  WHEN p.ID BETWEEN 1 AND 5 THEN CONCAT(
    CASE p.ID
      WHEN 1 THEN 'iphone-15-pro-max'
      WHEN 2 THEN 'samsung-galaxy-s24-ultra'
      WHEN 3 THEN 'xiaomi-14'
      WHEN 4 THEN 'oppo-reno-11'
      WHEN 5 THEN 'iphone-14'
    END,
    '-', LOWER(pv.ColorName), '-', pv.Storage_GB, 'gb.webp'
  )
  ELSE NULL
END;

ALTER TABLE `ProductVariant`
ADD CONSTRAINT `uk_ProductVariant_Image` UNIQUE (`Image`);
