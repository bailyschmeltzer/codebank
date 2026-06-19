# Test Multiple Hosts and Ports
# Useful for checking connectivity to multiple servers on specific ports

$hosts = @(
    'pbx09.sip.sovms.com'
    'pbx10.sip.sovms.com'
    'pbx11.sip.sovms.com'
    'pbx12.sip.sovms.com'
)

$ports = @(80, 443, 3306, 5432)

$results = ForEach ($hostname in $hosts) {
    ForEach ($port in $ports) {
        Test-NetConnection -ComputerName $hostname -Port $port
    }
}

$results | Format-Table -AutoSize
