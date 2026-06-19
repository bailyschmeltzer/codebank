# NOC Maintenance Tasks
# Find and manage users/computers not logged in past 90 days

# Get computers not logged in past 90 days (enabled only)
Get-ADComputer -Filter * -Properties LastLogonDate | 
    Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-90) -and $_.Enabled -eq $true} | 
    Sort-Object -Property LastLogonDate | 
    Format-Table SamAccountName, LastLogonDate

# Disable computers not logged in past 90 days
Get-ADComputer -Filter * -Properties LastLogonDate | 
    Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-90)} | 
    Sort-Object -Property LastLogonDate | 
    Set-ADComputer -Enabled $false

# Get users not logged in past 90 days
Get-ADUser -Filter * -Properties LastLogonDate | 
    Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-90) -and $_.Enabled -eq $true} | 
    Sort-Object -Property LastLogonDate | 
    Format-Table SamAccountName, LastLogonDate

# Disable users not logged in past 90 days (with Out-GridView for confirmation)
Get-ADUser -Filter * -Properties LastLogonDate | 
    Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-90) -and $_.Enabled -eq $true} | 
    Sort-Object -Property LastLogonDate | 
    Out-GridView -PassThru | 
    Set-ADUser -Enabled $false
