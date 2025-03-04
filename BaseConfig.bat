"c:\BaseConfig\365install.exe" /configure "c:\BaseConfig\365config.xml"

"c:\BaseConfig\adobeinstall.exe"
dism /online /Import-DefaultAppAssociations:"c:\BaseConfig\AppAssociations.xml"


powershell.exe set-executionpolicy remotesigned
powershell.exe -file "C:\BaseConfig\BaseConfig.ps1"

