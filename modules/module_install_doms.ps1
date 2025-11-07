# Script Name: DOMS Installation Script
# Script Version: 8.0

Write-Host "DOMS Installation Script - Version 8.0" -ForegroundColor Green

# ----------------------------------------
# Logical Part 1: Configuration & Setup Checks
# PartVersion: 7.0
# ----------------------------------------

# Define variables
$zipFileUrl = "https://files.stationmaster.info/doms_install_files.zip"
$extractLocation = "C:\winsm"
$workingDirectory = "C:\winsm\doms_install_files"
$zipFileName = "doms_install_files.zip"
$localZipFile = Join-Path -Path $extractLocation -ChildPath $zipFileName

# [0] Make sure running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run with Administrator privileges. Please restart as Administrator." -ForegroundColor Red
    Exit 1
}

# [1] Make sure extract location exists
if (-not (Test-Path -Path $extractLocation -PathType Container)) {
    try {
        New-Item -Path $extractLocation -ItemType Directory | Out-Null
        Write-Host "Created extract location: '$extractLocation'" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to create directory '$extractLocation'. $($_.Exception.Message)" -ForegroundColor Red
        Exit 1
    }
}

# Clean up previous working directory silently (if it exists)
if (Test-Path -Path $workingDirectory -PathType Container) {
    Remove-Item -Path $workingDirectory -Recurse -Force
}

# ----------------------------------------
# Logical Part 2: Obtain and Extract ZIP File
# PartVersion: 5.0
# ----------------------------------------

Write-Host "Starting download of ZIP file..."

# [2] Obtain zip file
# Use .Trim() to eliminate invisible whitespace and explicit Uri parsing for robustness.
try {
    # Ensure the URL is clean
    $cleanZipFileUrl = $zipFileUrl.Trim()
    
    # Optional: Use System.Uri to ensure the string is a valid URI object
    [void](New-Object System.Uri($cleanZipFileUrl))

    # Remove previous zip file to ensure fresh download
    if (Test-Path -Path $localZipFile) { Remove-Item -Path $localZipFile -Force | Out-Null }
    
    # Download the file
    Invoke-WebRequest -Uri $cleanZipFileUrl -OutFile $localZipFile -ErrorAction Stop
} catch {
    Write-Host "ERROR: Failed to download ZIP file. Check URL and connectivity. $($_.Exception.Message)" -ForegroundColor Red
    Exit 1
}

# [3] Extract to extract location
Write-Host "Attempting file extraction using robust COM object method..."

# Create the working directory destination folder explicitly
if (-not (Test-Path -Path $workingDirectory -PathType Container)) {
    New-Item -Path $workingDirectory -ItemType Directory | Out-Null
}

try {
    $shell = New-Object -ComObject Shell.Application
    $source = $shell.NameSpace($localZipFile)
    $destination = $shell.NameSpace($extractLocation)
    
    # 16 is the flag for "No UI, Overwrite all files"
    $destination.CopyHere($source.Items(), 16)

    # The CopyHere method can return before the physical copy is complete, so we wait explicitly
    $waitSeconds = 0
    Write-Host "Waiting for extraction to complete..."
    while (-not (Test-Path -Path $workingDirectory -PathType Container) -and $waitSeconds -lt 10) {
        Start-Sleep -Seconds 1
        $waitSeconds++
    }
    
    if (-not (Test-Path -Path $workingDirectory -PathType Container)) {
        throw "Extraction failed: Working directory was not created."
    }

    Write-Host "Download and extraction complete." -ForegroundColor Green
    # Cleanup downloaded zip file
    Remove-Item -Path $localZipFile -Force | Out-Null
} catch {
    Write-Host "ERROR: Failed to extract ZIP file using COM method. $($_.Exception.Message)" -ForegroundColor Red
    Exit 1
}

# ----------------------------------------
# Logical Part 3: Run Installers Sequentially
# PartVersion: 2.0
# ----------------------------------------

$installers = @(
    @{ Path = Join-Path -Path $workingDirectory -ChildPath "1_visualc++2005\1_FIRST_vcredist_x86.exe"; Name = "Visual C++ 2005 Redist (1st)" },
    @{ Path = Join-Path -Path $workingDirectory -ChildPath "1_visualc++2005\2_SECOND_vcredist_x86.EXE"; Name = "Visual C++ 2005 Redist (2nd)" },
    @{ Path = Join-Path -Path $workingDirectory -ChildPath "2_pss_5000_configurator\setup.exe"; Name = "PSS 5000 Configurator" },
    @{ Path = Join-Path -Path $workingDirectory -ChildPath "3_pss_interface_components\setup.exe"; Name = "PSS Interface Components" },
    @{ Path = Join-Path -Path $workingDirectory -ChildPath "4_doms_pss_demopos\setup.exe"; Name = "DOMS PSS DemoPOS" }
)

Write-Host "Starting sequential installer execution..." -ForegroundColor Yellow

# [4] Run the installers in order and wait for each one to finish
foreach ($installer in $installers) {
    $exePath = $installer.Path
    $exeName = $installer.Name
    
    Write-Host "--> Running: $($exeName)"
    
    if (Test-Path -Path $exePath) {
        try {
            Start-Process -FilePath $exePath -Wait -ErrorAction Stop
            Write-Host "Completed: $($exeName)" -ForegroundColor Green
        } catch {
            Write-Host "WARNING: Installer '$exeName' failed or encountered an issue, but proceeding. $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "ERROR: Installer file not found at '$exePath'. Installation cannot continue." -ForegroundColor Red
        Exit 1
    }
}

# ----------------------------------------
# Logical Part 4: File Copy
# PartVersion: 2.0
# ----------------------------------------

$sourceDll = Join-Path -Path $workingDirectory -ChildPath "Doms.dll"
$destinationDll = "C:\Program Files (x86)\Stationmaster\Doms.dll"
$destinationDir = Split-Path -Path $destinationDll

Write-Host "Attempting Doms.dll copy..." -ForegroundColor Yellow

if (-not (Test-Path -Path $sourceDll)) {
    Write-Host "ERROR: Source file '$sourceDll' not found. Cannot complete Doms.dll copy." -ForegroundColor Red
    Exit 1
}

if (Test-Path -Path $destinationDll) {
    Write-Host "Doms.dll already exists at destination. Skipping copy as requested." -ForegroundColor Yellow
} else {
    # Ensure destination directory exists
    if (-not (Test-Path -Path $destinationDir -PathType Container)) {
        try {
            New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
        } catch {
            Write-Host "ERROR: Failed to create directory '$destinationDir'. $($_.Exception.Message)" -ForegroundColor Red
            Exit 1
        }
    }
    
    # Perform the copy
    try {
        Copy-Item -Path $sourceDll -Destination $destinationDll -Force -ErrorAction Stop
        Write-Host "Successfully copied Doms.dll." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to copy Doms.dll. $($_.Exception.Message)" -ForegroundColor Red
        Exit 1
    }
}

# ----------------------------------------
# Logical Part 5: Final Cleanup
# PartVersion: 3.0
# ----------------------------------------

# The working directory cleanup command remains removed as per your previous instruction.

Write-Host "--- Installation Script Finished. ---" -ForegroundColor Green
