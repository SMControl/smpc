Write-Host "smpc.ps1 Version 1.04"
### Recent Changes
# - Updated 'Remove Rubbish from Windows 11' to open in a visible PowerShell window

### Part 0: Script Prep (Version 1.0)
Write-Host "Checking if script is running as Administrator..."
# Check if running as Administrator
$adminCheck = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$adminRole = [System.Security.Principal.WindowsPrincipal]$adminCheck
if (-not $adminRole.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator! Exiting..." -ForegroundColor Red
    Exit
}

Write-Host "Ensuring C:\winsm directory exists..."
# Ensure C:\winsm directory exists
if (!(Test-Path "C:\winsm")) {
    New-Item -ItemType Directory -Path "C:\winsm" | Out-Null
}

### Ask if this is a Host PC
$hostPC = Read-Host "Press 1 if this is a HOST PC, otherwise any other key..." -ForegroundColor Green

### Part 1: General Setup for All PCs (Version 1.1)
Write-Host "Applying power settings..."
# Power Settings
powercfg -h off  # Disable hibernation
powercfg -change -standby-timeout-ac 0  # Prevent PC from sleeping
powercfg -change -monitor-timeout-ac 20  # Allow monitors to turn off after 20 minutes
powercfg -change -disk-timeout-ac 0  # Ensure hard drives never sleep

Write-Host "Removing unnecessary Windows apps in a separate PowerShell window..."
# Remove Rubbish from Windows 11 in a new visible PowerShell window
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & ([scriptblock]::Create((irm 'https://debloat.raphi.re/'))) -RunDefaults -Silent"

Write-Host "Installing essential software..."
# Install Winget Packages
winget install gnu.nano --silent  # Shell Text Editor

Write-Host "Installing Firebird with StationMaster settings..."
# Install Firebird with StationMaster Settings
irm https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1 | iex

Write-Host "Pinning Firebird in Winget to prevent upgrades..."
# Pin Firebird in WinGet to prevent upgrades
winget pin add Firebird

Write-Host "Scheduling daily update task at 5AM..."
# Schedule Daily Updates at 5AM
Register-ScheduledTask -TaskName "SO Update Apps" -Description "Updates all installed apps daily at 5am" `
    -Action (New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -Command 'winget upgrade --all --silent --accept-source-agreements --accept-package-agreements'" `
    ) `
    -Trigger (New-ScheduledTaskTrigger -Daily -At 5:00AM) `
    -Principal (New-ScheduledTaskPrincipal -UserId "$env:COMPUTERNAME\$env:USERNAME" -LogonType ServiceAccount -RunLevel Highest) `
    -Force

### Part 2: Host PC Only Options (Version 1.2)
if ($hostPC -eq "1") {
    Write-Host "Running Host PC specific tasks..."
    
    Write-Host "Checking and downloading the latest Smart Office Setup.exe..."
    # Check and get new versions of Smart Office Setup.exe
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SMControl/SO_UC/main/SO_UC.exe" -OutFile "C:\winsm\SO_UC.exe"
    Write-Host "Running Smart Office Setup.exe..."
    Start-Process "C:\winsm\SO_UC.exe" -Wait
    
    Write-Host "Scheduling daily restart for PDTWiFi64 at 5AM..."
    # Restart PDTWiFi64 Daily at 5AM
    Register-ScheduledTask -TaskName "SO PDTWiFi" -Description "Restarts PDTWiFi at 5am Daily" `
        -Action (New-ScheduledTaskAction -Execute "powershell.exe" `
            -Argument "-Command Stop-Process -Name PDTWiFi64 -Force; Start-Sleep 5; Start-Process 'C:\Program Files (x86)\StationMaster\PDTWiFi64.exe'" `
        ) `
        -Trigger (New-ScheduledTaskTrigger -Daily -At 5:00AM) `
        -Principal (New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest) `
        -Force
}

Write-Host "Finalizing setup and launching Windows Setup Utility..."
### Always Last: Launch Windows Setup Utility for Installing Programs and Config Tasks
irm christitus.com/win | iex
