<!-- :
echo ==^> Running Windows Update
cscript //nologo "%~f0?.wsf"
exit /b

----- Begin wsf script --->
<job><script language="VBScript">
Option Explicit

deleteStartupEntry

Dim updateSession, updateSearcher, searchResult
On Error Resume Next
Set updateSession = CreateObject("Microsoft.Update.Session")
If Err.Number <> 0 Then
    LogWrite "Error " & Hex(Err) & " calling " & Err.Source
    LogWrite Err.Description
End If
On Error Goto 0
updateSession.ClientApplicationID = "packer"
On Error Resume Next
Set updateSearcher = updateSession.CreateUpdateSearcher()
If Err.Number <> 0 Then
    LogWrite "Error " & Hex(Err) & " calling " & Err.Source
    LogWrite Err.Description
End If
On Error Goto 0
LogWrite "Searching for updates..."
On Error Resume Next
Set searchResult = updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
If Err.Number <> 0 Then
    LogWrite "Error " & Hex(Err) & " calling " & Err.Source
    LogWrite Err.Description
End If
On Error Goto 0
If searchResult.Updates.Count Then
    LogWrite "There are " & searchResult.Updates.Count & " applicable updates"
End if
If searchResult.Updates.Count = 0 Then
    LogWrite "There are no applicable updates."
    ExecutePostInstallBatch
    WScript.Quit
End If

Dim updatesToDownload, updatesToInstall, installResult
Set updatesToDownload = getUpdatesToDownload(searchResult)
Set updatesToInstall = downloadUpdates(updateSession, updatesToDownload)
Set installResult = installUpdates(updateSession, updatesToInstall)
If installResult.RebootRequired Then
    addStartupEntry
    reboot(".")
    WScript.Quit
Else
    ExecutePostInstallBatch
End If

Sub ExecutePostInstallBatch
    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")

    If (fso.FileExists("a:\_post_update_install.bat")) Then
        Dim objShell
        Set objShell = WScript.CreateObject("WScript.Shell")
        objShell.Run "a:\_post_update_install.bat"
    End If
End Sub

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
    On Error Resume Next
    Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
    If Err.Number <> 0 Then
        LogWrite "Error " & Hex(Err) & " calling " & Err.Source
        LogWrite Err.Description
    End If
    On Error Goto 0
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
    On Error Resume Next
    Set installer = updateSession.CreateUpdateInstaller()
    If Err.Number <> 0 Then
        LogWrite "Error " & Hex(Err) & " calling " & Err.Source
        LogWrite Err.Description
    End If
    On Error Goto 0
    installer.Updates = updatesToInstall
    On Error Resume Next
    Set installationResult = installer.Install()
    If Err.Number <> 0 Then
        LogWrite "Error " & Hex(Err) & " calling " & Err.Source
        LogWrite Err.Description
    End If
    On Error Goto 0
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
    Dim reg, strKeyPath, strValueName, strValue
    Set reg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
    strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Run"
    strValueName = "WindowsUpdate"
    LogWrite "Checking to see if the following registry key exits:"
    LogWrite "HKLM\" & strKeyPath
    reg.GetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue
    If IsNull(strValue) Then
        LogWrite "The registry key does not exist from a prior run."
    Else
        LogWrite "The registry key exists from a prior run, deleting..."
        reg.DeleteValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName
        LogWrite "Registry key deleted."
    End If
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
    LogWrite "Rebooting " & computerName
    Dim objWMIService, colOS, objOS
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Shutdown)}!\\" & computerName & "\root\cimv2")
    Set colOS = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
    For Each objOS in colOS
        objOS.Reboot()
    Next
End Sub
</script></job>
