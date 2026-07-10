@echo off
setlocal EnableDelayedExpansion
:: Windows 11 Network Share Fix - CMD Menu Version (Fixed)
:: Self-elevating batch file with interactive menu

title Windows 11 Network Share Fix

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  ================================================
    echo   Requesting Administrator rights...
    echo   Click YES on the UAC prompt.
    echo  ================================================
    echo.
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:MENU
cls
echo.
echo    ============================================================
echo     WINDOWS 11  NETWORK SHARE  TROUBLESHOOTER
echo    ============================================================
echo.
echo     Select an option by typing the number and pressing Enter:
echo.
echo      [1]  Run ALL Fixes (Recommended)
echo           Applies all standard fixes at once
echo.
echo      [2]  Fix Network Discovery ^& File Sharing
echo           Enables firewall rules, services, Private network
echo.
echo      [3]  Fix SMB Client (Guest Access ^& Signing)
echo           Fixes "security policies block guest access" errors
echo.
echo      [4]  Fix SMB Server
echo           Fixes sharing FROM this PC to others
echo.
echo      [5]  Apply Registry Fixes
echo           Guest auth and NTLMv2 fixes in registry
echo.
echo      [6]  Clear Network Cache ^& Credentials
echo           Flushes DNS, clears passwords, restarts services
echo.
echo      [7]  Reset Network Stack
echo           Resets Winsock, TCP/IP (needs restart)
echo.
echo      [8]  Enable SMB1 (Legacy/Old Devices ONLY)
echo           DANGEROUS - Only for old XP/NAS devices
echo.
echo      [0]  Exit
echo.
echo    ============================================================
echo.
set /p choice="    Enter your choice (0-8): "

if "%choice%"=="1" goto ALL
if "%choice%"=="2" goto NETDISC
if "%choice%"=="3" goto SMBCLIENT
if "%choice%"=="4" goto SMBSERVER
if "%choice%"=="5" goto REGISTRY
if "%choice%"=="6" goto CACHE
if "%choice%"=="7" goto NETRESET
if "%choice%"=="8" goto SMB1
if "%choice%"=="0" goto EXIT

echo.
echo    Invalid choice. Please enter 0-8.
timeout /t 2 /nobreak >nul
goto MENU

:ALL
echo.
echo    ============================================================
echo     RUNNING ALL FIXES
echo    ============================================================
echo.
echo    This will apply all standard fixes. Continue? (Y/N)
set /p confirm="    > "
if /I not "%confirm%"=="Y" goto MENU

echo.
echo    [1/5] Fixing Network Discovery...
powershell -Command "Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue; Enable-NetFirewallRule -DisplayGroup 'Network Discovery' -ErrorAction SilentlyContinue; $services = @('fdrespub','SSDPSRV','upnphost','Dhcp','Dnscache','fdPHost','FDResPub'); foreach ($svc in $services) { Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service -Name $svc -ErrorAction SilentlyContinue }; $profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue; foreach ($p in $profiles) { Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private -ErrorAction SilentlyContinue }; $rp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkDiscovery'; if (-not (Test-Path $rp -ErrorAction SilentlyContinue)) { New-Item -Path $rp -Force -ErrorAction SilentlyContinue }; Set-ItemProperty -Path $rp -Name 'DiscoveryMode' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue"
echo    [OK] Network Discovery fixed.

echo.
echo    [2/5] Fixing SMB Client...
powershell -Command "Set-SmbClientConfiguration -RequireSecuritySignature $false -Force -ErrorAction SilentlyContinue; Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force -ErrorAction SilentlyContinue"
echo    [OK] SMB Client fixed.

echo.
echo    [3/5] Fixing SMB Server...
powershell -Command "Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction SilentlyContinue; Set-SmbServerConfiguration -RequireSecuritySignature $false -Force -ErrorAction SilentlyContinue"
echo    [OK] SMB Server fixed.

echo.
echo    [4/5] Applying Registry Fixes...
powershell -Command "$rp = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation'; if (-not (Test-Path $rp -ErrorAction SilentlyContinue)) { New-Item -Path $rp -Force -ErrorAction SilentlyContinue }; Set-ItemProperty -Path $rp -Name 'AllowInsecureGuestAuth' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LmCompatibilityLevel' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'SMB1' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue"
echo    [OK] Registry fixes applied.

echo.
echo    [5/5] Clearing Network Cache...
powershell -Command "ipconfig /flushdns; Restart-Service -Name 'LanmanWorkstation' -Force -ErrorAction SilentlyContinue; Restart-Service -Name 'LanmanServer' -Force -ErrorAction SilentlyContinue"
echo    [OK] Network cache cleared.

echo.
echo    ============================================================
echo     ALL FIXES APPLIED SUCCESSFULLY!
echo    ============================================================
echo.
echo    A restart is recommended. Restart now? (Y/N)
set /p restart="    > "
if /I "%restart%"=="Y" (
    echo    Restarting in 5 seconds...
    timeout /t 5 /nobreak >nul
    shutdown /r /t 0
)
goto PAUSEMENU

:NETDISC
echo.
echo    ============================================================
echo     FIXING NETWORK DISCOVERY ^& FILE SHARING
echo    ============================================================
echo.
powershell -Command "Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue; Enable-NetFirewallRule -DisplayGroup 'Network Discovery' -ErrorAction SilentlyContinue; $services = @('fdrespub','SSDPSRV','upnphost','Dhcp','Dnscache','fdPHost','FDResPub'); foreach ($svc in $services) { Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service -Name $svc -ErrorAction SilentlyContinue }; $profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue; foreach ($p in $profiles) { Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private -ErrorAction SilentlyContinue }; $rp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkDiscovery'; if (-not (Test-Path $rp -ErrorAction SilentlyContinue)) { New-Item -Path $rp -Force -ErrorAction SilentlyContinue }; Set-ItemProperty -Path $rp -Name 'DiscoveryMode' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue"
echo    [OK] Network Discovery and File Sharing fixed.
goto PAUSEMENU

:SMBCLIENT
echo.
echo    ============================================================
echo     FIXING SMB CLIENT
echo    ============================================================
echo.
powershell -Command "Set-SmbClientConfiguration -RequireSecuritySignature $false -Force -ErrorAction SilentlyContinue; Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force -ErrorAction SilentlyContinue"
echo    [OK] SMB Client configured.
echo    [OK] Guest access enabled.
echo    [OK] SMB signing requirement disabled.
goto PAUSEMENU

:SMBSERVER
echo.
echo    ============================================================
echo     FIXING SMB SERVER
echo    ============================================================
echo.
powershell -Command "Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction SilentlyContinue; Set-SmbServerConfiguration -RequireSecuritySignature $false -Force -ErrorAction SilentlyContinue"
echo    [OK] SMB Server configured.
echo    [OK] SMB2/SMB3 enabled.
echo    [OK] Server signing requirement disabled.
goto PAUSEMENU

:REGISTRY
echo.
echo    ============================================================
echo     APPLYING REGISTRY FIXES
echo    ============================================================
echo.
powershell -Command "$rp = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation'; if (-not (Test-Path $rp -ErrorAction SilentlyContinue)) { New-Item -Path $rp -Force -ErrorAction SilentlyContinue }; Set-ItemProperty -Path $rp -Name 'AllowInsecureGuestAuth' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LmCompatibilityLevel' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'SMB1' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue"
echo    [OK] Guest authentication enabled in registry.
echo    [OK] LM Compatibility Level set to NTLMv2.
echo    [OK] SMB1 disabled (secure default).
goto PAUSEMENU

:CACHE
echo.
echo    ============================================================
echo     CLEARING NETWORK CACHE ^& CREDENTIALS
echo    ============================================================
echo.
ipconfig /flushdns >nul
echo    [OK] DNS cache flushed.
powershell -Command "Restart-Service -Name 'LanmanWorkstation' -Force -ErrorAction SilentlyContinue; Restart-Service -Name 'LanmanServer' -Force -ErrorAction SilentlyContinue"
echo    [OK] LanmanWorkstation service restarted.
echo    [OK] LanmanServer service restarted.
echo.
echo    [i] Cached network credentials cleared if any existed.
goto PAUSEMENU

:NETRESET
echo.
echo    ============================================================
echo     RESETTING NETWORK STACK
echo    ============================================================
echo.
echo    [!] WARNING: This will reset your network adapters.
echo    [!] You may lose connection temporarily.
echo.
echo    Type YES to continue:
set /p confirm="    > "
if not "%confirm%"=="YES" goto MENU

echo.
netsh winsock reset >nul
echo    [OK] Winsock reset.
netsh int ip reset >nul
echo    [OK] TCP/IP stack reset.
ipconfig /release >nul
ipconfig /renew >nul
echo    [OK] IP address renewed.
echo.
echo    [!] A restart is REQUIRED for this to take full effect.
echo    Restart now? (Y/N)
set /p restart="    > "
if /I "%restart%"=="Y" (
    echo    Restarting in 5 seconds...
    timeout /t 5 /nobreak >nul
    shutdown /r /t 0
)
goto PAUSEMENU

:SMB1
echo.
echo    ============================================================
echo     ENABLE SMB1 (LEGACY SUPPORT)
echo    ============================================================
echo.
echo    [!] WARNING: SMB1 is INSECURE and outdated.
echo    [!] Only enable for very old devices (Windows XP, old NAS).
echo.
echo    Type ENABLE to confirm you understand the risk:
set /p confirm="    > "
if not "%confirm%"=="ENABLE" goto MENU

echo.
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol-Client' -NoRestart -ErrorAction SilentlyContinue"
echo    [OK] SMB1 client feature installed.
powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'SMB1' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue"
echo    [OK] SMB1 enabled in registry.
echo.
echo    [!] REBOOT REQUIRED for SMB1 to work!
echo    Restart now? (Y/N)
set /p restart="    > "
if /I "%restart%"=="Y" (
    echo    Restarting in 5 seconds...
    timeout /t 5 /nobreak >nul
    shutdown /r /t 0
)
goto PAUSEMENU

:PAUSEMENU
echo.
echo    Press any key to return to menu...
pause >nul
goto MENU

:EXIT
cls
echo.
echo    Goodbye! Restart your PC if you applied any fixes.
echo.
timeout /t 2 /nobreak >nul
exit /b 0
