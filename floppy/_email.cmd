@@setlocal EnableDelayedExpansion EnableExtensions
@@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@@set args=%*
@@if defined args set args=%args:"=\"%
@@echo Started: _email.cmd >>"%PACKER_LOG%"
@@echo %TIME% Executing: PowerShell -NoProfile -Command Invoke-Expression $('$args=@(^&{$args} %args%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:')))>>"%PACKER_LOG%"
@@PowerShell -NoProfile -Command Invoke-Expression $('$args=@(^&{$args} %args%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:')))
@@if %ERRORLEVEL% neq 0 echo %TIME% [ERROR] %ERRORLEVEL% returned by: PowerShell -NoProfile -Command Invoke-Expression $('$args=@(^&{$args} %args%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) >>"%PACKER_LOG%"
@@echo _email.cmd exiting with code %ERRORLEVEL%
@@exit /b %ERRORLEVEL%

$_Host = $Env:EMAIL_HOST
$Port  = $Env:EMAIL_PORT
$User  = $Env:EMAIL_USER
$Pass  = $Env:EMAIL_PASS

$Subject = $Env:EMAIL_SUBJECT

$From = $Env:EMAIL_FROM
$To   = $Env:EMAIL_TO
$Cc   = $Env:EMAIL_CC
$Bcc  = $Env:EMAIL_BCC

$Files = $Env:EMAIL_FILES

If ([string]::IsNullOrEmpty($Subject)) {
    If (![string]::IsNullOrEmpty($args[0])) {
        $Subject = $args[0]
    } else {
        If (![string]::IsNullOrEmpty($Env:PACKER_VM_NAME)) {
            $Subject = $Env:PACKER_VM_NAME
        } else {
            $Subject = 'Packer build'
        }
        If (![string]::IsNullOrEmpty($Env:PACKER_BUILDER_TYPE)) {
            $Subject += " (" + $Env:PACKER_BUILDER_TYPE + ")"
        }
    }
}

for ($i = 0; $i -lt $args.count; $i++ ) {
    If (![string]::IsNullOrEmpty($args[$i])) {
        If (Test-Path $args[$i]) {
            If (![string]::IsNullOrEmpty($Files)) {
                $Files += "*"
            }
            $Files += $args[$i]
        }
    }
}

$msg = New-Object System.Net.Mail.MailMessage
$msg.From = $From
$msg.Subject = $Subject
$msg.IsBodyHtml = $false

Write-Output "Sending email:"
Write-Output("Host: " + $_Host)
Write-Output("Port: " + $Port)
Write-Output("User: " + $User)
Write-Output("Pass: " + $Pass)
Write-Output("---")
Write-Output("From: " + $From)
Write-Output("Subj: " + $Subject)

$Body = ""
If (![string]::IsNullOrEmpty($Env:EMAIL_BODY)) {
    If (Test-Path $Env:EMAIL_BODY) {
        $Body = Get-Content $Env:EMAIL_BODY
    } else {
        $Body = $Env:EMAIL_BODY
    }
}

$msg.Body = $Body

If (![string]::IsNullOrEmpty($To)) {
    $tos = $To.Split(',')
    foreach ($s in $Tos) {
        Write-Output("To:   " + $s)
        $msg.To.Add($s)
    }
}

If (![string]::IsNullOrEmpty($Cc)) {
    $ccs = $Cc.Split(',')
    foreach ($s in $ccs) {
        Write-Output("Cc:   " + $s)
        $msg.Cc.Add($s)
    }
}

If (![string]::IsNullOrEmpty($Bcc)) {
    $bccs = $Bcc.Split(',')
    foreach ($s in $Bccs) {
        $msg.Bcc.Add($s)
        Write-Output("Bcc:  " + $s)
    }
}

If (![string]::IsNullOrEmpty($Files)) {
    $attachments = $Files.Split(',')
    foreach ($attachment in $attachments) {
        $attachment = $attachment.trim('"')
        If (Test-Path $attachment) {
            Write-Output("Encl: " + $attachment)
            $msg.Attachments.Add($attachment)
        } else {
            Write-Output("ERROR: File not found: '" + $attachment + "'")
        }
    }
}

$SMTPClient = New-Object Net.Mail.SmtpClient($_Host, $Port)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($User, $Pass);
$SMTPClient.Send($msg)

Exit $LASTEXITCODE
