# Get Service Status on Multiple Machines
# Set service to autostart, start it, and get status across multiple computers

$scriptBlock = {
    Set-Service -StartupType Automatic -Name WSearch
    Start-Service -Name WSearch
    Get-Service -Name WSearch
}

$hosts = @('SERVER01', 'SERVER02', 'SERVER03', 'SERVER04')

ForEach ($computerName in $hosts) {
    Invoke-Command -ComputerName $computerName -AsJob -ScriptBlock $scriptBlock
}

# Wait and retrieve job results
Start-Sleep -Seconds 5
$results = Get-Job | Receive-Job
$results | Format-Table
