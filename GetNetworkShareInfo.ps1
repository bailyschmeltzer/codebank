# Get Network Share Information
# Lists all shared folders on a computer

param(
    [string]$ComputerName = $env:COMPUTERNAME
)

Write-Host "Network Shares on: $ComputerName" -ForegroundColor Green

try {
    $shares = Get-WmiObject Win32_Share -ComputerName $ComputerName | Where-Object {$_.Type -eq 0}
    
    $shareInfo = ForEach ($share in $shares) {
        [PSCustomObject]@{
            Name = $share.Name
            Path = $share.Path
            Description = $share.Description
            AccessCount = $share.MaximumAllowed
        }
    }
    
    $shareInfo | Format-Table -AutoSize
    
} catch {
    Write-Error "Failed to retrieve shares from $ComputerName : $_"
}
