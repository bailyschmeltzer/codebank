net user Administrator PASSWORD
net user Administrator active:no
WMIC USERACCOUNT WHERE Name='Administrator' SET PasswordExpires=FALSE
net user USERNAME PASSWORD /add
WMIC USERACCOUNT WHERE Name='USERNAME' SET PasswordExpires=FALSE
net localgroup administrators USERNAME /add
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /T REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f 
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-TCP" /v UserAuthentication /t REG_DWORD /d 0 /f
netsh AdvFirewall set allprofiles state off
net localgroup Administrators "Domain Users" /add
"c:\BaseConfig\365install.exe" /configure "c:\BaseConfig\365config.xml"

"c:\BaseConfig\adobeinstall.exe"
dism /online /Import-DefaultAppAssociations:"c:\BaseConfig\AppAssociations.xml"


powershell.exe set-executionpolicy remotesigned
powershell.exe -file "C:\BaseConfig\BaseConfig.ps1"

