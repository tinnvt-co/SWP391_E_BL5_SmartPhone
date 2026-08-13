param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$DownloadBackImages
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$imageDirectory = Join-Path $ProjectRoot 'web\assets\images\products'
$sourcePath = Join-Path $ProjectRoot 'phone-image-sources.csv'
$sqlPath = Join-Path $ProjectRoot 'database_swp391.sql'

function Get-Slug([string]$Text) {
    $value = $Text.ToLowerInvariant().Replace('+', ' plus ')
    return ([regex]::Replace($value, '[^a-z0-9]+', '-')).Trim('-')
}

function Download-Image([string]$Url, [string]$Path) {
    $temporaryPath = $Path + '.tmp'
    if (Test-Path $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }
    & curl.exe -L --fail --silent --show-error --max-time 30 -o $temporaryPath $Url
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $temporaryPath) -or (Get-Item $temporaryPath).Length -lt 2000) {
        if (Test-Path $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
        return $false
    }
    Move-Item -LiteralPath $temporaryPath -Destination $Path -Force
    return $true
}

$sources = Import-Csv -LiteralPath $sourcePath
$selectedSources = @()
$removedSources = @()

foreach ($productGroup in ($sources | Group-Object ProductId)) {
    $usedHashes = @{}
    foreach ($source in $productGroup.Group) {
        $frontPath = Join-Path $imageDirectory $source.FirstVariantImage
        if (-not (Test-Path $frontPath)) {
            throw "Missing front image: $frontPath"
        }
        $hash = (Get-FileHash -LiteralPath $frontPath -Algorithm SHA256).Hash
        if ($usedHashes.ContainsKey($hash)) {
            $removedSources += $source
        } else {
            $usedHashes[$hash] = $true
            $selectedSources += $source
        }
    }
}

$processed = 0
foreach ($source in $selectedSources) {
    $productSlug = Get-Slug $source.ProductName
    $colorSlug = Get-Slug $source.Color
    $backName = "$productSlug-$colorSlug-back.jpg"
    $backPath = Join-Path $imageDirectory $backName
    $frontPath = Join-Path $imageDirectory $source.FirstVariantImage
    $frontHash = (Get-FileHash -LiteralPath $frontPath -Algorithm SHA256).Hash

    if ($DownloadBackImages -or -not (Test-Path $backPath)) {
        $query = "$($source.ProductName) $($source.Color) back rear view official smartphone"
        $saved = $false
        foreach ($position in @(0, 2, 5)) {
            $url = 'https://tse1.mm.bing.net/th?q=' + [uri]::EscapeDataString($query)
            $url += "&w=700&h=700&c=7&rs=1&p=$position"
            if (Download-Image $url $backPath) {
                $backHash = (Get-FileHash -LiteralPath $backPath -Algorithm SHA256).Hash
                if ($backHash -ne $frontHash) {
                    $saved = $true
                    break
                }
            }
        }
        if (-not $saved -and -not (Test-Path $backPath)) {
            Copy-Item -LiteralPath $frontPath -Destination $backPath
        }
    }

    Add-Member -InputObject $source -NotePropertyName BackImage -NotePropertyValue $backName -Force
    $processed++
    if (($processed % 50) -eq 0) {
        Write-Output "Prepared $processed / $($selectedSources.Count) back images"
    }
}

$selectedKeys = @{}
foreach ($source in $selectedSources) {
    $selectedKeys["$($source.ProductId)|$($source.Color)"] = $source.BackImage
}

$sql = [IO.File]::ReadAllText($sqlPath)
$sql = $sql.Replace('`Image` VARCHAR(255) NULL,', "`Image` VARCHAR(255) NULL,`r`n  `BackImage` VARCHAR(255) NULL,")
$sql = $sql.Replace('`Latest_cost`, `Image`, `Status`)', '`Latest_cost`, `Image`, `BackImage`, `Status`)')

$startMarker = 'INSERT INTO `ProductVariant`'
$endMarker = 'INSERT INTO Inventory'
$start = $sql.IndexOf($startMarker)
$end = $sql.IndexOf($endMarker, $start)
if ($start -lt 0 -or $end -lt 0) {
    throw 'ProductVariant seed block was not found.'
}

$block = $sql.Substring($start, $end - $start)
$lines = $block -split "`r?`n"
$header = $lines[0..0]
if ($lines.Count -gt 1 -and $lines[1] -match '^\(' -eq $false) {
    $header += $lines[1]
}

$rowPattern = "^\((\d+), (\d+), (\d+), (\d+), '([^']+)', '([^']+)', '([^']+)', '([^']+)', (\d+), (\d+), '([^']+)'(?:, '[^']*')?, 'ACTIVE'\)[,;]$"
$keptRows = @()
$removedImages = @()

foreach ($line in $lines) {
    if ($line -notmatch $rowPattern) {
        continue
    }
    $key = "$($Matches[2])|$($Matches[5])"
    if (-not $selectedKeys.ContainsKey($key)) {
        $removedImages += $Matches[11]
        continue
    }
    $backImage = $selectedKeys[$key].Replace("'", "''")
    $keptRows += "($($Matches[1]), $($Matches[2]), $($Matches[3]), $($Matches[4]), '$($Matches[5])', '$($Matches[6])', '$($Matches[7])', '$($Matches[8])', $($Matches[9]), $($Matches[10]), '$($Matches[11])', '$backImage', 'ACTIVE')"
}

if ($keptRows.Count -eq 0) {
    throw 'No ProductVariant rows were parsed.'
}

for ($index = 0; $index -lt $keptRows.Count; $index++) {
    $keptRows[$index] += if ($index -eq $keptRows.Count - 1) { ';' } else { ',' }
}

$newBlock = ($header + $keptRows + '') -join "`r`n"
$sql = $sql.Substring(0, $start) + $newBlock + $sql.Substring($end)
[IO.File]::WriteAllText($sqlPath, $sql, $utf8)

$resolvedImageDirectory = [IO.Path]::GetFullPath($imageDirectory)
foreach ($imageName in ($removedImages | Sort-Object -Unique)) {
    $path = [IO.Path]::GetFullPath((Join-Path $imageDirectory $imageName))
    if (-not $path.StartsWith($resolvedImageDirectory, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe image path: $path"
    }
    if (Test-Path $path) {
        Remove-Item -LiteralPath $path -Force
    }
}

$selectionPath = Join-Path $ProjectRoot 'phone-color-selection.csv'
$selectedSources |
    Select-Object ProductId, Brand, ProductName, Color, FirstVariantImage, BackImage, QueryUrl |
    Export-Csv -LiteralPath $selectionPath -NoTypeInformation -Encoding UTF8

Write-Output "Products: $(($selectedSources | Group-Object ProductId).Count)"
Write-Output "Selected product colors: $($selectedSources.Count)"
Write-Output "Removed duplicate colors: $($removedSources.Count)"
Write-Output "Product variants: $($keptRows.Count)"
