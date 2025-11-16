# PowerShell script to backup and modify Call of Duty config files
# Requires PowerShell 5.0 or higher
# Version: 2.2

# Define potential config locations
$userPath = $env:USERPROFILE
$localAppData = $env:LOCALAPPDATA

$configPaths = @(
    (Join-Path $userPath "Documents\Call of Duty\players"),
    (Join-Path $localAppData "Activision\Call of Duty\Players")
)

Write-Host "Call of Duty Config Patcher v2.2" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Function to find config files in a directory
function Find-ConfigFiles {
    param (
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return @()
    }

    Write-Host "Scanning: $Path" -ForegroundColor Yellow

    # Define search patterns for different config file formats
    $patterns = @(
        "s.1.0.cod*.txt0",      # Pattern: s.1.0.cod24.txt0, s.1.0.cod25.txt0
        "s.1.0.bt.cod*.txt0"    # Pattern: s.1.0.bt.cod25.txt0
    )

    $foundPairs = @()

    foreach ($pattern in $patterns) {
        $txt0Files = Get-ChildItem -Path $Path -Filter $pattern -ErrorAction SilentlyContinue

        foreach ($txt0File in $txt0Files) {
            # Extract the base name without extension
            $baseName = $txt0File.Name -replace '\.txt0$', ''
            $txt1Path = Join-Path $Path "$baseName.txt1"

            # Check if the corresponding .txt1 file exists
            if (Test-Path $txt1Path) {
                # Check if this pair is already in the list (avoid duplicates)
                $alreadyAdded = $foundPairs | Where-Object { $_.BaseName -eq $baseName }

                if (-not $alreadyAdded) {
                    $foundPairs += [PSCustomObject]@{
                        BaseName = $baseName
                        Path = $Path
                        Txt0 = $txt0File.FullName
                        Txt1 = $txt1Path
                    }
                    Write-Host "  Found pair: $baseName" -ForegroundColor Green
                }
            }
        }
    }

    return $foundPairs
}

# Search for config files in all locations
Write-Host "Searching for Call of Duty config files..." -ForegroundColor Cyan
Write-Host ""

$allConfigPairs = @()
foreach ($path in $configPaths) {
    $pairs = Find-ConfigFiles -Path $path
    if ($pairs.Count -gt 0) {
        $allConfigPairs += $pairs
    }
}

if ($allConfigPairs.Count -eq 0) {
    Write-Error "No config files found in any location"
    Write-Host ""
    Write-Host "Searched locations:" -ForegroundColor Yellow
    foreach ($path in $configPaths) {
        Write-Host "  - $path" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Supported patterns:" -ForegroundColor Yellow
    Write-Host "  - s.1.0.cod*.txt0/.txt1 (e.g., s.1.0.cod24.txt0)" -ForegroundColor Gray
    Write-Host "  - s.1.0.bt.cod*.txt0/.txt1 (e.g., s.1.0.bt.cod25.txt0)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Please verify that Call of Duty has been launched at least once." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Found $($allConfigPairs.Count) config pair(s) to process" -ForegroundColor Green
Write-Host ""

# Define the configuration changes
$configChanges = @{
    "NvidiaReflex" = "Enabled"
    "BloodLimit" = "true"
    "BloodLimitInterval" = "2000"
    "ShowBlood" = "false"
    "ShowBrass" = "false"
    "DepthOfFieldQuality" = "Low"
    "CorpseLimit" = "0"
    "ShaderQuality" = "Low"
    "SubdivisionLevel" = "0"
    "BulletImpacts" = "false"
    "TerrainQuality" = "Very Low"
    "Tessellation" = "0_Off"
}

# Function to modify config file
function Update-ConfigFile {
    param (
        [string]$FilePath,
        [hashtable]$Changes
    )

    Write-Host "  Processing: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan

    # Read the file content
    $lines = Get-Content -Path $FilePath
    $modifiedLines = @()
    $changesApplied = 0
    $unchangedCount = 0

    foreach ($line in $lines) {
        $modifiedLine = $line

        # Check if line contains '@' and '='
        if ($line -match '^([^@]+)@.*=\s*(.*)$') {
            $key = $matches[1].Trim()

            # Check if this key needs to be modified
            if ($Changes.ContainsKey($key)) {
                $newValue = $Changes[$key]

                # Split the line at '=' to separate key part and value part
                if ($line -match '^([^=]+=)\s*([^/]*)(//.*)?$') {
                    $beforeEquals = $matches[1]
                    $oldValue = $matches[2].Trim()
                    $comment = if ($matches[3]) { " " + $matches[3] } else { "" }

                    # Only modify if the value is actually different
                    if ($oldValue -ne $newValue) {
                        $modifiedLine = $beforeEquals + " " + $newValue + $comment
                        $changesApplied++
                        Write-Host "    Changed $key : $oldValue -> $newValue $(if($comment){'(comment preserved)'})" -ForegroundColor Yellow
                    } else {
                        $unchangedCount++
                        Write-Host "    Skipped $key : already set to $oldValue" -ForegroundColor Gray
                    }
                }
            }
        }

        $modifiedLines += $modifiedLine
    }

    # Write the modified content back to the file
    $modifiedLines | Set-Content -Path $FilePath -Encoding UTF8

    Write-Host "    Result: $changesApplied changes, $unchangedCount unchanged" -ForegroundColor Cyan

    return $changesApplied
}

# Process all found config pairs
$totalChanges = 0
$processedCount = 0

foreach ($configPair in $allConfigPairs) {
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host "Processing: $($configPair.BaseName)" -ForegroundColor Magenta
    Write-Host "Location: $($configPair.Path)" -ForegroundColor Magenta
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host ""

    # Generate timestamp for backup
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $archiveName = "cod_backup_$($configPair.BaseName)_${timestamp}.zip"
    $archivePath = Join-Path $configPair.Path $archiveName

    # Create backup
    Write-Host "Creating backup: $archiveName" -ForegroundColor Cyan
    try {
        $filesToZip = @($configPair.Txt0, $configPair.Txt1)
        Compress-Archive -Path $filesToZip -DestinationPath $archivePath -Force
        Write-Host "Backup created: $archivePath" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Error "Failed to create backup: $_"
        continue
    }

    # Modify files
    Write-Host "Modifying configuration files..." -ForegroundColor Cyan

    try {
        $changes1 = Update-ConfigFile -FilePath $configPair.Txt0 -Changes $configChanges
        Write-Host ""
        $changes2 = Update-ConfigFile -FilePath $configPair.Txt1 -Changes $configChanges

        $totalChanges += ($changes1 + $changes2)
        $processedCount++

        Write-Host ""
        Write-Host "Completed: $($configPair.BaseName) ($($changes1 + $changes2) total changes)" -ForegroundColor Green
        Write-Host ""

    } catch {
        Write-Error "Failed to modify files: $_"
    }
}

# Final summary
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "All Operations Completed!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host "Processed config pairs: $processedCount" -ForegroundColor White
Write-Host "Total changes applied: $totalChanges" -ForegroundColor White
Write-Host ""
Write-Host "Backups created in their respective directories." -ForegroundColor Cyan
Write-Host "You can now launch Call of Duty with optimized settings." -ForegroundColor Cyan
Write-Host ""
