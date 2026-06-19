# Purpose: Collect a bundled set of baseline network diagnostics.
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir = ".\NetDiag_$stamp"
# Timestamped folder keeps each diagnostic capture separate.
New-Item -ItemType Directory -Path $outDir | Out-Null

ipconfig /all > "$outDir\ipconfig_all.txt"
route print > "$outDir\route_print.txt"
arp -a > "$outDir\arp.txt"
nslookup microsoft.com > "$outDir\nslookup_test.txt"
Test-NetConnection 8.8.8.8 -InformationLevel Detailed | Out-File "$outDir\test_netconnection.txt"
Get-DnsClientServerAddress | Out-File "$outDir\dns_servers.txt"

Write-Host "Network diagnostics saved to $outDir"