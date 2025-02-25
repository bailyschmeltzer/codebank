# Specify the path to your target OU
$OUpath = 'OU=Accounts Computer,DC=delaware,DC=acoust-a-fiber,DC=com'

# Get active users from the specified OU along with their last logon time
$users = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase $OUpath -Properties LastLogon |
         Select-Object Name, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}

# Export the user data to a CSV file
$exportPath = 'C:\users\administrator.delaware\desktop\Active Computers Delaware.csv'
$users | Export-Csv -Path $exportPath -NoTypeInformation

# Display a confirmation message
Write-Host "User data exported to $exportPath"