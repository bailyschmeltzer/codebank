# Check if running as an administrator
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')

# If not running as an administrator, re-launch the script with elevated privileges
if (-not $isAdmin) {
    $params = @{
        FilePath     = 'powershell' # or 'pwsh' for PowerShell Core
        Verb         = 'RunAs'  # Run as Administrator
        ArgumentList = @(
            '-NoExit',
            '-ExecutionPolicy Bypass',
            '-File "{0}"' -f $PSCommandPath  # Pass the current script to the elevated process
        )
    }
    Start-Process @params
    return  # Exit the script after relaunching with elevated privileges
}


<#
# Set the Administrator password and disable the account
net user Administrator PASSWORD  # Set Administrator password
net user Administrator /active:no  # Disable the Administrator account
WMIC USERACCOUNT WHERE Name='Administrator' SET PasswordExpires=FALSE  # Prevent Administrator password from expiring

# Add a new user with the specified username and password
net user USERNAME PASSWORD /add  # Create a new user
WMIC USERACCOUNT WHERE Name='USERNAME' SET PasswordExpires=FALSE  # Prevent password expiration for the new user

# Add the new user to the Administrators group
net localgroup administrators USERNAME /add  # Add new user to the Administrators group

# Add "Domain Users" to Administrators group
net localgroup Administrators "Domain Users" /add  # Add Domain Users to Administrators group

#>


# Enable Remote Desktop Protocol (RDP) by modifying registry settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /T REG_DWORD /d 0 /f  # Enable RDP
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f  # Disable UAC for RDP
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-TCP" /v UserAuthentication /t REG_DWORD /d 0 /f  # Disable NLA (Network Level Authentication) for RDP

# Disable Windows Firewall (optional, use cautiously)
netsh AdvFirewall set allprofiles state off  # Turn off the firewall

# Set power settings to never timeout for standby, monitor, and hibernate
powercfg /change standby-timeout-ac 0  # Set standby timeout to never on AC power
powercfg /change standby-timeout-dc 0  # Set standby timeout to never on DC power
powercfg /change monitor-timeout-ac 0  # Set monitor timeout to never on AC power
powercfg /change monitor-timeout-dc 0  # Set monitor timeout to never on DC power
powercfg /change hibernate-timeout-ac 0  # Set hibernate timeout to never on AC power
powercfg /change hibernate-timeout-dc 0  # Set hibernate timeout to never on DC power

# Download and install Google Chrome if it's not already present
$downloadUrl = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"  # Chrome installer URL
$localPath = "C:\Temp\GoogleChromeStandaloneEnterprise64.msi"  # Path to save installer

# Ensure the Temp directory exists
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory  # Create Temp directory if it doesn't exist
}

# Download Chrome if it's not already present
if (!(Test-Path $localPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing  # Download the installer
}

# Install Chrome silently
Start-Process -FilePath $localPath -ArgumentList "/quiet /norestart" -Wait  # Install Chrome with no user interaction

# Download and install Dell Command Update if it's not already present
$downloadUrl = "https://downloads.dell.com/FOLDER11914075M/1/Dell-Command-Update-Application_6VFWW_WIN_5.4.0_A00.EXE"  # Dell Command Update installer URL
$localPath = "C:\Temp\DellCommandUpdate.exe"  # Path to save installer

# Ensure the Temp directory exists
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory  # Create Temp directory if it doesn't exist
}

# Download the Dell Command Update installer if not present
if (!(Test-Path $localPath)) {
    Write-Host "Downloading Dell Command Update installer..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing  # Download the installer
    Write-Host "Download complete!"
} else {
    Write-Host "Installer already exists."
}

# Run the Dell Command Update installer silently
Write-Host "Running the installer..."
Start-Process -FilePath $localPath -ArgumentList "/quiet /norestart" -Wait  # Install silently
Write-Host "Dell Command Update installed successfully!"

# Download Microsoft Teams if not already present
$downloadUrl = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"  # Teams installer URL
$localPath = "C:\Temp\TeamsBootstrapper.exe"  # Path to save installer

# Check if Teams installer exists, download if not
if(!(Test-Path $localPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing  # Download Teams installer
}

# Install Teams using the bootstrapper
Start-Process -FilePath $localPath -ArgumentList "-p" -Wait  # Install Teams silently

# Remove any existing Teams installations
teamsbootstrapper -x  # Uninstall existing Teams installations
teamsbootstrapper -u  # Uninstall existing Teams installations

# Download Office Deployment Tool if not already present
$odtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18324-20194.exe"  # Office Deployment Tool URL
$odtPath = "C:\Temp\OfficeDeploymentTool.exe"  # Path to save Office Deployment Tool
$odtExtractPath = "C:\Temp\OfficeDeploymentTool"  # Path to extract the tool
$configFile = "C:\Temp\configuration.xml"  # Path to save the configuration file

# Download the Office Deployment Tool if not already present
if (!(Test-Path $odtPath)) {
    Write-Host "Downloading the Office Deployment Tool..."
    Invoke-WebRequest -Uri $odtUrl -OutFile $odtPath  # Download Office Deployment Tool
    Write-Host "Office Deployment Tool downloaded successfully."
} else {
    Write-Host "Office Deployment Tool already downloaded."
}

# Extract the Office Deployment Tool if not already extracted
if (!(Test-Path $odtExtractPath)) {
    Write-Host "Extracting the Office Deployment Tool..."
    Start-Process -FilePath $odtPath -ArgumentList "/quiet /extract:$odtExtractPath" -Wait  # Extract tool
    Write-Host "Office Deployment Tool extracted successfully."
} else {
    Write-Host "Office Deployment Tool already extracted."
}

# Create configuration XML for Office 365 installation
$configXmlContent = @"
<Configuration>
  <Add SourcePath="https://officecdn.microsoft.com/pr/office2021/ProPlus2021Retail" OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365BusinessRetail">
      <Language ID="en-us" />
    </Product>
  </Add>
  <Display Level="Full" AcceptEULA="TRUE" />
  <Property Name="ForceAppShutdown" Value="TRUE" />
</Configuration>
"@  # Office configuration settings

# Save the configuration XML file
$configXmlContent | Out-File -FilePath $configFile -Force  # Save XML to file
Write-Host "Configuration file created."

# Install Office 365 using the Office Deployment Tool and configuration file
Write-Host "Starting Office 365 installation..."
Start-Process -FilePath "$odtExtractPath\setup.exe" -ArgumentList "/configure `"$configFile`"" -Wait  # Run Office setup
Write-Host "Office 365 installation completed!"

# Download and install Adobe Acrobat Reader if not already present
$readerUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320269/AcroRdrDCx642300320269_en_US.exe"  # Adobe Reader installer URL
$installerPath = "C:\Temp\AcrobatReaderInstaller.exe"  # Path to save installer

# Download Adobe Acrobat Reader installer if not already present
if (!(Test-Path $installerPath)) {
    Write-Host "Downloading Adobe Acrobat Reader..."
    Invoke-WebRequest -Uri $readerUrl -OutFile $installerPath  # Download Adobe Reader installer
    Write-Host "Adobe Acrobat Reader downloaded successfully."
} else {
    Write-Host "Adobe Acrobat Reader installer already downloaded."
}

# Install Adobe Acrobat Reader silently
Write-Host "Starting Adobe Acrobat Reader installation..."
Start-Process -FilePath $installerPath -ArgumentList "/sAll /msi EULA_ACCEPT=YES" -Wait  # Install Reader silently
Write-Host "Adobe Acrobat Reader installation completed!"

# Set Chrome as the default browser by modifying the registry
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice" -Name "ProgId" -Value "ChromeHTML"  # Set .html to open with Chrome
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice" -Name "ProgId" -Value "ChromeHTML"  # Set .htm to open with Chrome

# Define registry settings for Google Chrome
$settings = @(
    [PSCustomObject]@{ Path = "SOFTWARE\Policies\Google\Chrome"; Value = 4; Name = "RestoreOnStartup" },
    [PSCustomObject]@{ Path = "SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs"; Value = "https://google.com"; Name = "URL1" }
)

# Process registry settings for Chrome configuration
foreach ($setting in $settings) {
    try {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Path, $true) 
                    [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Path, $true)
        $registry.SetValue($setting.Name, $setting.Value)  # Apply registry changes
    } catch {
        Write-Error "Failed to set registry key: $($_.Exception.Message)"  # Handle errors in setting registry keys
    } finally {
        $registry.Dispose()  # Clean up registry objects
    }
}

# Remove specified Appx packages (pre-installed apps)
$packagesToRemove = @(
    '*3dbuilder*', '*windowsalarms*', '*windowscommunicationsapps*',
    '*windowscamera*', '*officehub*', '*skypeapp*', '*getstarted*',
    '*zunemusic*', '*windowsmaps*', '*solitairecollection*', 
    '*bingfinance*', '*zunevideo*', '*bingnews*', '*windowsphone*', 
    '*bingsports*', '*bingweather*', '*xbox*', 
    '*onenote*', '*bing*', '*mixedreality*'
)

# Remove the specified Appx packages
foreach ($package in $packagesToRemove) {
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like $package} | Remove-AppxProvisionedPackage -Online  # Remove provisioned packages
    Get-AppxPackage -AllUsers $package | Remove-AppxPackage -AllUsers  # Remove installed packages
}

# Set the system timezone to Eastern Standard Time (EST)
Set-TimeZone -Id "Eastern Standard Time"  # Set system timezone to EST

# Open Windows Update settings for user
Start-Process "C:\Windows\System32\control.exe" -ArgumentList "/name Microsoft.WindowsUpdate"  # Open Windows Update settings
