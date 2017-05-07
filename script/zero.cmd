@@setlocal EnableDelayedExpansion EnableExtensions
@@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@@set args=%*
@@if defined args set args=%args:"=\"%
@@echo Started: zero.cmd >>"%PACKER_LOG%"
@@echo %TIME% Executing: PowerShell -NoProfile -Command Invoke-Expression $('$args=@(^&{$args} %args%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:')))>>"%PACKER_LOG%"
@@PowerShell -NoProfile -Command Invoke-Expression $('$args=@(^&{$args} %args%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:')))
@@if %ERRORLEVEL% neq 0 echo %TIME% [ERROR] %ERRORLEVEL% returned by: PowerShell -NoProfile -Command Invoke-Expression $('$args=@(^&{$args} %args%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) >>"%PACKER_LOG%"
@@echo zero.cmd exiting with code %ERRORLEVEL%
@@exit /b %ERRORLEVEL%

$FilePath="c:\zero.tmp"
$Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
$ArraySize= 64kb
$SpaceToLeave= $Volume.Size * 0.05
$FileSize= $Volume.FreeSpace - $SpacetoLeave
$ZeroArray= new-object byte[]($ArraySize)
Write-Output "Zeroing C:";
$Stream= [io.File]::OpenWrite($FilePath)
try {
    $CurFileSize = 0
    $last = ""
    while($CurFileSize -lt $FileSize) {
        $a = [math]::round($CurFileSize / $FileSize * 100, 0)
        $b = [string]("{0:N0}" -f $a)
        $c = $b.PadLeft(3," ") + "% complete`r"
        if ($c -ne $last) {
            Write-Output $c;
            $last = $c
        }
        $Stream.Write($ZeroArray,0,$ZeroArray.Length)
        $CurFileSize += $ZeroArray.Length
    }
    Write-Output "100.00% compelete.";
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}

Del $FilePath
Exit $LASTEXITCODE
