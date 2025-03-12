# Function: Show-Header
# Description: Clears the screen and displays the script title and version.
function Show-Header {
    Clear-Host
    Write-Host "SM PC Transfer Helper - Version 1.00" -ForegroundColor Cyan
    Write-Host "------------------------------------" -ForegroundColor Cyan
    Write-Host " "
}
# Function: Part-End
# Description: Pauses execution, allowing the user to continue or exit the script.
function Part-End {
    Write-Host ""
    Write-Host ""
    $input = Read-Host "Press Enter to continue or 0 to exit..."
    if ($input -eq '0') { exit }
}
# Part 0/38 - Pre-Checks
# PartVersion=1.00
# status=
# Section A: Check Administrator Privileges
$adminCheck = [System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    Write-Host "Right-click on the Start button and select 'Terminal (Admin)' to open up a Terminal with the correct permissions." -ForegroundColor White
    Read-Host "Press Enter to exit..."
    exit
}
# Section B: Check and Rename Hostname
$hostname = $env:COMPUTERNAME
Write-Host "Current Hostname: $hostname" -ForegroundColor Cyan
Write-Host "It is recommended to name the PC as 'BO' followed by the site number (e.g., BO123 for site 123)." -ForegroundColor Yellow
$renameChoice = Read-Host "Would you like to rename the PC? Press Enter to continue or Y to rename"
if ($renameChoice -match '^[Yy]$') {
    $newHostname = Read-Host "Enter the new hostname (e.g., BO123)"
    Write-Host "Renaming PC to $newHostname..." -ForegroundColor White
    Rename-Computer -NewName $newHostname -Force
    Write-Host "Hostname changed successfully. A restart is required." -ForegroundColor Green
    $restartChoice = Read-Host "Would you like to restart now? (Y/N)"
    if ($restartChoice -match '^[Yy]$') {
        Restart-Computer -Force
    } else {
        Write-Host "Please restart manually and rerun this script." -ForegroundColor Yellow
        exit
    }
    exit
}
# Part 1/38 - Copy Stationmaster Folder
# PartVersion=1.00
# Status = finished here
Show-Header
Write-Host "(Part 1/38)" -ForegroundColor Yellow
Write-Host "Task: Copy Stationmaster Folder" -ForegroundColor Green
Write-Host "[█_____________________________________]" -ForegroundColor Magenta
Write-Host " "
$stationMasterPath = "C:\Program Files (x86)\StationMaster"
while (-not (Test-Path $stationMasterPath)) {
    Show-Header
    Write-Host "(Part 1/38)" -ForegroundColor Yellow
    Write-Host "Task: Copy Stationmaster Folder" -ForegroundColor Green
    Write-Host "[█_____________________ ]" -ForegroundColor Magenta
    Write-Host "Stationmaster folder NOT found at '$stationMasterPath'." -ForegroundColor Red
    Write-Host "Please copy the Stationmaster folder from the old PC to this location." -ForegroundColor White
    $input = Read-Host "Press Enter to check again or 0 to exit script."
    if ($input -eq '0') { exit }
}
Write-Host "Stationmaster folder found at '$stationMasterPath'." -ForegroundColor Green
Part-End
# Part 2/38 - Install Firebird
# PartVersion=1.00
# Status= looks ok
Show-Header
Write-Host "(Part 2/38)" -ForegroundColor Yellow
Write-Host "Task: Install Firebird" -ForegroundColor Green
Write-Host "[██____________________________________]" -ForegroundColor Magenta
Write-Host " "
$firebirdPath = "C:\Program Files (x86)\Firebird\Firebird_4_0"
if (Test-Path $firebirdPath) {
    Write-Host "Firebird is already installed." -ForegroundColor Green
    Part-End
} else {
    Write-Host "Firebird is NOT installed." -ForegroundColor Red
    $installChoice = Read-Host "Would you like the script to install Firebird for you? (Y/N)"
    if ($installChoice -match '^[Yy]$') {
        Write-Host "Running Firebird installer..." -ForegroundColor White
        Start-Process powershell -ArgumentList '-Command "irm https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1 | iex"' -Wait
        Write-Host "Firebird installation complete. Verifying installation..." -ForegroundColor White
        if (Test-Path $firebirdPath) {
            Write-Host "Firebird is now installed successfully." -ForegroundColor Green
            Part-End
        } else {
            Write-Host "Warning: Firebird installation may have failed. Please check manually." -ForegroundColor Red
            Part-End
        }
    } else {
        Write-Host "Please install Firebird." -ForegroundColor White
        Part-End
    }
}
# Part 3/38 - Install Smart Office
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 3/38)" -ForegroundColor Yellow
Write-Host "Task: Install SmartOffice" -ForegroundColor Green
Write-Host "[███___________________________________]" -ForegroundColor Magenta
Write-Host " "
$installChoice = Read-Host "Would you like the script to help install SmartOffice? (Y/N)"
if ($installChoice -eq '0') { exit }
if ($installChoice -match '^[Yy]$') {
    Write-Host "Running Smart Office installer..." -ForegroundColor White
    Start-Process powershell -ArgumentList '-Command "irm https://raw.githubusercontent.com/SMControl/SO_UC/main/soua.ps1 | iex"' -Wait
    Write-Host "Smart Office installation complete. Verifying installation..." -ForegroundColor White
    if (Test-Path $stationMasterPath) {
        Write-Host "SmartOffice is now installed successfully." -ForegroundColor Green
        Part-End
    } else {
        Write-Host "Warning: SmartOffice installation may have failed. Please check manually." -ForegroundColor Red
        Part-End
    }
} else {
    Write-Host "Please install SmartOffice." -ForegroundColor White
    Part-End
}
# Part 4/38 - Reinstall BDE
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 4/38)" -ForegroundColor Yellow
Write-Host "Task: Reinstall BDE" -ForegroundColor Green
Write-Host "[████__________________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Please reinstall the BDE (Borland Database Engine) on this PC." -ForegroundColor White
Part-End
# Part 5/38 - Re-network Stationmaster
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 5/38)" -ForegroundColor Yellow
Write-Host "Task: Re-network Stationmaster" -ForegroundColor Green
Write-Host "[█████_________________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Please re-network Stationmaster on all client PCs as required." -ForegroundColor White
Write-Host "Ensure all clients can communicate with the host machine." -ForegroundColor White
# Section A: Display Network Information
Write-Host "Gathering Network Information..."
Write-Host ""
$adapter = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq 'Up' }
$ipAddress = $adapter.IPv4Address.IPAddress
$dhcpEnabled = if ($adapter.IPv4Interface.Dhcp -eq 'Enabled') { 'DHCP' } else { 'Static' }
$hostname = $env:COMPUTERNAME
$networkProfile = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' }).NetworkCategory
Write-Host "Hostname: $hostname" -ForegroundColor Cyan
Write-Host "Host IP Address: $ipAddress ($dhcpEnabled)" -ForegroundColor Cyan
Write-Host "Gateway: $($adapter.IPv4DefaultGateway.NextHop)" -ForegroundColor Cyan
Write-Host "Network Profile: $networkProfile" -ForegroundColor Cyan
Part-End
# Part 6/38 - Confirm Communication to Tills
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 6/38)" -ForegroundColor Yellow
Write-Host "Task: Confirm Communication to Tills" -ForegroundColor Green
Write-Host "[██████________________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Please confirm that all tills can communicate with the host machine." -ForegroundColor White
# Section A: Check Till Connectivity
Write-Host "Checking what Tills are on the Network..." -ForegroundColor Cyan
$tills = @("POS1", "POS2", "POS3", "POS4")
foreach ($till in $tills) {
    Write-Host "Pinging $till..." -ForegroundColor White
    $ping = Test-Connection -ComputerName $till -Count 1 -Quiet
    if ($ping) {
        $resolvedIP = [System.Net.Dns]::GetHostAddresses($till) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
        Write-Host "$till is online at IP $resolvedIP." -ForegroundColor Green
    } else {
        Write-Host "$till did not respond." -ForegroundColor Red
    }
}
# Section B: Check Till Shared Folders Accessibility
Write-Host "Check Till Shares..." -ForegroundColor Cyan
foreach ($till in $onlineTills) {
    $sharePath = "\\$till\c$"
    Write-Host "Checking shared folder access on $till..." -ForegroundColor White
    if (Test-Path $sharePath) {
        Write-Host "Successfully accessed shared folder on $till ($sharePath)." -ForegroundColor Green
    } else {
        Write-Host "Unable to access shared folder on $till ($sharePath). Please Check." -ForegroundColor Red
    }
}
Part-End
# Part 7/38 - Confirm Broadband Connection (Pointless here)
# Part 8/38 - Add PDTWiFi64 to Startup
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 8/38)" -ForegroundColor Yellow
Write-Host "Task: Add PDTWiFi64 to Startup" -ForegroundColor Green
Write-Host "[████████________________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Choose how you want PDTWiFi64 to be setup:" -ForegroundColor White
Write-Host " "
Write-Host "1 - I will handle this myself." -ForegroundColor Yellow
Write-Host "2 - Configure via Startup Folder. [Classic]"
Write-Host "3 - Configure via Scheduled Task [Run at Startup and restart daily at 5am]" -ForegroundColor Cyan
Write-Host "4 - Configure as a Windows System Service [Let Windows handle it but no Tray Icon]" -ForegroundColor Green
$installChoice = Read-Host "Enter 1, 2, 3, or 4 (or 0 to exit)"
if ($installChoice -eq '0') { exit }
if ($installChoice -eq '1') {
    Write-Host " "
    Write-Host "Configure PDTWiFi64 yourself. " -ForegroundColor Yellow
    Part-End
}
if ($installChoice -eq '2') {
    Write-Host "Setting up PDTWiFi64 as a regular startup item.." -ForegroundColor White
    Start-Process powershell -ArgumentList '-Command "[INSERT PDTWIFI TRAY ICON SETUP COMMAND HERE]"' -Wait
    Write-Host "PDTWiFi64 has been added to the Startup Folder." -ForegroundColor Green
    Part-End
}
if ($installChoice -eq '3') {
    Write-Host "Setting up PDTWiFi64 via Scheduled Task..." -ForegroundColor White
    Start-Process powershell -ArgumentList '-Command "[INSERT PDTWIFI SCHEDULED TASK SETUP COMMAND HERE]"' -Wait
    Write-Host "PDTWiFi64 has been added via Scheduled Task called SO PDTWiFi." -ForegroundColor Green
    Part-End
}
if ($installChoice -eq '4') {
    Write-Host "Setting up PDTWiFi64 to run as a service with no tray icon.." -ForegroundColor White
    Start-Process powershell -ArgumentList '-Command "[INSERT PDTWIFI SERVICE SETUP COMMAND HERE]"' -Wait
    Write-Host "PDTWiFi64 (service) has been added as a Windows System Service named SO PDTWiFi" -ForegroundColor Green
    Part-End
}
# Part 9/38 - Add CigServer to Startup
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 9/38)" -ForegroundColor Yellow
Write-Host "Task: Add CigServer to Startup" -ForegroundColor Green
Write-Host "[█████████_______________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Choose how you want CigServer to be added to startup:" -ForegroundColor White
Write-Host " "
Write-Host "1 - I will handle this myself." -ForegroundColor Yellow
Write-Host "2 - Set it up via Startup Folder. [Classic]" -ForegroundColor Cyan
Write-Host "3 - Set it up as a Windows System Service [Let Windows handle it but no Tray Icon]" -ForegroundColor Green
$installChoice = Read-Host "Enter 1, 2, or 3 (or 0 to exit)"
if ($installChoice -eq '0') { exit }
if ($installChoice -eq '1') {
    Write-Host " "
    Write-Host "Configure CigServer yourself" -ForegroundColor Yellow
    Part-End
}
if ($installChoice -eq '2') {
    Write-Host "Setting up CigServer as a regular startup item..." -ForegroundColor White
    Start-Process powershell -ArgumentList '-Command "[INSERT CIGSERVER TRAY ICON SETUP COMMAND HERE]"' -Wait
    Write-Host "CigServer has been added to the Startup Folder." -ForegroundColor Green
    Part-End
}
if ($installChoice -eq '3') {
    Write-Host "Setting up CigServer to run as a service with no tray icon..." -ForegroundColor White
    Start-Process powershell -ArgumentList '-Command "[INSERT CIGSERVER SERVICE SETUP COMMAND HERE]"' -Wait
    Write-Host "CigServer has been added as a Windows System Service named SO CigServer" -ForegroundColor Green
    Part-End
}
# Part 10/38 - Reinstall Printers
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 10/38)" -ForegroundColor Yellow
Write-Host "Task: Reinstall Printers" -ForegroundColor Green
Write-Host "[██████████________________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Setup all printers." -ForegroundColor White
Part-End
# Part 11/38 - Reinstall Handheld
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 11/38)" -ForegroundColor Yellow
Write-Host "Task: Reinstall Handheld" -ForegroundColor Green
Write-Host "[███████████_______________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Setup Handheld and confirm its working." -ForegroundColor White
Part-End
# Part 12/38 - Enter New Backup Location for Stationmaster
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 12/38)" -ForegroundColor Yellow
Write-Host "Task: Enter New Backup Location" -ForegroundColor Green
Write-Host "[████████████______________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Configure Backups" -ForegroundColor White
Part-End
# Part 13/38 - Change Firewall as Required
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 13/38)" -ForegroundColor Yellow
Write-Host "Task: Change Firewall as Required" -ForegroundColor Green
Write-Host "[█████████████_____________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Review and adjust the firewall settings if necessary." -ForegroundColor White
Part-End
# Part 14/38 - Configure Power Settings
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 14/38)" -ForegroundColor Yellow
Write-Host "Task: Configure Power Settings" -ForegroundColor Green
Write-Host "[██████████████___________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Would you like the script to configure power settings? (Y/N)" -ForegroundColor White
Write-Host " "
$powerChoice = Read-Host "Enter Y or N (or 0 to exit)"
if ($powerChoice -eq '0') { exit }
if ($powerChoice -match '^[Yy]$') {
    Write-Host "Configuring power settings..." -ForegroundColor White
    Write-Host " - Disabling standby timeout on AC power.." -ForegroundColor Cyan
    powercfg -change -standby-timeout-ac 0
    Write-Host " - Setting monitor timeout to 20 minutes.." -ForegroundColor Cyan
    powercfg -change -monitor-timeout-ac 20
    Write-Host " - Preventing hard disks from spinning down.." -ForegroundColor Cyan
    powercfg -change -disk-timeout-ac 0
    Write-Host " - Disabling system hibernation.." -ForegroundColor Cyan
    powercfg -h off
    Write-Host "Power settings have been configured" -ForegroundColor Green
    Part-End
} else {
    Write-Host "Configure power settings yourself" -ForegroundColor Yellow
    Part-End
}
# Part 15/38 - Record Product Keys
Show-Header
Write-Host "(Part 15/38)" -ForegroundColor Yellow
Write-Host "Task: Record Product Keys" -ForegroundColor Green
Write-Host "[███████████████__________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Record the product keys of installed software in Smart-Records." -ForegroundColor White
Part-End
# Part 16/38 - Register Office and Norton
Show-Header
Write-Host "(Part 16/38)" -ForegroundColor Yellow
Write-Host "Task: Register Office and Norton" -ForegroundColor Green
Write-Host "[████████████████________________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Register Microsoft Office and Norton. Open programs to confirm activation." -ForegroundColor White
Part-End
# Part 17/38 - Copy R.O.S Folder
Show-Header
Write-Host "(Part 17/38)" -ForegroundColor Yellow
Write-Host "Task: Copy R.O.S Folder" -ForegroundColor Green
Write-Host "[█████████████████_______________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Copy the R.O.S folder from the old PC to the new one." -ForegroundColor White
Part-End
# Part 18/38 - Transfer Payroll Software
Show-Header
Write-Host "(Part 18/38)" -ForegroundColor Yellow
Write-Host "Task: Transfer Payroll Software" -ForegroundColor Green
Write-Host "[██████████████████______________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Transfer the payroll software or take backups from the old PC." -ForegroundColor White
Part-End
# Part 19/38 - Install DOMS Components
Show-Header
Write-Host "(Part 19/38)" -ForegroundColor Yellow
Write-Host "Task: Install DOMS Components" -ForegroundColor Green
Write-Host "[███████████████████_____________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Install the required DOMS components." -ForegroundColor White
Part-End
# Part 20/38 - Copy Doms.ini / Doms.xml
Show-Header
Write-Host "(Part 20/38)" -ForegroundColor Yellow
Write-Host "Task: Copy Doms.ini / Doms.xml" -ForegroundColor Green
Write-Host "[████████████████████____________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Copy the Doms.ini and Doms.xml files from the old PC to the new one." -ForegroundColor White
Part-End
# Part 21/38 - Ensure DOMS.dll Installed and Send Fuel Prices
Show-Header
Write-Host "(Part 21/38)" -ForegroundColor Yellow
Write-Host "Task: Ensure DOMS.dll Installed and Send Fuel Prices" -ForegroundColor Green
Write-Host "[█████████████████████___________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Make sure DOMS.dll is installed. Send fuel prices to DOMS for confirmation." -ForegroundColor White
Part-End
# Part 22/38 - Transfer Email
Show-Header
Write-Host "(Part 22/38)" -ForegroundColor Yellow
Write-Host "Task: Transfer Email" -ForegroundColor Green
Write-Host "[██████████████████████_________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Transfer email accounts and settings to the new PC." -ForegroundColor White
Part-End

# Part 23/38 - Remove Stationmaster from Old PC
Show-Header
Write-Host "(Part 23/38)" -ForegroundColor Yellow
Write-Host "Task: Remove Stationmaster from Old PC" -ForegroundColor Green
Write-Host "[███████████████████████________________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Break Stationmaster on the old PC by deleting the Stationmaster folder and registry entries." -ForegroundColor White
Part-End

# Part 24/38 - Recreate Scheduled Tasks
# PartVersion=1.00
# status = want to do a massive script here for managing all types of tasks, sales send and process, bwg, esl, eurodata etc
Show-Header
Write-Host "(Part 24/38)" -ForegroundColor Yellow
Write-Host "Task: Recreate Scheduled Tasks" -ForegroundColor Green
Write-Host "[████████████████████████_______________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Recreate all relevant scheduled tasks related to Stationmaster." -ForegroundColor White
Part-End

# Part 25/38 - Install and Start LiveSales
# PartVersion=1.00
# status=untested
Show-Header
Write-Host "(Part 25/38)" -ForegroundColor Yellow
Write-Host "Task: Install and Start LiveSales" -ForegroundColor Green
Write-Host "[█████████████████████████_____________]" -ForegroundColor Magenta
Write-Host " "
$installChoice = Read-Host "Press Y to install LiveSales, or N to handle it yourself (or 0 to exit)"
if ($installChoice -eq '0') { exit }
if ($installChoice -match '^[Yy]$') {
    Write-Host " "
    Write-Host "Installing LiveSales as a service..." -ForegroundColor White
    Start-Process -FilePath "C:\Program Files (x86)\StationMaster\LiveSales.exe" -ArgumentList "-install" -Wait
    Write-Host "LiveSales has been installed as a service." -ForegroundColor Green
    Write-Host "Confirm it is running before continuing." -ForegroundColor Green
    Part-End
} else {
    Write-Host " "
    Write-Host "Install LiveSales yourself and ensure it is running." -ForegroundColor White
    Part-End
}

# Part 26/38 - Transfer Documents
Show-Header
Write-Host "(Part 26/38)" -ForegroundColor Yellow
Write-Host "Task: Transfer Documents" -ForegroundColor Green
Write-Host "[██████████████████████████____________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Copy over any required documents from the old PC to the new one." -ForegroundColor White
Part-End

# Part 27/38 - Transfer Shortcuts and Browser Passwords
Show-Header
Write-Host "(Part 27/38)" -ForegroundColor Yellow
Write-Host "Task: Transfer Shortcuts and Browser Passwords" -ForegroundColor Green
Write-Host "[███████████████████████████___________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Ensure shortcuts and saved browser passwords are transferred." -ForegroundColor White
Part-End

# Part 28/38 - Install VNC or eMIS
# PartVersion=1.00
# status=todo script tightvnc install but need to figure out how to disable the server component from starting up (although not a major concern)
Show-Header
Write-Host "(Part 28/38)" -ForegroundColor Yellow
Write-Host "Task: Install VNC or eMIS" -ForegroundColor Green
Write-Host "[████████████████████████████__________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Install VNC or eMIS as required." -ForegroundColor White
# Section A - Install VNC
# status=todo script tightvnc install but need to figure out how to disable the server component from starting up (although not a major concern)
# Section B - Install emis
# status = provide link to download the exe for it maybe
Part-End

# Part 29/38 - Share Download1 Folder
# PartVersion=1.00
# status=todo
Show-Header
Write-Host "(Part 29/38)" -ForegroundColor Yellow
Write-Host "Task: Share Download1 Folder" -ForegroundColor Green
Write-Host "[█████████████████████████████_________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Share the Download1 folder if required and ensure tills point to it." -ForegroundColor White
Part-End

# Part 30/38 - Set Fixed IP Address on New Host PC
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 30/38)" -ForegroundColor Yellow
Write-Host "Task: Set Fixed IP Address on New Host PC" -ForegroundColor Green
Write-Host "[██████████████████████████████________]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Ensure the new Host PC has the correct fixed IP address." -ForegroundColor White
Part-End
# Part 31/38 - Copy RES Folder for SmartPOS Sites
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 31/38)" -ForegroundColor Yellow
Write-Host "Task: Copy RES Folder for SmartPOS Sites" -ForegroundColor Green
Write-Host "[███████████████████████████████_______]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Copy the RES folder that contains images not stored in the default database for item keys." -ForegroundColor White
Part-End

# Part 32/38 - Install LAN A4 Printer as TCP/IP Device
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 32/38)" -ForegroundColor Yellow
Write-Host "Task: Install LAN A4 Printer as TCP/IP Device" -ForegroundColor Green
Write-Host "[████████████████████████████████______]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Ensure the LAN A4 printer is installed as a TCP/IP device and not a WSD one." -ForegroundColor White
Part-End

# Part 33/38 - Configure Auto Sales Process Services
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 33/38)" -ForegroundColor Yellow
Write-Host "Task: Configure Auto Sales Process Services" -ForegroundColor Green
Write-Host "[█████████████████████████████████_____]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Ensure auto sales process, send sales, import wholesaler updates, and ESLs services are configured correctly." -ForegroundColor White
Part-End

# Part 34/38 - Verify SELs Registry Settings
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 34/38)" -ForegroundColor Yellow
Write-Host "Task: Verify SELs Registry Settings" -ForegroundColor Green
Write-Host "[██████████████████████████████████____]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Check and confirm the SELs registry settings are correctly configured." -ForegroundColor White
Part-End

# Part 35/38 - Inform Retailer About Avery Scales and Bartender Licensing
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 35/38)" -ForegroundColor Yellow
Write-Host "Task: Inform Retailer About Avery Scales and Bartender Licensing" -ForegroundColor Green
Write-Host "[███████████████████████████████████___]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Let the retailer know that we cannot install or license Avery Scales software or Bartender software." -ForegroundColor White
Part-End

# Part 36/38 - Final System Check
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 36/38)" -ForegroundColor Yellow
Write-Host "Task: Final System Check" -ForegroundColor Green
Write-Host "[████████████████████████████████████__]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Perform a final check to ensure all tasks have been completed successfully." -ForegroundColor White
Part-End

# Part 37/38 - Confirm System is Ready for Use
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 37/38)" -ForegroundColor Yellow
Write-Host "Task: Confirm System is Ready for Use" -ForegroundColor Green
Write-Host "[█████████████████████████████████████_]" -ForegroundColor Magenta
Write-Host " "
Write-Host "Ensure the system is fully operational and ready for customer use." -ForegroundColor White
Part-End

# Part 38/38 - Completion and Final Notes
# PartVersion=1.00
# status=
Show-Header
Write-Host "(Part 38/38)" -ForegroundColor Yellow
Write-Host "Task: Completion and Final Notes" -ForegroundColor Green
Write-Host "[██████████████████████████████████████]" -ForegroundColor Magenta
Write-Host " "
Write-Host "The PC transfer process is now complete!" -ForegroundColor Green
Write-Host "Ensure all final checks are done before handing over the system." -ForegroundColor White
Part-End

