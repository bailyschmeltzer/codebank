:: Purpose: Set PowerShell execution policy to allow local script execution.
:: Uses RemoteSigned so local scripts run while downloaded scripts require signing.
powershell.exe set-executionpolicy remotesigned
