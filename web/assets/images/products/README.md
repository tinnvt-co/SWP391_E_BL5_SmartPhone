# Product images

This folder contains the local images used by `ProductVariant.Image`. The database stores only a file name, never a Windows path, web path, or remote URL.

The generated catalog contains:

- 200 real phone model names: 50 Apple, 50 Samsung, 50 Xiaomi, and 50 OPPO.
- 3 RAM/storage options for each phone.
- Up to 4 colors per phone. A color is removed when its downloaded front image duplicates another color of the same product.
- 733 retained product/color combinations and 2,199 product variants.
- A front image and a back image for every retained product/color combination.

Storage does not change a phone's appearance. Variants with the same product and color use the same back image, while their front image file names remain unique because the database validates duplicate `Image` names.

## Rebuild the catalog

Run this from the project root:

```powershell
.\tools\generate-phone-catalog.ps1 -DownloadImages
```

The script rewrites the product seed in `database_swp391.sql`, exports `phone-catalog.csv`, exports the image-query manifest `phone-image-sources.csv`, downloads the local images, removes duplicate color images, downloads back images, and exports the retained colors to `phone-color-selection.csv`.

## Replace an image manually

1. Download the official product render for the exact model and color.
2. Keep a square image with a white or transparent background when possible.
3. Replace the front and back files for that product/color while preserving the existing file names.
4. Do not change `ProductVariant.Image` unless the new front-image file name is also unique.

The automatically collected images are intended for this educational demo. Search-result images can originate from manufacturers, retailers, or editorial sites. Verify ownership and replace them with licensed manufacturer assets before any public or commercial use.
