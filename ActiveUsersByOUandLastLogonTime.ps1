# Specify the path to your target OU
$OUpath = 'OU=Delaware,OU=Acoust-A-FiberUsers,OU=Accounts User,DC=delaware,DC=acoust-a-fiber,DC=com'

# Get active users from the specified OU along with their last logon time
$users = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $OUpath -Properties LastLogon |
         Select-Object Name, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}

# Export the user data to a CSV file
$exportPath = 'C:\users\administrator.delaware\desktop\Active Users Delaware.csv'
$users | Export-Csv -Path $exportPath -NoTypeInformation

# Display a confirmation message
Write-Host "User data exported to $exportPath"

