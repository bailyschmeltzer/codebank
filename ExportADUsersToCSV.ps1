# Export AD Users to CSV with Key Attributes
# Exports user information including email, phone, department, manager

$users = Get-ADUser -Filter * -Properties EmailAddress, MobilePhone, Department, Manager, Title |
    Select-Object @(
        'Name'
        'SamAccountName'
        'EmailAddress'
        'MobilePhone'
        'Department'
        'Title'
        @{Name='Manager'; Expression={if($_.Manager) {(Get-ADUser $_.Manager).Name} else {$null}}}
        'Enabled'
        'DistinguishedName'
    )

$exportPath = "C:\Reports\ADUsers_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$users | Export-Csv -Path $exportPath -NoTypeInformation

Write-Host "Exported $($users.Count) users to: $exportPath"
