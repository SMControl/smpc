Write-Host "smpc.ps1 Version 1.01"
### Recent Changes
# - Merged Parts 1-6 into Part 1 for all PCs
# - Renamed Host PC section to Part 2
# - Updated versioning structure

### Ask if this is a Host PC
$hostPC = Read-Host "Press 1 if this is a HOST PC, otherwise press any other key"

### Part 1: General Setup for All PCs (Version 1.1)
# Power Settings
powercfg -h off  # Disable hibernation
powercfg -change -standby-timeout-ac 0  # Prevent PC from sleeping
powercfg -change -monitor-timeout-ac 20  # Allow monitors to turn off after 20 minutes
powercfg -change -disk-timeout-ac 0  # Ensure hard drives never sleep

# Remove Rubbish from Windows 11
& ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -RunDefaults -Silent

# Install Winget Packages
winget install gnu.nano --silent  # Shell Text Editor

# Install Firebird with StationMaster Settings
irm https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1 | iex

# Pin Firebird in WinGet to prevent upgrades
winget pin add Firebird

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
    
    # Ensure C:\winsm directory exists
    if (!(Test-Path "C:\winsm")) {
        New-Item -ItemType Directory -Path "C:\winsm" | Out-Null
    }
    
    # Check and get new versions of Smart Office Setup.exe
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SMControl/SO_UC/main/SO_UC.exe" -OutFile "C:\winsm\SO_UC.exe"
    Start-Process "C:\winsm\SO_UC.exe"
    
    # Restart PDTWiFi64 Daily at 5AM
    Register-ScheduledTask -TaskName "SO PDTWiFi" -Description "Restarts PDTWiFi at 5am Daily" `
        -Action (New-ScheduledTaskAction -Execute "powershell.exe" `
            -Argument "-Command Stop-Process -Name PDTWiFi64 -Force; Start-Sleep 5; Start-Process 'C:\Program Files (x86)\StationMaster\PDTWiFi64.exe'" `
        ) `
        -Trigger (New-ScheduledTaskTrigger -Daily -At 5:00AM) `
        -Principal (New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest) `
        -Force
}

### Always Last: Launch Windows Setup Utility for Installing Programs and Config Tasks
irm christitus.com/win | iex
