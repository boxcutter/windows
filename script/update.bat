<!-- :
if NOT "%UPDATE%" == "true" exit /b
echo ==^> Running Windows Update
cscript /nologo "%~f0?.wsf"
exit /b

----- Begin wsf script --->
<job><script language="VBScript">
    Option Explicit

    Dim updateSession, updateSearch, updatesToDownload
    Dim updatesToInstall, installResult
    Set updateSession = CreateObject("Microsoft.Update.Session")
    updateSession.ClientApplicationID = "packer"
    Set updateSearch = searchForUpdates(updateSession)
    Set updatesToDownload = createUpdateCollection(updateSearch)
    Set updatesToInstall = downloadUpdates(updateSession, updateSearch, updatesToDownload)
    Set installResult = installUpdates(updateSession, updatesToInstall) 
    If installResult.RebootRequired Then
        Dim objShell
        Set objShell = WScript.CreateObject("wscript.shell")
        objShell.Run "shutdown.exe /r /t 00"
        WScript.Sleep 60
    End If

    Function searchForUpdates(updateSession)
        Dim updateSearcher
        Set updateSearcher = updateSession.CreateUpdateSearcher()
        WScript.Echo "Searching for updates..." & vbCRLF

        Dim searchString, searchResult, i
        searchString = "IsInstalled=0 and Type='Software' and IsHidden=0"
        Set searchResult = updateSearcher.Search(searchString)
        WScript.Echo "List of applicable items on the machine:"
        For i = 0 To searchResult.Updates.Count-1
            Dim update
            Set update = searchResult.Updates.Item(i)
            WScript.Echo i + 1 & "> " & update.Title
        Next
        If searchResult.Updates.Count = 0 Then
            WScript.Echo "There are no applicable updates."
            WScript.Quit
        End If
        Set searchForUpdates = searchResult
    End Function

    Function createUpdateCollection(updateSearch)
        WScript.Echo vbCRLF & "Creating collection of updates to download"
        Dim updatesToDownload, i
        Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
        For i = 0 to updateSearch.Updates.Count-1
            Dim update, addThisUpdate
            Set update = updateSearch.Updates.Item(i)
            addThisUpdate = false
            If update.InstallationBehavior.CanRequestUserInput = true Then
                WScript.Echo i + 1 & "> skipping: " & update.Title & _
                " because it requires user input"
            Else
                If update.EulaAccepted = false Then
                    update.AcceptEula()
                    addThisUpdate = true
                Else
                    addThisUpdate = true
                End If
            End If
            If addThisUpdate = true Then
                WScript.Echo i + 1 & "> adding: " & update.Title
                updatesToDownload.Add(update)
            End If
        Next
        If updatesToDownload.Count = 0 Then
            WScript.Echo "All applicable updates were skipped."
            WScript.Quit
        End If
        Set createUpdateCollection = updatesToDownload
    End Function

    Function downloadUpdates(updateSession, updateSearch, updatesToDownload)
        WScript.Echo vbCRLF & "Downloading updates..."
        Dim downloader, updatesToInstall, rebootMayBeRequired, i
        Set downloader = updateSession.CreateUpdateDownloader()
        downloader.Updates = updatesToDownload
        downloader.Download()
        
        Set updatesToInstall = CreateObject("Microsoft.Update.UpdateColl")
        rebootMayBeRequired = false
        WScript.Echo vbCRLF & "Successfully downloaded updates:"

        For i = 0 to updateSearch.Updates.Count-1
            Dim update
            Set update = updateSearch.Updates.Item(i)
            If update.IsDownloaded = true Then
                WScript.Echo i + 1 & "> " & update.Title
                updatesToInstall.Add(update)
                If update.InstallationBehavior.RebootBehavior > 0 Then
                    rebootMayBeRequired = true
                End If
            End If
        Next
        If updatesToInstall.Count = 0 Then
            WScript.Echo "No updates were successfully downloaded."
            WScript.Quit
        End If
        Set downloadUpdates = updatesToInstall
    End Function

    Function installUpdates(updateSession, updatesToInstall)
        WScript.Echo "Installing updates..."
        Dim installer, installationResult, i
        Set installer = updateSession.CreateUpdateInstaller()
        installer.Updates = updatesToInstall
        Set installationResult = installer.Install()

        WScript.Echo "Installation Result: " & _
        installationResult.ResultCode
        WScript.Echo "Reboot Required: " & _
        installationResult.RebootRequired & vbCRLF
        WScript.Echo "Listing of updates installed " & _
        "and individual installation results:"

        For i = 0 to updatesToInstall.Count - 1
            WScript.Echo i + 1 & "> " & _
            updatesToInstall.Item(i).Title & _
            ": " & installationResult.GetUpdateResult(i).ResultCode
        Next
        Set installUpdates = installationResult
    End Function
</script></job>
