<!-- :
echo ==^> Running Windows Update
cscript //nologo "%~f0?.wsf"
exit /b

----- Begin wsf script --->
<job><script language="VBScript">
Option Explicit

deleteStartupEntry

Dim updateSession, updateSearcher, searchResult
Set updateSession = CreateObject("Microsoft.Update.Session")
updateSession.ClientApplicationID = "packer"
Set updateSearcher = updateSession.CreateUpdateSearcher()
WScript.Echo "Searching for updates..."
Set searchResult = updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
If searchResult.Updates.Count Then
    WScript.Echo "There are " & searchResult.Updates.Count & " applicable updates"
End if 
If searchResult.Updates.Count = 0 Then
    WScript.Echo "There are no applicable updates."
    WScript.Quit
End If

Dim updatesToDownload, updatesToInstall, installResult
Set updatesToDownload = getUpdatesToDownload(searchResult)
Set updatesToInstall = downloadUpdates(updateSession, updatesToDownload)
Set installResult = installUpdates(updateSession, updatesToInstall)
If installResult.RebootRequired Then
    addStartupEntry
    reboot(".")
End If

Sub LogWrite(message)
    Dim strFile, objFSO, objFile
    Const ForAppending = 8
    strFile = "C:\Windows\Temp\windows-update.log"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.OpenTextFile(strFile, ForAppending, True)
    objFile.WriteLine(Now & ": " & message)
    WScript.Echo message
    objFile.Close
End Sub

Function getUpdatesToDownload(searchResult)
    LogWrite "Creating collection of updates to download."
    Dim updatesToDownload, i
    Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
    For i = 0 to searchResult.Updates.Count-1
        Dim update, addThisUpdate
        Set update = searchResult.Updates.Item(i)
        addThisUpdate = false
        If update.InstallationBehavior.CanRequestUserInput = true Then
            LogWrite i + 1 & "> skipping: " & update.Title & " because it requires user input"
        Else
            If update.EulaAccepted = false Then
                LogWrite i + 1 & "> note: " & update.Title & " has a license agreement that must be accepted:"
                update.AcceptEula()
            End If
            addThisUpdate = true
        End If
        If addThisUpdate = true Then
            LogWrite i + 1 & "> adding: " & update.Title
            updatesToDownload.Add(update)
        End If
    Next

    If updatesToDownload.Count = 0 Then
        LogWrite "All applicable updates were skipped."
        WScript.Quit
    End If
    Set getUpdatesToDownload = updatesToDownload 
End Function

Function downloadUpdates(updateSession, updatesToDownload)
    LogWrite "Downloading updates..."
    Dim updateDownloader
    Set updateDownloader = updateSession.CreateUpdateDownloader()
    updateDownloader.Updates = updatesToDownload
    updateDownloader.Download()
    LogWrite "Successfully downloaded updates..."

    Dim updatesToInstall, rebootMayBeRequired, i
    rebootMayBeRequired = false
    Set updatesToInstall = CreateObject("Microsoft.Update.UpdateColl")
    For i = 0 To searchResult.Updates.Count-1
        Dim update
        Set update = searchResult.Updates.Item(i)
        If update.IsDownloaded = true Then
            LogWrite i + 1 & "> " & update.Title
            updatesToInstall.Add(update)
            If update.InstallationBehavior.RebootBehavior > 0 Then
                rebootMayBeRequired = true
            End If
        End If
    Next

    If updatesToInstall.Count = 0 Then
        LogWrite "No updates were successfully downloaded."
        WScript.Quit
    End If

    Set downloadUpdates = updatesToInstall
End Function

Function installUpdates(updateSession, updatesToInstall)
    LogWrite "Installing updates..."
    Dim installer, installationResult, i
    Set installer = updateSession.CreateUpdateInstaller()
    installer.Updates = updatesToInstall
    Set installationResult = installer.Install()
    LogWrite "Installation Result: " & installationResult.ResultCode
    LogWrite "Reboot Required: " & installationResult.RebootRequired
    LogWrite "Listing of updates installed and individual installation results:"
    For i = 0 to updatesToInstall.Count - 1
        LogWrite i + 1 & "> " & updatesToInstall.Item(i).Title & ": " & installationResult.GetUpdateResult(i).ResultCode
    Next
    Set installUpdates = installationResult
End Function

Sub deleteStartupEntry
   Const HKEY_LOCAL_MACHINE = &H80000002
   Dim strComputer
   strComputer = "."
   Dim reg, strKeyPath, strValueName
   Set reg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
   strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Run"
   strValueName = "WindowsUpdate"
   reg.DeleteValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName
End Sub

Sub addStartupEntry
    Dim objShell, fullName, strPath
    Set objShell = CreateObject("WScript.Shell")
    fullName = WScript.ScriptFullName
    strPath = Left(fullName, InStrRev(fullName, "?.wsf") - 1)

    Const HKEY_LOCAL_MACHINE = &H80000002
    Dim strComputer, reg, strKeyPath, strValueName
    strComputer = "."
    Set reg=GetObject("winmgmts:{impersonationLevel=impersonate}!//" & strComputer & "/root/default:StdRegProv")
    strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Run"
    strValueName = "WindowsUpdate"
    LogWrite "Writing " & strValueName & " = " & strPath
    LogWrite "to registry key"
    LogWrite "HKLM\" & strKeyPath
    reg.SetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strPath
End Sub

Sub reboot(computerName)
    Dim objWMIService, colOS, objOS
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Shutdown)}!\\" & computerName & "\root\cimv2")
    Set colOS = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
    For Each objOS in colOS
        objOS.Reboot()
    Next
End Sub
</script></job>