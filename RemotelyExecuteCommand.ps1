# Remotely Execute Command on Multiple Servers
# Run a command across multiple computers and collect results

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerNames,
    [Parameter(Mandatory=$true)]
    [scriptblock]$ScriptBlock,
    [pscredential]$Credential,
    [switch]$AsJob
)

$invokeParams = @{
    ScriptBlock = $ScriptBlock
    ComputerName = $ComputerNames
}

if ($Credential) {
    $invokeParams['Credential'] = $Credential
}

if ($AsJob) {
    $invokeParams['AsJob'] = $true
    $jobs = Invoke-Command @invokeParams
    
    Write-Host "Started $($jobs.Count) jobs"
    Write-Host "To retrieve results, run: Get-Job | Receive-Job"
    return
}

$results = Invoke-Command @invokeParams

ForEach ($result in $results) {
    Write-Host "--- $($result.PSComputerName) ---"
    $result
}
