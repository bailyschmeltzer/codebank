# Install or update Sysmon with a provided XML config.
# Run from a folder containing: sysmon.exe/sysmon64.exe and sysmonconfig.xml

$services = @("Sysmon", "Sysmon64")
$runningService = $null
$configPath = "C:\ProgramData\Sysmon\sysmonconfig.xml"
$configDir = Split-Path $configPath

if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $configPath)) {
    Copy-Item .\sysmonconfig.xml -Destination $configPath -Force
}

foreach ($svc in $services) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        $runningService = $svc
    }
}

if (-not (Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue) -and -not (Get-Service -Name "Sysmon64" -ErrorAction SilentlyContinue)) {
    try {
        if ([Environment]::Is64BitOperatingSystem) {
            Copy-Item .\sysmon64.exe C:\Windows\System32\sysmon64.exe -Force
            Start-Process C:\Windows\System32\sysmon64.exe -ArgumentList "-accepteula -i `"$configPath`"" -Wait
            Start-Process C:\Windows\System32\sysmon64.exe -ArgumentList "-accepteula -c `"$configPath`"" -Wait
            $service = Get-Service -Name "Sysmon64" -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq "Running") { $runningService = "Sysmon64" }
        }
        else {
            Copy-Item .\sysmon.exe C:\Windows\System32\sysmon.exe -Force
            Start-Process C:\Windows\System32\sysmon.exe -ArgumentList "-accepteula -i `"$configPath`"" -Wait
            Start-Process C:\Windows\System32\sysmon.exe -ArgumentList "-accepteula -c `"$configPath`"" -Wait
            $service = Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq "Running") { $runningService = "Sysmon" }
        }
    }
    catch {
        Write-Error "Sysmon installation failed: $($_.Exception.Message)"
        exit 1
    }
}

if ($runningService) {
    Write-Host "Service running: $runningService"
}
else {
    Write-Host "No Sysmon service is currently running."
}
