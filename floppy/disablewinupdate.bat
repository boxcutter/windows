<!-- :
@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if "%PACKER_DEBUG%" geq "5" (@echo on) else (@echo off)

echo ==^> Enabling updates for other products from Microsoft Update
net stop wuauserv

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v EnableFeaturedSoftware /t REG_DWORD /d 1 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v IncludeRecommendedUpdates /t REG_DWORD /d 1 /f

cscript //nologo "%~f0?.wsf"

net start wuauserv
exit /b

----- Begin wsf script --->
<job><script language="VBScript">
  Set ServiceManager = CreateObject("Microsoft.Update.ServiceManager")
  Set NewUpdateService = ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")

  Const NOT_CONFIGURED = 0
  Const DISABLED = 1
  Const PROMPT_TO_APPROVE_BEFORE_DOWNLOAD = 2
  Const DOWNLOAD_AUTOMATICALLY = 3
  Const SCHEDULED_INSTALLATION = 4
  Set AutoUpdate = CreateObject("Microsoft.Update.AutoUpdate")
  Set AutoUpdateSettings = AutoUpdate.Settings
  AutoUpdateSettings.NotificationLevel = DISABLED
  AutoUpdateSettings.Save
  AutoUpdateSettings.Refresh
</script></job>
