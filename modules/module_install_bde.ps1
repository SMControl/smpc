# ------------------------------------------------------------------------------------------------------------------
# Script Name: DLL Registration Script | Version: 1.0.0
# This script downloads a specified DLL and registers it using regsvr32.
# ------------------------------------------------------------------------------------------------------------------

# Define variables
$DllUrl = "https://files.stationmaster.info/BDEINST.DLL"
$DownloadPath = "C:\BDEINST.DLL"
$TargetDirectory = "C:\"


# ------------------------------------------------------------------------------------------------------------------
# Part 1.0.0: Check for Administrative Privileges
# ------------------------------------------------------------------------------------------------------------------
Write-Host "`n-- Part 1: Checking for Admin Privileges (v1.0.0) --" -ForegroundColor Cyan

# Get the current Windows identity
$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = [Security.Principal.WindowsPrincipal] $CurrentIdentity

# Check if the user is a member of the Administrators group
if (-not $WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run with Administrator privileges." -ForegroundColor Red
    Write-Host "Please right-click the script and select 'Run as Administrator'." -ForegroundColor Red
    exit 1
}

Write-Host "SUCCESS: Running with Administrator privileges." -ForegroundColor Green


# ------------------------------------------------------------------------------------------------------------------
# Part 2.0.0: Setup Environment (Set Current Directory)
# ------------------------------------------------------------------------------------------------------------------
Write-Host "`n-- Part 2: Setting Current Directory (v2.0.0) --" -ForegroundColor Cyan

try {
    # Set the current working location to C:\
    Set-Location -Path $TargetDirectory
    Write-Host "SUCCESS: Current directory set to $($TargetDirectory)." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Could not set current directory to $($TargetDirectory)." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


# ------------------------------------------------------------------------------------------------------------------
# Part 3.0.0: Download DLL File
# ------------------------------------------------------------------------------------------------------------------
Write-Host "`n-- Part 3: Downloading DLL File (v3.0.0) --" -ForegroundColor Cyan
Write-Host "Attempting to download DLL from '$DllUrl' to '$DownloadPath'..."

try {
    # Download the file using the built-in cmdlet
    Invoke-WebRequest -Uri $DllUrl -OutFile $DownloadPath -ErrorAction Stop

    # Verify the download succeeded by checking if the file exists
    if (Test-Path $DownloadPath) {
        Write-Host "SUCCESS: DLL downloaded successfully." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Download failed. File was not found at '$DownloadPath' after download." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: An error occurred during file download." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


# ------------------------------------------------------------------------------------------------------------------
# Part 4.0.0: Register DLL
# ------------------------------------------------------------------------------------------------------------------
Write-Host "`n-- Part 4: Registering DLL (v4.0.0) --" -ForegroundColor Cyan

# Use the Start-Process cmdlet to run regsvr32 silently
try {
    $RegSvrProcess = Start-Process -FilePath "regsvr32.exe" -ArgumentList "/s", $DownloadPath -Wait -PassThru
    
    # regsvr32 returns 0 for success
    if ($RegSvrProcess.ExitCode -eq 0) {
        Write-Host "SUCCESS: DLL registered successfully." -ForegroundColor Green
    } else {
        Write-Host "ERROR: DLL registration failed with Exit Code $($RegSvrProcess.ExitCode)." -ForegroundColor Red
        Write-Host "Note: regsvr32 output is suppressed (/s), so check system logs if issues persist." -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: Failed to execute regsvr32." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nScript execution complete." -ForegroundColor Yellow
# ------------------------------------------------------------------------------------------------------------------
