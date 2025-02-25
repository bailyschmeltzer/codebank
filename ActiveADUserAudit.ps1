$ExportPath = 'c:\adusers_list.csv'
$OUs = @("OU=Delaware,OU=Acoust-A-FiberUsers,OU=Accounts User,DC=delaware,DC=acoust-a-fiber,DC=com", 
	"OU=San Antonio,OU=Acoust-A-FiberUsers,OU=Accounts User,DC=delaware,DC=acoust-a-fiber,DC=com",
	"OU=Romita,OU=Acoust-A-FiberUsers,OU=Accounts User,DC=delaware,DC=acoust-a-fiber,DC=com",
	"OU=G&G Michigan,OU=Acoust-A-FiberUsers,OU=Accounts User,DC=delaware,DC=acoust-a-fiber,DC=com")  # List of OUs to search in

foreach ($OU in $OUs) {
    Get-ADUser -Filter 'Enabled -eq $true' -SearchBase "LDAP://$OU" | 
    Select-Object Name, @{Name='OU';Expression={(($_.DistinguishedName -split ',')[1] -replace 'OU=','')}} | 
    Export-Csv -NoTypeInformation -Append $ExportPath
}
