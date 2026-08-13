param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot), [switch]$DownloadImages)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Parse-Models([string]$Text) {
    $items = @()
    foreach ($line in ($Text.Trim() -split "`r?`n")) {
        $parts = $line.Trim() -split '\|'
        $items += [PSCustomObject]@{ Name = $parts[0]; Year = [int]$parts[1] }
    }
    return $items
}

function Get-Slug([string]$Text) {
    $value = $Text.ToLowerInvariant().Replace('+', ' plus ')
    return ([regex]::Replace($value, '[^a-z0-9]+', '-')).Trim('-')
}

function Sql-Text([string]$Text) {
    return "'" + $Text.Replace("'", "''") + "'"
}

function Get-MemoryOptions([string]$Brand, [int]$CategoryId) {
    if ($Brand -eq 'Apple') {
        switch ($CategoryId) {
            1 { return @(@(8, 256), @(8, 512), @(8, 1024)) }
            2 { return @(@(6, 128), @(6, 256), @(6, 512)) }
            3 { return @(@(4, 64), @(4, 128), @(6, 256)) }
            4 { return @(@(2, 32), @(2, 64), @(3, 128)) }
        }
    }
    switch ($CategoryId) {
        1 { return @(@(12, 256), @(12, 512), @(16, 1024)) }
        2 { return @(@(8, 128), @(8, 256), @(12, 512)) }
        3 { return @(@(6, 128), @(8, 128), @(8, 256)) }
        4 { return @(@(4, 64), @(4, 128), @(6, 128)) }
    }
}

function Get-Colors([string]$Brand, [string]$Name) {
    if ($Brand -eq 'Apple' -and $Name -match '17 Pro|16 Pro|15 Pro') {
        return @(
            @('Black Titanium', '#2F3033'), @('White Titanium', '#F2F1ED'),
            @('Blue Titanium', '#5B6672'), @('Natural Titanium', '#B7AA96')
        )
    }
    if ($Brand -eq 'Apple') {
        return @(@('Black', '#24262B'), @('White', '#F2F2F0'), @('Blue', '#6F89A8'), @('Pink', '#D8A7B1'))
    }
    if ($Brand -eq 'Samsung' -or $Brand -eq 'Xiaomi') {
        return @(@('Black', '#24262B'), @('Silver', '#D7D8DA'), @('Blue', '#6F89A8'), @('Green', '#718878'))
    }
    return @(@('Black', '#24262B'), @('White', '#F2F2F0'), @('Blue', '#6F89A8'), @('Gold', '#C9A66B'))
}

function Get-BasePrice([int]$Index) {
    if ($Index -lt 13) { return 34990000 - ($Index * 900000) }
    if ($Index -lt 26) { return 19490000 - (($Index - 13) * 500000) }
    if ($Index -lt 38) { return 12490000 - (($Index - 26) * 450000) }
    return 6790000 - (($Index - 38) * 300000)
}

$apple = Parse-Models @'
iPhone 17 Pro Max|2025
iPhone 17 Pro|2025
iPhone Air|2025
iPhone 17|2025
iPhone 17e|2026
iPhone 16 Pro Max|2024
iPhone 16 Pro|2024
iPhone 16 Plus|2024
iPhone 16|2024
iPhone 16e|2025
iPhone 15 Pro Max|2023
iPhone 15 Pro|2023
iPhone 15 Plus|2023
iPhone 15|2023
iPhone 14 Pro Max|2022
iPhone 14 Pro|2022
iPhone 14 Plus|2022
iPhone 14|2022
iPhone 13 Pro Max|2021
iPhone 13 Pro|2021
iPhone 13|2021
iPhone 12 Pro Max|2020
iPhone 12 Pro|2020
iPhone 11 Pro Max|2019
iPhone 11 Pro|2019
iPhone SE 3|2022
iPhone 13 mini|2021
iPhone 12 mini|2020
iPhone 11|2019
iPhone XS Max|2018
iPhone XS|2018
iPhone XR|2018
iPhone X|2017
iPhone SE 2|2020
iPhone 8 Plus|2017
iPhone 8|2017
iPhone 7 Plus|2016
iPhone 7|2016
iPhone SE|2016
iPhone 6s Plus|2015
iPhone 6s|2015
iPhone 6 Plus|2014
iPhone 6|2014
iPhone 5s|2013
iPhone 5c|2013
iPhone 5|2012
iPhone 4s|2011
iPhone 4|2010
iPhone 3GS|2009
iPhone 3G|2008
'@

$samsung = Parse-Models @'
Samsung Galaxy S26 Ultra|2026
Samsung Galaxy S26+|2026
Samsung Galaxy S26|2026
Samsung Galaxy S25 Ultra|2025
Samsung Galaxy S25+|2025
Samsung Galaxy S25 Edge|2025
Samsung Galaxy S25 FE|2025
Samsung Galaxy S25|2025
Samsung Galaxy S24 Ultra|2024
Samsung Galaxy S24+|2024
Samsung Galaxy S24 FE|2024
Samsung Galaxy S24|2024
Samsung Galaxy Z Fold7|2025
Samsung Galaxy Z Flip7|2025
Samsung Galaxy Z Fold6|2024
Samsung Galaxy Z Flip6|2024
Samsung Galaxy S23 Ultra|2023
Samsung Galaxy S23+|2023
Samsung Galaxy S23 FE|2023
Samsung Galaxy S23|2023
Samsung Galaxy S22 Ultra|2022
Samsung Galaxy S22+|2022
Samsung Galaxy S22|2022
Samsung Galaxy S21 Ultra|2021
Samsung Galaxy S21+|2021
Samsung Galaxy S21 FE|2022
Samsung Galaxy S21|2021
Samsung Galaxy S20 Ultra|2020
Samsung Galaxy S20+|2020
Samsung Galaxy S20 FE|2020
Samsung Galaxy S20|2020
Samsung Galaxy Note20 Ultra|2020
Samsung Galaxy Note20|2020
Samsung Galaxy Note10+|2019
Samsung Galaxy Note10|2019
Samsung Galaxy A56|2025
Samsung Galaxy A55|2024
Samsung Galaxy A54|2023
Samsung Galaxy A53|2022
Samsung Galaxy A52s 5G|2021
Samsung Galaxy A52|2021
Samsung Galaxy A36|2025
Samsung Galaxy A35|2024
Samsung Galaxy A34|2023
Samsung Galaxy A33|2022
Samsung Galaxy A26|2025
Samsung Galaxy A25|2023
Samsung Galaxy A24|2023
Samsung Galaxy A16|2024
Samsung Galaxy A15|2023
'@

$xiaomi = Parse-Models @'
Xiaomi 17 Ultra|2026
Xiaomi 17 Pro Max|2025
Xiaomi 17 Pro|2025
Xiaomi 17|2025
Xiaomi 15 Ultra|2025
Xiaomi 15 Pro|2024
Xiaomi 14 Ultra|2024
Xiaomi 14 Pro|2023
Xiaomi 13 Ultra|2023
Xiaomi 13 Pro|2022
Xiaomi 12S Ultra|2022
Xiaomi Mi 11 Ultra|2021
POCO F7 Ultra|2025
Xiaomi 15|2025
Xiaomi 14|2023
Xiaomi 13|2022
Xiaomi 12S Pro|2022
Xiaomi 12S|2022
Xiaomi 12 Pro|2021
Xiaomi Mi 11 Pro|2021
Xiaomi Mi 11|2020
Xiaomi Mi 10 Ultra|2020
Xiaomi Mi 10 Pro|2020
Redmi Note 15 Pro+ 5G|2025
Redmi Note 14 Pro+ 5G|2024
POCO F7 Pro|2025
Xiaomi 13 Lite|2023
Xiaomi 12|2021
Xiaomi 12 Lite|2022
Xiaomi Mi 11 Lite|2021
Xiaomi Mi 10|2020
Xiaomi Mi 10 Lite|2020
Redmi Note 15 Pro 5G|2025
Redmi Note 15 5G|2025
Redmi Note 14 Pro 5G|2024
Redmi Note 14 5G|2024
Redmi Note 13 Pro+ 5G|2023
POCO F6 Pro|2024
Redmi Note 15|2025
Redmi Note 14|2024
Redmi Note 13 Pro 5G|2023
Redmi Note 13 5G|2023
Redmi Note 13|2023
Redmi Note 12 Pro+ 5G|2022
Redmi Note 12 Pro 5G|2022
Redmi Note 12 5G|2023
Redmi Note 12|2022
POCO F6|2024
POCO X7 Pro|2025
POCO X7|2025
'@

$oppo = Parse-Models @'
OPPO Find X9 Ultra|2026
OPPO Find X9 Pro|2025
OPPO Find X9|2025
OPPO Find X8 Ultra|2025
OPPO Find X8 Pro|2024
OPPO Find X8|2024
OPPO Find X7 Ultra|2024
OPPO Find X7|2024
OPPO Find X6 Pro|2023
OPPO Find X6|2023
OPPO Find X5 Pro|2022
OPPO Find N6|2026
OPPO Find N5|2025
OPPO Find X5|2022
OPPO Find X3 Pro|2021
OPPO Find N3|2023
OPPO Reno15 Pro Max|2026
OPPO Reno15 Pro|2026
OPPO Reno15|2026
OPPO Reno14 Pro|2025
OPPO Reno14|2025
OPPO Reno13 Pro|2024
OPPO Reno13|2024
OPPO Reno12 Pro|2024
OPPO Reno12|2024
OPPO Reno11 Pro|2023
OPPO Reno11|2023
OPPO Reno10 Pro+|2023
OPPO Reno10 Pro|2023
OPPO Reno10|2023
OPPO Reno9 Pro+|2022
OPPO Reno9 Pro|2022
OPPO Reno9|2022
OPPO Reno8 Pro|2022
OPPO Reno8|2022
OPPO Reno7 Pro|2021
OPPO Reno7|2021
OPPO Reno6 Pro|2021
OPPO Reno6|2021
OPPO A6 Pro 5G|2025
OPPO A6 5G|2025
OPPO A5 Pro 5G|2025
OPPO A5 5G|2025
OPPO A5|2025
OPPO A3 Pro|2024
OPPO A3|2024
OPPO A98|2023
OPPO A96|2022
OPPO A78|2023
OPPO A57|2022
'@

$brandData = @(
    [PSCustomObject]@{ Id = 1; Name = 'Apple'; Code = 'APL'; Models = $apple },
    [PSCustomObject]@{ Id = 2; Name = 'Samsung'; Code = 'SAM'; Models = $samsung },
    [PSCustomObject]@{ Id = 3; Name = 'Xiaomi'; Code = 'XIA'; Models = $xiaomi },
    [PSCustomObject]@{ Id = 4; Name = 'Oppo'; Code = 'OPP'; Models = $oppo }
)

foreach ($brand in $brandData) {
    if ($brand.Models.Count -ne 50) { throw "$($brand.Name) must contain exactly 50 products." }
}

$products = @()
$variants = @()
$imageSources = @()
$productId = 1
$variantId = 1

foreach ($brand in $brandData) {
    for ($index = 0; $index -lt $brand.Models.Count; $index++) {
        $model = $brand.Models[$index]
        $categoryId = if ($index -lt 13) { 1 } elseif ($index -lt 26) { 2 } elseif ($index -lt 38) { 3 } else { 4 }
        $product = [PSCustomObject]@{
            Id = $productId; Name = $model.Name; Year = $model.Year
            Rating = $(if (($index % 4) -eq 0) { 5 } else { 4 })
            CategoryId = $categoryId; BrandId = $brand.Id; Brand = $brand.Name
            BrandCode = $brand.Code; BasePrice = (Get-BasePrice $index); Slug = (Get-Slug $model.Name)
        }
        $products += $product
        $memories = Get-MemoryOptions $brand.Name $categoryId
        $colors = Get-Colors $brand.Name $model.Name

        for ($memoryIndex = 0; $memoryIndex -lt $memories.Count; $memoryIndex++) {
            $ram = [int]$memories[$memoryIndex][0]
            $storage = [int]$memories[$memoryIndex][1]
            for ($colorIndex = 0; $colorIndex -lt $colors.Count; $colorIndex++) {
                $colorName = [string]$colors[$colorIndex][0]
                $sellingPrice = $product.BasePrice + ($memoryIndex * 2500000)
                $variants += [PSCustomObject]@{
                    Id = $variantId; ProductId = $productId; RAM = $ram; Storage = $storage
                    ColorName = $colorName; ColorHex = [string]$colors[$colorIndex][1]
                    Barcode = '89' + $variantId.ToString('D11')
                    SKU = "$($brand.Code)-$($productId.ToString('D3'))-${ram}R-${storage}G-C$($colorIndex + 1)"
                    SellingPrice = $sellingPrice; LatestCost = [math]::Floor($sellingPrice * 0.82)
                    Image = "$($product.Slug)-${ram}gb-${storage}gb-$(Get-Slug $colorName).jpg"
                }
                $variantId++
            }
        }

        foreach ($color in $colors) {
            $colorName = [string]$color[0]
            $query = "$($model.Name) $colorName official product phone white background"
            $imageSources += [PSCustomObject]@{
                ProductId = $productId; Brand = $brand.Name; ProductName = $model.Name; Color = $colorName
                Query = $query
                QueryUrl = 'https://tse1.mm.bing.net/th?q=' + [uri]::EscapeDataString($query) + '&w=700&h=700&c=7&rs=1&p=0'
                FirstVariantImage = "$($product.Slug)-$([int]$memories[0][0])gb-$([int]$memories[0][1])gb-$(Get-Slug $colorName).jpg"
            }
        }
        $productId++
    }
}

if (($products | Select-Object -ExpandProperty Name -Unique).Count -ne 200) { throw 'Product names must be unique.' }
if (($variants | Select-Object -ExpandProperty Image -Unique).Count -ne 2400) { throw 'Variant image names must be unique.' }
if (($products | Where-Object { $_.Name.Length -gt 50 }).Count -gt 0) { throw 'A product name exceeds VARCHAR(50).' }

$sqlPath = Join-Path $ProjectRoot 'database_swp391.sql'
$originalSql = [IO.File]::ReadAllText($sqlPath)
$marker = [regex]::Match($originalSql, '(?m)^INSERT INTO `Product`')
if (-not $marker.Success) { throw 'Product seed marker was not found.' }
$prefix = $originalSql.Substring(0, $marker.Index)
$builder = New-Object System.Text.StringBuilder

[void]$builder.AppendLine('INSERT INTO `Product` (`ID`, `Name`, `Description`, `Release_Year`, `Rating`, `warranty_months`, `CategoryID`, `BrandID`, `Status`) VALUES')
for ($i = 0; $i -lt $products.Count; $i++) {
    $p = $products[$i]
    $ending = if ($i -eq $products.Count - 1) { ';' } else { ',' }
    $description = "$($p.Name) genuine smartphone with selectable RAM, storage and colors"
    [void]$builder.AppendLine("($($p.Id), $(Sql-Text $p.Name), $(Sql-Text $description), $($p.Year), $($p.Rating), 12, $($p.CategoryId), $($p.BrandId), 'ACTIVE')$ending")
}

[void]$builder.AppendLine()
[void]$builder.AppendLine('INSERT INTO `ProductVariant` (`ID`, `ProductID`, `RAM_GB`, `Storage_GB`, `ColorName`, `ColorHex`, `Barcode`, `SKU`, `Selling_price`, `Latest_cost`, `Image`, `Status`) VALUES')
for ($i = 0; $i -lt $variants.Count; $i++) {
    $v = $variants[$i]
    $ending = if ($i -eq $variants.Count - 1) { ';' } else { ',' }
    [void]$builder.AppendLine("($($v.Id), $($v.ProductId), $($v.RAM), $($v.Storage), $(Sql-Text $v.ColorName), $(Sql-Text $v.ColorHex), $(Sql-Text $v.Barcode), $(Sql-Text $v.SKU), $($v.SellingPrice), $($v.LatestCost), $(Sql-Text $v.Image), 'ACTIVE')$ending")
}

$firstApple = $variants | Where-Object ProductId -eq 1 | Select-Object -First 1
$fifthApple = $variants | Where-Object ProductId -eq 5 | Select-Object -First 1
$firstSamsung = $variants | Where-Object ProductId -eq 51 | Select-Object -First 1
$firstXiaomi = $variants | Where-Object ProductId -eq 101 | Select-Object -First 1
$orderOneTotal = $firstApple.SellingPrice + $fifthApple.SellingPrice
$orderTwoTotal = $firstSamsung.SellingPrice
$importTotal = ($firstApple.SellingPrice * 5) + $fifthApple.SellingPrice

[void]$builder.AppendLine(@"

INSERT INTO `Inventory` (`ProductVariantID`, `Amount`, `Min_amount`, `Max_amount`, `Status`)
SELECT pv.ID, 8 + ((pv.ProductID + pv.ID) MOD 13), 2, 50, 'ACTIVE' FROM `ProductVariant` pv;

INSERT INTO `Supplier_ProductVariant` (`SupplierID`, `ProductVariantID`)
SELECT 1 + ((pv.ProductID - 1) MOD 3), pv.ID FROM `ProductVariant` pv;

INSERT INTO `Cart` (`UserID`, `ProductVariantID`, `Amount`) VALUES
(4, $($firstApple.Id), 1), (4, $($fifthApple.Id), 2);

INSERT INTO `Wishlist` (`UserID`, `ProductVariantID`) VALUES
(4, $($firstSamsung.Id)), (4, $($firstXiaomi.Id)), (6, $($firstApple.Id));

INSERT INTO `Transaction` (`ID`, `UserID`, `Total_price`, `Type`, `Status`, `SupplierID`, `Paid_amount`, `Change_amount`, `Method`, `Updated_by`, `Reference_transactionID`) VALUES
(1, 4, $orderOneTotal, 'ORDER', 'PAID', NULL, $orderOneTotal, 0, 'BANK_TRANSFER', 3, NULL),
(2, 6, $orderTwoTotal, 'ORDER', 'CANCEL_REQUESTED', NULL, $orderTwoTotal, 0, 'VNPAY', 3, NULL),
(3, 2, $importTotal, 'IMPORT', 'COMPLETED', 1, $importTotal, 0, 'BANK_TRANSFER', 2, NULL),
(4, 6, $orderTwoTotal, 'REFUND', 'PENDING', NULL, 0, 0, 'ORIGINAL_PAYMENT', 2, 2);

INSERT INTO `Transaction_ProductVariant` (`TransactionID`, `ProductVariantID`, `Amount`, `UnitPrice`, `Discount_rate`, `Discount_amount`, `Total`) VALUES
(1, $($firstApple.Id), 1, $($firstApple.SellingPrice), 10, $([math]::Floor($firstApple.SellingPrice * 0.10)), $([math]::Floor($firstApple.SellingPrice * 0.90))),
(1, $($fifthApple.Id), 1, $($fifthApple.SellingPrice), 0, 0, $($fifthApple.SellingPrice)),
(2, $($firstSamsung.Id), 1, $($firstSamsung.SellingPrice), 5, $([math]::Floor($firstSamsung.SellingPrice * 0.05)), $([math]::Floor($firstSamsung.SellingPrice * 0.95))),
(3, $($firstApple.Id), 5, $($firstApple.SellingPrice), 0, 0, $($firstApple.SellingPrice * 5)),
(3, $($fifthApple.Id), 1, $($fifthApple.SellingPrice), 0, 0, $($fifthApple.SellingPrice)),
(4, $($firstSamsung.Id), 1, $($firstSamsung.SellingPrice), 0, 0, $($firstSamsung.SellingPrice));

INSERT INTO `DeliveryInfo` (`ID`, `UserID`, `Recipient_name`, `Recipient_phone`, `Delivery_address`, `Status`) VALUES
(1, 4, 'Demo Customer', '0900000004', 'Thu Duc, Ho Chi Minh City', 'ACTIVE'),
(2, 6, 'Chi Kim Tuyen', '0900000303', 'Quan 7, Ho Chi Minh City', 'ACTIVE');

INSERT INTO `Feedback` (`ID`, `Rating`, `Content`, `UserID`, `ProductVariantID`) VALUES
(1, 5, 'May dep, chay muot, pin tot.', 4, $($firstApple.Id)),
(2, 4, 'San pham dung tot.', 6, $($fifthApple.Id));

INSERT INTO `Answer` (`ID`, `FeedbackID`, `Content`, `UserID`) VALUES
(1, 1, 'Cam on ban da tin tuong shop.', 2),
(2, 2, 'Shop se kiem tra va lien he lai voi ban.', 2);

INSERT INTO `ReturnRequest` (`ID`, `Status`, `Description`, `Image`, `UserID`, `TransactionID`) VALUES
(1, 'REQUESTED', 'Customer requested cancellation before delivery.', NULL, 6, 2);

INSERT INTO `ReturnRequest_ProductVariant` (`ReturnRequestID`, `ProductVariantID`) VALUES
(1, $($firstSamsung.Id));
"@)

[IO.File]::WriteAllText($sqlPath, $prefix + $builder.ToString(), $utf8)
$products | Select-Object Id, Brand, Name, Year, CategoryId, BasePrice | Export-Csv -LiteralPath (Join-Path $ProjectRoot 'phone-catalog.csv') -NoTypeInformation -Encoding UTF8
$imageSources | Export-Csv -LiteralPath (Join-Path $ProjectRoot 'phone-image-sources.csv') -NoTypeInformation -Encoding UTF8

if ($DownloadImages) {
    $imageDirectory = Join-Path $ProjectRoot 'web\assets\images\products'
    New-Item -ItemType Directory -Path $imageDirectory -Force | Out-Null
    $downloaded = 0
    $failed = @()
    foreach ($source in $imageSources) {
        $matchingVariants = $variants | Where-Object { $_.ProductId -eq $source.ProductId -and $_.ColorName -eq $source.Color }
        $firstPath = Join-Path $imageDirectory $matchingVariants[0].Image
        $tempPath = $firstPath + '.tmp'
        if (-not (Test-Path $firstPath) -or (Get-Item $firstPath).Length -lt 2000) {
            if (Test-Path $tempPath) { Remove-Item -LiteralPath $tempPath -Force }
            & curl.exe -L --fail --silent --show-error --max-time 30 -o $tempPath $source.QueryUrl
            if ($LASTEXITCODE -ne 0 -or -not (Test-Path $tempPath) -or (Get-Item $tempPath).Length -lt 2000) {
                if (Test-Path $tempPath) { Remove-Item -LiteralPath $tempPath -Force }
                $failed += "$($source.ProductName) - $($source.Color)"
                continue
            }
            Move-Item -LiteralPath $tempPath -Destination $firstPath -Force
        }
        foreach ($variant in $matchingVariants) {
            $targetPath = Join-Path $imageDirectory $variant.Image
            if ($targetPath -ne $firstPath) { Copy-Item -LiteralPath $firstPath -Destination $targetPath -Force }
        }
        $downloaded++
        if (($downloaded % 50) -eq 0) { Write-Output "Downloaded $downloaded / $($imageSources.Count) color images" }
    }
    if ($failed.Count -gt 0) { throw "Image downloads failed: $($failed -join ', ')" }

    $refineScript = Join-Path $PSScriptRoot 'refine-phone-colors.ps1'
    & $refineScript -ProjectRoot $ProjectRoot -DownloadBackImages
}

Write-Output "Products: $($products.Count)"
Write-Output "Base variants before color validation: $($variants.Count)"
Write-Output "Image color sources: $($imageSources.Count)"
Write-Output "SQL: $sqlPath"
