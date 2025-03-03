# Check if running as an administrator
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')

if (-not $isAdmin) {
    $params = @{
        FilePath     = 'powershell' # or 'pwsh' for PowerShell Core
        Verb         = 'RunAs'
        ArgumentList = @(
            '-NoExit',
            '-ExecutionPolicy Bypass',
            '-File "{0}"' -f $PSCommandPath
        )
    }
    Start-Process @params
    return
}

powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /hange hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0


# Define registry settings for Google Chrome
$settings = @(
    [PSCustomObject]@{ Path = "SOFTWARE\Policies\Google\Chrome"; Value = 4; Name = "RestoreOnStartup" },
    [PSCustomObject]@{ Path = "SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs"; Value = "https://medicusit.com"; Name = "URL1" }
)

# Process registry settings
foreach ($setting in $settings) {
    try {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Path, $true) ?? 
                    [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Path, $true)
        $registry.SetValue($setting.Name, $setting.Value)
    } catch {
        Write-Error "Failed to set registry key: $($_.Exception.Message)"
    } finally {
        $registry.Dispose()
    }
}


# Remove specified Appx packages
$packagesToRemove = @(
    '*3dbuilder*', '*windowsalarms*', '*windowscommunicationsapps*',
    '*windowscamera*', '*officehub*', '*skypeapp*', '*getstarted*',
    '*zunemusic*', '*windowsmaps*', '*solitairecollection*', 
    '*bingfinance*', '*zunevideo*', '*bingnews*', '*windowsphone*', 
    '*bingsports*', '*bingweather*', '*xbox*', 
    '*onenote*', '*bing*', '*mixedreality*'
)

foreach ($package in $packagesToRemove) {
	Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like $package} | Remove-AppxProvisionedPackage -Online
    Get-AppxPackage -AllUsers $package | Remove-AppxPackage -AllUsers
}

Set-TimeZone -Id "EST"

# Open Windows Update settings
Start-Process "C:\Windows\System32\control.exe" -ArgumentList "/name Microsoft.WindowsUpdate"
