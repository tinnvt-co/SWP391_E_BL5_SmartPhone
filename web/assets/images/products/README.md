# Product images

Place all real product images directly in this folder. The database stores only the file name, never a folder or URL.

```text
products/
  iphone-15-pro-max-black-128gb.webp
  iphone-15-pro-max-black-256gb.webp
  iphone-15-pro-max-silver-256gb.webp
  samsung-galaxy-s24-ultra-blue-512gb.webp
```

Use lowercase file names, no Vietnamese accents, no spaces, and hyphens between words. Use `.webp` when possible; `.jpg` and `.png` also work.

The value stored in `ProductVariant.Image` is only the file name.

```text
iphone-15-pro-max-black-256gb.webp
```

`Product.Image` is not part of the new database. Save the image for every product variant instead.

## Add real images for each color

1. Open the official product page of Apple, Samsung, Xiaomi, or OPPO. Download the official product image for each color. Do not copy an image URL from another shop because the image can disappear or block hotlinking.
2. Keep a square image with a white or transparent background. A size of `800 x 800` pixels is enough for this project.
3. Convert the file to WebP if possible. Use the exact color in the file name.
4. Put the file in the correct phone folder.
5. Update `ProductVariant.Image` with the local path.

Example for Product ID `1`:

```sql
UPDATE ProductVariant
SET Image = 'iphone-15-pro-max-black-256gb.webp'
WHERE ProductID = 1 AND ColorName = 'Black' AND Storage_GB = 256;

UPDATE ProductVariant
SET Image = 'iphone-15-pro-max-blue-256gb.webp'
WHERE ProductID = 1 AND ColorName = 'Blue' AND Storage_GB = 256;

UPDATE ProductVariant
SET Image = 'iphone-15-pro-max-silver-256gb.webp'
WHERE ProductID = 1 AND ColorName = 'Silver' AND Storage_GB = 256;

UPDATE ProductVariant
SET Image = 'iphone-15-pro-max-pink-256gb.webp'
WHERE ProductID = 1 AND ColorName = 'Pink' AND Storage_GB = 256;
```

Check all colors that need images:

```sql
SELECT p.ID, p.Name, pv.ColorName, pv.Image
FROM Product p
JOIN ProductVariant pv ON pv.ProductID = p.ID
ORDER BY p.ID, pv.ColorName;
```

If the official color name is different from the current database color, update `ColorName`, `ColorHex`, and `Image` together. Include `Storage_GB` because each memory version has its own file name.

```sql
UPDATE ProductVariant
SET ColorName = 'Black Titanium',
    ColorHex = '#3A3A3C',
    Image = 'iphone-15-pro-max-black-256gb.webp'
WHERE ProductID = 1 AND ColorName = 'Black' AND Storage_GB = 256;
```

Do not save a Windows path, web path, or URL in the database. Store only the image file name.
