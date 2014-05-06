echo ==^> Disabling automatic machine account password changes
:: http://support.microsoft.com/kb/154501
REG ADD "HKLM\System\CurrentControlSet\Services\Netlogon\Parameters" /v DisablePasswordChange /t REG_DWORD /d 2 /f
