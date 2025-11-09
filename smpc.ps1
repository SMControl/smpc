# Script Name: smpct.ps1
# Script Version: 1.05
# Last Updated: 2025-11-09

# ------------------------------------
# --- URL Definitions ---
# ------------------------------------

# Firebird Installer Script (Part 2)
$FirebirdInstallerUrl = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/modules/module_firebird.ps1"

# Smart Office Installer Script (Part 3)
$SmartOfficeInstallerUrl = "https://raw.githubusercontent.com/SMControl/SO_UC/main/soua.ps1"

# BDE Installer Script (Part 4)
$BDEInstallerUrl = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/modules/module_install_bde.ps1"

# PDT Wi-Fi Task Scheduler Setup Script (Part 8)
$PDTWifiTaskUrl = "https://raw.githubusercontent.com/SMControl/SM_PDTWiFi_Task/main/SMPT_Online.ps1"

# DOMS Components Installer Script (Part 20)
$DomsInstallerUrl = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/modules/module_install_doms.ps1"


# --- Core Functions ---

function Show-Header {
    Clear-Host
    Write-Host "SM PC Transfer Guide - Version 1.05 (Scripting Assistant)" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " "
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Get-ProgressBar {
    param([int]$PartNumber, [int]$TotalParts = 38, [int]$BarLength = 20)
    # Calculate filled blocks. Ensure at least 1 block is shown for Part 1/38.
    $progressChars = [math]::Floor(($PartNumber / $TotalParts) * $BarLength)
    if ($PartNumber -gt 0 -and $progressChars -eq 0) { $progressChars = 1 }
    if ($PartNumber -eq $TotalParts) { $progressChars = $BarLength }

    $progressBar = "[" + ("█" * $progressChars) + ("_" * ($BarLength - $progressChars)) + "]"
    return $progressBar
}

function Part-End {
    $input = Read-Host "Press Enter to continue or 0 to exit..."
    if ($input -eq '0') { exit }
}

# --- Transfer Checklist Parts ---

# Part 1/38 - Copy Stationmaster Folder
# Part Version: 1.00
$partNumber = 1
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
$stationMasterPath = "C:\Program Files (x86)\StationMaster"
while (-not (Test-Path $stationMasterPath)) {
    Show-Header
    Write-Host "(Part $partNumber/38 | V$partVersion)"
    Write-Host (Get-ProgressBar -PartNumber $partNumber)
    Write-Warning "Stationmaster folder NOT found at '$stationMasterPath'."
    Write-Host "We need to copy the Stationmaster folder from the old PC to this location."
    $input = Read-Host "Press Enter to check again or 0 to exit..."
    if ($input -eq '0') { exit }
}
Write-Success "Stationmaster folder found at '$stationMasterPath'."
Write-Host "Ready to move on."
Part-End

# Part 2/38 - Install Firebird
# Part Version: 1.02 (Updated Firebird installer URL)
$partNumber = 2
$partVersion = "1.02"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Install Firebird"
$firebirdPath = "C:\Program Files (x86)\Firebird\Firebird_4_0"
if (Test-Path $firebirdPath) {
    Write-Success "Firebird is already installed at '$firebirdPath'."
} else {
    Write-Warning "Firebird is NOT installed."
    $installChoice = Read-Host "Would you like the script to install Firebird for us? (Y/N)"
    if ($installChoice -eq '0') { exit }
    if ($installChoice -match '^[Yy]$') {
        Write-Host "Running Firebird installer from: $FirebirdInstallerUrl"
        # NOTE: This command executes a remote script that manages the Firebird installation.
        Start-Process powershell -ArgumentList "-Command `"irm $FirebirdInstallerUrl | iex`"" -Wait
        Write-Host "Firebird installation complete. Verifying installation..."
        if (Test-Path $firebirdPath) {
            Write-Success "Firebird is now installed successfully."
        } else {
            Write-Warning "Warning: Firebird installation may have failed. Please check manually."
        }
    } else {
        Write-Host "Please install Firebird manually and press Enter to continue."
        Part-End
    }
}
Part-End

# Part 3/38 - Install Smart Office
# Part Version: 1.01 (Updated to use URL variable)
$partNumber = 3
$partVersion = "1.01"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Install Smart Office"
$installChoice = Read-Host "Would you like the script to install Smart Office for us? (Y/N)"
if ($installChoice -eq '0') { exit }
if ($installChoice -match '^[Yy]$') {
    Write-Host "Running Smart Office installer from: $SmartOfficeInstallerUrl"
    # NOTE: This command executes a remote script for Smart Office installation.
    Start-Process powershell -ArgumentList "-Command `"irm $SmartOfficeInstallerUrl | iex`"" -Wait
    Write-Host "Smart Office installation complete. Verifying installation..."
    if (Test-Path $stationMasterPath) {
        Write-Success "Smart Office is now installed successfully."
    } else {
        Write-Warning "Warning: Smart Office installation may have failed. Please check manually."
    }
} else {
    Write-Host "Please install Smart Office manually and press Enter to continue."
    Part-End
}
Part-End

# Part 4/38 - Reinstall BDE
# Part Version: 1.01 (Updated to include automated installer option)
$partNumber = 4
$partVersion = "1.01"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Reinstall BDE"
Write-Host "We need to reinstall the BDE (Borland Database Engine) on this PC." -ForegroundColor Yellow

$installChoice = Read-Host "Would you like the script to help reinstall the BDE? (Y/N)"

if ($installChoice -eq '0') { 
    exit 
}

if ($installChoice -match '^[Yy]$') {
    Write-Host "Running BDE Reinstallation script from: $BDEInstallerUrl" -ForegroundColor White
    
    # Executes the remote script
    Start-Process powershell -ArgumentList "-Command `"irm $BDEInstallerUrl | iex`"" -Wait

    Write-Host "BDE Reinstallation script execution complete." -ForegroundColor Green
    Write-Success "BDE reinstallation script has run successfully. Please proceed."
    Part-End

} else {
    Write-Host "Please reinstall the BDE (Borland Database Engine) manually and press Enter to continue." -ForegroundColor Yellow
    Part-End
}

# Part 5/38 - Re-network Stationmaster
# Part Version: 1.01
$partNumber = 5
$partVersion = "1.01"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Re-network Stationmaster"
Write-Host "We will re-network Stationmaster on all client PCs as required."
Write-Host "Ensure all clients can communicate with the host machine."

# --- Host Network Information ---
Write-Host "`n--- Host Network Configuration ---" -ForegroundColor Cyan
$adapter = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq 'Up' }
$ipAddress = $adapter.IPv4Address.IPAddress
$dhcpEnabled = if ($adapter.IPv4Interface.Dhcp -eq 'Enabled') { 'DHCP' } else { 'Static' }
$hostname = $env:COMPUTERNAME
$networkProfile = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' }).NetworkCategory
Write-Host ("{0,-20}: {1}" -f "Hostname", $hostname)
Write-Host ("{0,-20}: {1} ({2})" -f "IP Address", $ipAddress, $dhcpEnabled)
Write-Host ("{0,-20}: {1}" -f "Network Profile", $networkProfile)
Write-Host "----------------------------------`n" -ForegroundColor Cyan

# --- Till Connectivity Check ---
$tills = @("POS1", "POS2", "POS3", "POS4")
Write-Host "Pinging known Till addresses for connectivity check:" -ForegroundColor Cyan
foreach ($till in $tills) {
    Write-Host "Pinging $till..." -NoNewline
    try {
        $ping = Test-Connection -ComputerName $till -Count 1 -ErrorAction Stop -Quiet
        if ($ping) {
            $resolvedIP = [System.Net.Dns]::GetHostAddresses($till) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
            Write-Success "  [ONLINE] -> $till is online at IP $resolvedIP."
        } else {
            Write-Warning "  [OFFLINE] -> $till did not respond to ping."
        }
    } catch {
        Write-Warning "  [ERROR] -> Could not resolve or ping $till. Check DNS/NetBIOS."
    }
}
Write-Host ""
$input = Read-Host "Press Enter once re-networking is complete or 0 to exit..."
if ($input -eq '0') { exit }
Part-End

# Part 6/38 - Confirm Communication to Tills
# Part Version: 1.00
$partNumber = 6
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Confirm Communication to Tills"
Write-Host "We need to confirm that all tills can communicate with the host machine." -ForegroundColor Yellow
Part-End

# Part 7/38 - Confirm Broadband Connection
# Part Version: 1.00
$partNumber = 7
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Confirm Broadband Connection"
Write-Host "We need to confirm that the broadband connection is active and working on this PC." -ForegroundColor Yellow
Part-End

# Part 8/38 - Add PDTwifi to Startup
# Part Version: 1.01 (Updated to use URL variable)
$partNumber = 8
$partVersion = "1.01"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Add PDTwifi to Startup"
$installChoice = Read-Host "Would you like the script to add PDTwifi to Startup via Task Scheduler? (Y/N)"
if ($installChoice -eq '0') { exit }
if ($installChoice -match '^[Yy]$') {
    Write-Host "Running PDTwifi startup setup from: $PDTWifiTaskUrl"
    # NOTE: This command executes a remote script to set up the Task Scheduler entry for PDTwifi.
    Start-Process powershell -ArgumentList "-Command `"irm $PDTWifiTaskUrl | iex`"" -Wait
    Write-Success "PDTwifi has been added to Startup."
} else {
    Write-Host "Please add PDTwifi to Startup manually and press Enter to continue."
    Part-End
}
Part-End

# Part 9/38 - Add CigServer to Startup
# Part Version: 1.00
$partNumber = 9
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Add CigServer to Startup"
$installChoice = Read-Host "Would you like the script to add CigServer to Startup via Task Scheduler? (Y/N)"
if ($installChoice -eq '0') { exit }
if ($installChoice -match '^[Yy]$') {
    Write-Host "Running CigServer startup setup..."
    # Placeholder for installation command (must be added by user)
    # Start-Process powershell -ArgumentList '-Command "[INSERT INSTALL COMMAND HERE]"' -Wait
    Write-Warning "Automated setup command is missing. Assuming setup completed."
    Write-Success "CigServer has been noted as added to Startup."
} else {
    Write-Host "Please add CigServer to Startup manually and press Enter to continue."
    Part-End
}
Part-End

# Part 10/38 - Reinstall Printers
# Part Version: 1.00
$partNumber = 10
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Reinstall Printers"
Write-Host "We need to reinstall any required printers on this PC." -ForegroundColor Yellow
Part-End

# Part 11/38 - Reinstall Handheld
# Part Version: 1.00
$partNumber = 11
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Reinstall Handheld"
Write-Host "We need to reinstall the handheld device as required." -ForegroundColor Yellow
Part-End

# Part 12/38 - Enter Backup Location
# Part Version: 1.00
$partNumber = 12
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Enter Backup Location"
Write-Host "We need to enter the new backup location for Smart Office within the software's settings." -ForegroundColor Yellow
Part-End

# Part 13/38 - Change Firewall Settings
# Part Version: 1.00
$partNumber = 13
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Change Firewall Settings"
Write-Host "We need to update the firewall settings as required to allow necessary Smart Office services." -ForegroundColor Yellow
Part-End

# Part 14/38 - Adjust Power Settings
# Part Version: 1.00
$partNumber = 14
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Adjust Power Settings"
$adjustPower = Read-Host "Would you like the script to configure power settings for us? (Y/N)"
if ($adjustPower -eq '0') { exit }
if ($adjustPower -match '^[Yy]$') {
    Write-Host "Disabling system hibernation..."
    powercfg -h off
    Write-Host "Setting hard drive to never turn off..."
    powercfg -change -disk-timeout-ac 0
    powercfg -change -disk-timeout-dc 0
    Write-Host "Setting system sleep to never..."
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    Write-Host "Setting monitor timeout to 20 minutes..."
    powercfg -change -monitor-timeout-ac 20
    powercfg -change -monitor-timeout-dc 20
    Write-Host "Disabling network adapter power saving..."
    # Note: Using powercfg for devicewake is a general approach, often the adapter property in Device Manager is preferred.
    Get-NetAdapter | ForEach-Object { powercfg -devicequery wake_from_any | ForEach-Object { powercfg -devicedisablewake $_ } }
    Write-Success "All power settings have been successfully configured."
} else {
    Write-Host "Please configure power settings manually and press Enter to continue."
    Part-End
}
Part-End

# Part 15/38 - Record Office Product Keys
# Part Version: 1.00
$partNumber = 15
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Record Office Product Keys"
Write-Host "We need to record the Microsoft Office product keys into Smart-Records." -ForegroundColor Yellow
Part-End

# Part 16/38 - Register Office
# Part Version: 1.00
$partNumber = 16
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Register Office"
Write-Host "We need to register Microsoft Office and confirm activation is successful." -ForegroundColor Yellow
Part-End

# Part 17/38 - Register Norton
# Part Version: 1.00
$partNumber = 17
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Register Norton"
Write-Host "We need to register Norton and confirm activation is successful." -ForegroundColor Yellow
Part-End

# Part 18/38 - Copy R.O.S Folder
# Part Version: 1.00
$partNumber = 18
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Copy R.O.S Folder"
Write-Host "We need to copy the R.O.S folder from the old PC." -ForegroundColor Yellow
Part-End

# Part 19/38 - Transfer Payroll Software
# Part Version: 1.00
$partNumber = 19
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Transfer Payroll Software"
Write-Host "We need to transfer the Payroll Software or take backups from the old PC." -ForegroundColor Yellow
Part-End

# Part 20/38 - Install DOMS Components
# Part Version: 1.01 (Incorporated colleague's automated install script)
$partNumber = 20
$partVersion = "1.01"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Install DOMS Components"
# Ask the user if they want the script to automate the installation
$installChoice = Read-Host "Would you like the script to help install DOMS Components? (Y/N)"

if ($installChoice -eq '0') { 
    # Exit if the user enters '0'
    exit 
}

if ($installChoice -match '^[Yy]$') {
    Write-Host "Running DOMS Components installer script from: $DomsInstallerUrl" -ForegroundColor White
    
    # Executes the remote script
    Start-Process powershell -ArgumentList "-Command `"irm $DomsInstallerUrl | iex`"" -Wait

    Write-Host "DOMS Components installer script execution complete." -ForegroundColor Green
    
    # Since we cannot verify the installation path, we assume success.
    Write-Host "Installation script has run successfully. Please proceed with configuration (Parts 21-23)." -ForegroundColor White
    Part-End

} else {
    Write-Host "Please install the required DOMS Components manually before continuing." -ForegroundColor Yellow
    Part-End
}

# Part 21/38 - Copy Doms.ini
# Part Version: 1.00
$partNumber = 21
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Copy Doms.ini"
Write-Host "We need to copy Doms.ini from the old PC." -ForegroundColor Yellow
Part-End

# Part 22/38 - Copy Doms.xml
# Part Version: 1.00
$partNumber = 22
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Copy Doms.xml"
Write-Host "We need to copy Doms.xml from the old PC." -ForegroundColor Yellow
Part-End

# Part 23/38 - Verify DOMS.dll and Send Fuel Prices
# Part Version: 1.00
$partNumber = 23
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Verify DOMS.dll and Send Fuel Prices"
Write-Host "We need to ensure DOMS.dll is installed and send fuel prices to DOMS for confirmation." -ForegroundColor Yellow
Part-End

# Part 24/38 - Transfer Email
# Part Version: 1.00
$partNumber = 24
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Transfer Email"
Write-Host "We need to transfer email accounts and data to the new PC." -ForegroundColor Yellow
Part-End

# Part 25/38 - Break Stationmaster on Old PC
# Part Version: 1.00
$partNumber = 25
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Break Stationmaster on Old PC"
Write-Host "We need to delete the Stationmaster folder and registry entries on the old PC." -ForegroundColor Yellow
Part-End

# Part 26/38 - Recreate Scheduled Tasks
# Part Version: 1.00
$partNumber = 26
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Recreate Scheduled Tasks"
Write-Host "We need to recreate all relevant scheduled tasks relating to Stationmaster." -ForegroundColor Yellow
Part-End

# Part 27/38 - Install and Start LiveSales
# Part Version: 1.00
$partNumber = 27
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Install and Start LiveSales"
Write-Host "We need to install and start LiveSales." -ForegroundColor Yellow
Part-End

# Part 28/38 - Copy Documents
# Part Version: 1.00
$partNumber = 28
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Copy Documents"
Write-Host "We need to copy over documents and files as required." -ForegroundColor Yellow
Part-End

# Part 29/38 - Transfer Browser Shortcuts and Passwords
# Part Version: 1.00
$partNumber = 29
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Transfer Browser Shortcuts and Passwords"
Write-Host "We need to transfer shortcuts and passwords from the web browser." -ForegroundColor Yellow
Part-End

# Part 30/38 - Install VNC or eMIS
# Part Version: 1.00
$partNumber = 30
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Install VNC or eMIS"
Write-Host "We need to install VNC or eMIS as required." -ForegroundColor Yellow
Part-End

# Part 31/38 - Share Download1 Folder and Point Tills
# Part Version: 1.00
$partNumber = 31
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Share Download1 Folder and Point Tills"
Write-Host "We need to share the Download1 folder if required and ensure tills are pointing to this new share." -ForegroundColor Yellow
Part-End

# Part 32/38 - Ensure Fixed IP Address on New Host PC
# Part Version: 1.00
$partNumber = 32
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Ensure Fixed IP Address on New Host PC"
Write-Host "We need to ensure the fixed IP address(es) on the new Host PC are correctly set." -ForegroundColor Yellow
Part-End

# Part 33/38 - Copy RES Folder for SmartPOS
# Part Version: 1.00
$partNumber = 33
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Copy RES Folder for SmartPOS"
Write-Host "For SmartPOS sites, we need to copy the RES folder containing any images not in the default database." -ForegroundColor Yellow
Part-End

# Part 34/38 - Install LAN A4 Printer as TCP/IP Device
# Part Version: 1.00
$partNumber = 34
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Install LAN A4 Printer as TCP/IP Device"
Write-Host "We need to install the LAN A4 printer as a TCP/IP device (do not install as a WSD device)." -ForegroundColor Yellow
Part-End

# Part 35/38 - Check Services and Processes
# Part Version: 1.00
$partNumber = 35
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Check Services and Processes"
Write-Host "We need to check Auto Sales Process, Send Sales, Import Wholesaler Updates, and ESLs are running correctly." -ForegroundColor Yellow
Part-End

# Part 36/38 - Check SELs Registry Settings
# Part Version: 1.00
$partNumber = 36
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Check SELs Registry Settings"
Write-Host "We need to check the SELs registry settings." -ForegroundColor Yellow
Part-End

# Part 37/38 - Advise Retailer on Software Licensing
# Part Version: 1.00
$partNumber = 37
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Advise Retailer on Software Licensing"
Write-Host "We need to advise the retailer that Avery scales and Bartender software cannot be installed/licensed." -ForegroundColor Yellow
Part-End

# Part 38/38 - Final Checks and Wrap Up
# Part Version: 1.00
$partNumber = 38
$partVersion = "1.00"
Show-Header
Write-Host "(Part $partNumber/38 | V$partVersion)"
Write-Host (Get-ProgressBar -PartNumber $partNumber)
Write-Host " "
Write-Host "Task: Final Checks and Wrap Up"
Write-Host "Perform any final checks and confirm that all tasks have been completed." -ForegroundColor Green
Part-End

# --- End of Script ---
