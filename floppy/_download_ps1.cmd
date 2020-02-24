set url=%~1
set filename=%~2

echo ==^> Downloading "%url%" to "%filename%"

if defined http_proxy (
    if defined no_proxy (
        set ps1_script="$wc = (New-Object System.Net.WebClient) ; $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.proxy.BypassList = (('%no_proxy%').split(',')) ; $wc.DownloadFile('%url%', '%filename%')"
    ) else (
        set ps1_script="$wc = (New-Object System.Net.WebClient) ; $wc.proxy = (new-object System.Net.WebProxy('%http_proxy%')) ; $wc.DownloadFile('%url%', '%filename%')"
    )
) else (
    set ps1_script="(New-Object System.Net.WebClient).DownloadFile('%url%', '%filename%')"
)

powershell -command %ps1_script% >nul
exit /b
