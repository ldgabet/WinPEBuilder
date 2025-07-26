@ECHO OFF
title WinPEBuilder v1.1 - By CarlosMartinez - GitHub @cmartinezone
:: Developed by: Carlos Martinez @cmartinezone Date: 1/15/2019
:: Updated: 11-11-2019- Composing Packages, and adding background replacement
:: WinPEBuilder 1.0 Auto Generate WinPE ISO with drivers and script incorporate

REM Where to put Windows PE tree and ISO
Set winpe_root=%~dp0WinPE-Root
 
REM ADK installation path. ADK 10 can be found here: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
Set adk_path=%programfiles(x86)%\Windows Kits\10\Assessment and Deployment Kit
 
REM Drivers tree path
Set drivers_path=%~dp0Add-Drivers

REM User scripts location to include in new WinPE image. Scripts tree should include the modified startnet.cmd in which you can add your stuff
Set scripts_path=%~dp0Add-Scripts

REM Directory path for finall iso generated  
set ISO_Path=%~dp0WinPE-ISO
 
REM Calling a script which sets some useful variables 
call "%adk_path%\Deployment Tools\DandISetEnv.bat"
 
REM Cleaning WinPE tree
if exist %winpe_root% rd /q /s %winpe_root%
 
REM Calling standart script that copies WinPE tree
call copype.cmd amd64 %winpe_root%
 
REM Mounting WinPE wim-image
Dism /Mount-Wim /WimFile:%winpe_root%\media\sources\boot.wim /index:1 /MountDir:%winpe_root%\mount
 
REM Adding some useful packages. Packages description and dependencies for WinPE 10 can be found here: http://technet.microsoft.com/en-us/library/hh824926.aspx
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-HTA.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-HTA_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFx.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFx_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-FMAPI.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-SecureBootCmdlets.cab"

REM: Bitlocker startup support packages
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-EnhancedStorage.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-EnhancedStorage_en-us.cab"

Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-SecureStartup.cab"
Dism /image:%winpe_root%\mount /Add-Package /PackagePath:"%adk_path%\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-SecureStartup_en-us.cab"

REM Adding drivers
Dism /image:%winpe_root%\mount /Add-Driver /driver:%drivers_path% /recurse

REM Remove  winpe background permisions to be eligible for replacement.
TAKEOWN /F %winpe_root%\mount\Windows\System32\winpe.jpg
ICACLS %winpe_root%\mount\Windows\System32\winpe.jpg /grant administrators:F

REM Copying script to the WinPE root directory
xcopy %scripts_path%  %winpe_root%\mount\Windows\System32 /r /s /e /i /y

REM Set region Language
Dism /Set-AllIntl:en-US /Image:%winpe_root%\mount

REM Set Keyboard Azerty (FR)
Dism /Set-InputLocale:040c:0000040c /Image:%winpe_root%\mount

REM Setting the timezone. List of available timezones can be found here: http://technet.microsoft.com/en-US/library/cc749073(v=ws.10).aspx
Dism /image:%winpe_root%\mount /Set-TimeZone:"Romance Standard Time"

REM Cleanup image file.
Dism /Image:%winpe_root%\mount /Cleanup-Image /StartComponentCleanup /ResetBase

REM Unmounting and commit changes
Dism /Unmount-Wim /MountDir:%winpe_root%\mount\ /Commit

REM Compression image file maximum.
Dism /Export-Image /SourceImageFile:%winpe_root%\media\sources\boot.wim /SourceIndex:1 /DestinationImageFile:%winpe_root%\media\sources\min_boot.wim /Compress:Max

REM Overwrite boot.wim with min_boot.wim
MOVE /Y %winpe_root%\media\sources\min_boot.wim %winpe_root%\media\sources\boot.wim

REM Creating ISO image from WinPE 
oscdimg -n -b%winpe_root%\bootbins\etfsboot.com %winpe_root%\media %ISO_Path%\WinPE_X64.iso && PAUSE
