# Generate Active Directory Audit Report
# Comprehensive report of AD configuration, users, groups, and permissions

param(
    [string]$ReportPath = "C:\Reports\ADaudit_$(Get-Date -Format 'yyyyMMdd').html"
)

# Gather AD Information
$domain = Get-ADDomain
$forest = Get-ADForest
$users = Get-ADUser -Filter * | Measure-Object
$computers = Get-ADComputer -Filter * | Measure-Object
$groups = Get-ADGroup -Filter * | Measure-Object
$disabledUsers = Get-ADUser -Filter {Enabled -eq $false} | Measure-Object
$passwordExpiringUsers = Get-ADUser -Filter {passwordNotRequired -eq $false} -Properties msDS-UserPasswordExpiryTimeComputed |
    Where-Object {$_.'msDS-UserPasswordExpiryTimeComputed' -lt (Get-Date).AddDays(30)} | Measure-Object

# Create HTML Report
$html = @"
<html>
<head>
    <title>Active Directory Audit Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0066cc; }
        h2 { color: #333333; border-bottom: 2px solid #0066cc; padding-bottom: 5px; }
        table { border-collapse: collapse; width: 100%; margin: 15px 0; }
        th { background-color: #0066cc; color: white; padding: 10px; text-align: left; }
        td { border: 1px solid #ddd; padding: 10px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .warning { color: #ff6600; font-weight: bold; }
        .success { color: #00aa00; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Active Directory Audit Report</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    
    <h2>Domain Information</h2>
    <table>
        <tr><td><b>Domain Name</b></td><td>$($domain.DNSRoot)</td></tr>
        <tr><td><b>NetBIOS Name</b></td><td>$($domain.NetBIOSName)</td></tr>
        <tr><td><b>Forest</b></td><td>$($forest.RootDomain)</td></tr>
        <tr><td><b>Functional Level</b></td><td>$($domain.DomainMode)</td></tr>
    </table>
    
    <h2>Statistics</h2>
    <table>
        <tr>
            <th>Category</th>
            <th>Count</th>
            <th>Status</th>
        </tr>
        <tr>
            <td>Total Users</td>
            <td>$($users.Count)</td>
            <td class="success">OK</td>
        </tr>
        <tr>
            <td>Disabled Users</td>
            <td class="warning">$($disabledUsers.Count)</td>
            <td>Review</td>
        </tr>
        <tr>
            <td>Passwords Expiring (30 days)</td>
            <td class="warning">$($passwordExpiringUsers.Count)</td>
            <td>Review</td>
        </tr>
        <tr>
            <td>Total Computers</td>
            <td>$($computers.Count)</td>
            <td class="success">OK</td>
        </tr>
        <tr>
            <td>Total Groups</td>
            <td>$($groups.Count)</td>
            <td class="success">OK</td>
        </tr>
    </table>
</body>
</html>
"@

$html | Out-File -FilePath $ReportPath -Encoding UTF8
Write-Host "Report generated: $ReportPath"
