# Network Diagnostics - Run comprehensive network tests
# Tests DNS, connectivity, and network interface status

param(
    [string]$ComputerName = $env:COMPUTERNAME,
    [string[]]$DNSServers = @('8.8.8.8', '1.1.1.1'),
    [string[]]$PingTargets = @('google.com', 'cloudflare.com')
)

Write-Host "=== Network Diagnostics for $ComputerName ===" -ForegroundColor Green

# DNS Resolution Test
Write-Host "`nDNS Resolution Test:" -ForegroundColor Cyan
ForEach ($dnsServer in $DNSServers) {
    try {
        $result = Resolve-DnsName -Name google.com -Server $dnsServer -ErrorAction Stop
        Write-Host "✓ $dnsServer - OK" -ForegroundColor Green
    } catch {
        Write-Host "✗ $dnsServer - FAILED" -ForegroundColor Red
    }
}

# Network Interface Status
Write-Host "`nNetwork Interfaces:" -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Format-Table Name, MacAddress, LinkSpeed

# Ping Tests
Write-Host "`nPing Tests:" -ForegroundColor Cyan
ForEach ($target in $PingTargets) {
    $result = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
    if ($result) {
        Write-Host "✓ $target - Response Time: $($result.ResponseTime)ms" -ForegroundColor Green
    } else {
        Write-Host "✗ $target - No response" -ForegroundColor Red
    }
}

# Check Network Connectivity
Write-Host "`nNetwork Connectivity:" -ForegroundColor Cyan
$connectivity = Test-NetConnection -ComputerName google.com -InformationLevel Quiet
Write-Host "Internet Connectivity: $(if($connectivity) {'Connected'} else {'Disconnected'})" -ForegroundColor $(if($connectivity) {'Green'} else {'Red'})
