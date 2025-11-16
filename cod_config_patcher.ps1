# PowerShell script to backup and modify Call of Duty config files
# Requires PowerShell 5.0 or higher
# Version: 2.0

# Define the user profile path
$userPath = $env:USERPROFILE
$codPath = Join-Path $userPath "Documents\Call of Duty\players"

# Check if the directory exists
if (-not (Test-Path $codPath)) {
    Write-Error "Directory not found: $codPath"
    Write-Host "Expected path: $codPath" -ForegroundColor Red
    exit 1
}

Write-Host "Scanning directory: $codPath" -ForegroundColor Cyan
Write-Host ""

# Find all .txt0 files matching the pattern s.1.0.cod*.txt0
$txt0Files = Get-ChildItem -Path $codPath -Filter "s.1.0.cod*.txt0" -ErrorAction SilentlyContinue

if ($txt0Files.Count -eq 0) {
    Write-Error "No config files found matching pattern: s.1.0.cod*.txt0"
    Write-Host "Please verify that Call of Duty config files exist in: $codPath" -ForegroundColor Yellow
    exit 1
}

# Automatically select the first matching pair
$selectedFile = $null
$fileBaseName = $null

foreach ($txt0File in $txt0Files) {
    # Extract the base name without extension (e.g., s.1.0.cod24 or s.1.0.cod25)
    $baseName = $txt0File.Name -replace '\.txt0$', ''
    $txt1Path = Join-Path $codPath "$baseName.txt1"

    # Check if the corresponding .txt1 file exists
    if (Test-Path $txt1Path) {
        $selectedFile = $txt0File
        $fileBaseName = $baseName
        Write-Host "Found matching config pair: $baseName" -ForegroundColor Green
        break
    }
}

if (-not $selectedFile) {
    Write-Error "No matching .txt0 and .txt1 file pair found"
    Write-Host "Available .txt0 files:" -ForegroundColor Yellow
    $txt0Files | ForEach-Object { Write-Host "  - $($_.Name)" }
    exit 1
}

# Define the files to backup and modify
$files = @("$fileBaseName.txt0", "$fileBaseName.txt1")

Write-Host "Will process the following files:" -ForegroundColor Cyan
$files | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
Write-Host ""

# Generate timestamp without spaces or special characters
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$archiveName = "cod_backup_${timestamp}.zip"
$archivePath = Join-Path $codPath $archiveName

# Create the ZIP archive
Write-Host "Creating backup archive: $archiveName" -ForegroundColor Cyan
try {
    $filesToZip = $files | ForEach-Object { Join-Path $codPath $_ }
    Compress-Archive -Path $filesToZip -DestinationPath $archivePath -Force
    Write-Host "Backup created successfully: $archivePath" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Error "Failed to create backup: $_"
    exit 1
}

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

    Write-Host "Processing file: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan

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
                    $beforeEquals = $matches[1]  # Everything before and including '='
                    $oldValue = $matches[2].Trim()  # The actual value
                    $comment = if ($matches[3]) { " " + $matches[3] } else { "" }  # Comment if exists

                    # Only modify if the value is actually different
                    if ($oldValue -ne $newValue) {
                        # Reconstruct the line with new value and preserved comment
                        $modifiedLine = $beforeEquals + " " + $newValue + $comment
                        $changesApplied++
                        Write-Host "  Changed $key : $oldValue -> $newValue $(if($comment){'(comment preserved)'})" -ForegroundColor Yellow
                    } else {
                        # Value is already correct, no change needed
                        $unchangedCount++
                        Write-Host "  Skipped $key : already set to $oldValue" -ForegroundColor Gray
                    }
                }
            }
        }

        $modifiedLines += $modifiedLine
    }

    # Write the modified content back to the file
    $modifiedLines | Set-Content -Path $FilePath -Encoding UTF8

    Write-Host "  Result: $changesApplied changes applied, $unchangedCount already correct" -ForegroundColor Cyan
    Write-Host ""

    return $changesApplied
}

# Modify both files
Write-Host "Modifying configuration files..." -ForegroundColor Green
Write-Host ""
$totalChanges = 0

foreach ($file in $files) {
    $filePath = Join-Path $codPath $file
    try {
        $changes = Update-ConfigFile -FilePath $filePath -Changes $configChanges
        $totalChanges += $changes
    } catch {
        Write-Error "Failed to modify $file : $_"
    }
}

Write-Host "======================================" -ForegroundColor Green
Write-Host "Operation completed successfully!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host "Total changes applied: $totalChanges"
Write-Host "Backup location: $archivePath"
Write-Host ""
Write-Host "You can now launch Call of Duty with optimized settings." -ForegroundColor Cyan
