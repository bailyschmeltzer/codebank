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


# Set the Administrator password and disable the account
net user Administrator PASSWORD
net user Administrator /active:no
WMIC USERACCOUNT WHERE Name='Administrator' SET PasswordExpires=FALSE

# Add a new user
net user USERNAME PASSWORD /add
WMIC USERACCOUNT WHERE Name='USERNAME' SET PasswordExpires=FALSE

# Add the new user to the Administrators group
net localgroup administrators USERNAME /add

# Enable RDP by modifying registry keys
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /T REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-TCP" /v UserAuthentication /t REG_DWORD /d 0 /f

# Disable Windows Firewall (optional)
netsh AdvFirewall set allprofiles state off

# Add "Domain Users" to Administrators group
net localgroup Administrators "Domain Users" /add

# Set timeout settings to never
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0

# Download Chrome if not already present 
$downloadUrl = "https://dl.google.com/chrome/install/standalone/GoogleChromeStandaloneEnterprise64.msi" 
$localPath = "C:\Temp\GoogleChromeStandaloneEnterprise64.msi" 

# Ensure the Temp directory exists
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory
}

# Check if .msi already exists in file path, download if not
if (!(Test-Path $localPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing
}

# Install Chrome silently
Start-Process -FilePath $localPath -ArgumentList "/quiet /norestart" -Wait

# URL of the Dell Command | Update installer
$downloadUrl = "https://downloads.dell.com/FOLDER05079098M/1/Dell-Command-Update_Application_4.0.0.139_A00.exe"
$localPath = "C:\Temp\DellCommandUpdate.exe"

# Ensure the Temp directory exists
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory
}

# Check if the installer already exists in the file path, download if not
if (!(Test-Path $localPath)) {
    Write-Host "Downloading Dell Command Update installer..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing
    Write-Host "Download complete!"
} else {
    Write-Host "Installer already exists."
}

# Optionally, run the installer silently
Write-Host "Running the installer..."
Start-Process -FilePath $localPath -ArgumentList "/quiet /norestart" -Wait
Write-Host "Dell Command Update installed successfully!"

# Download the Teams bootstrapper if not already present 
$downloadUrl = "https://download.microsoft.com/download/7/0/5/70585c-c22b-4bcb-b69d-14e2d4c038a2/Teams_windows_x64.exe" 
$localPath = "C:\Temp\TeamsBootstrapper.exe" 

# Checks if .exe already exists in file path, downloads if not
if(!(Test-Path $localPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing
}


# Remove existing copies of Teams
teamsbootstrapper -x
teamsbootstrapper -u 

# Install Teams using the bootstrapper 
Start-Process -FilePath $localPath -ArgumentList "-p" -Wait


# Step 1: Define paths and URLs
$odtUrl = "https://download.microsoft.com/download/1/7/6/176F2D4E-2D61-4365-8B2D-67D99B1A5788/OfficeDeploymentTool.exe"
$odtPath = "C:\Temp\OfficeDeploymentTool.exe"
$odtExtractPath = "C:\Temp\OfficeDeploymentTool"
$configFile = "C:\Temp\configuration.xml"

# Step 2: Download the Office Deployment Tool
if (!(Test-Path $odtPath)) {
    Write-Host "Downloading the Office Deployment Tool..."
    Invoke-WebRequest -Uri $odtUrl -OutFile $odtPath
    Write-Host "Office Deployment Tool downloaded successfully."
} else {
    Write-Host "Office Deployment Tool already downloaded."
}

# Step 3: Extract the Office Deployment Tool
if (!(Test-Path $odtExtractPath)) {
    Write-Host "Extracting the Office Deployment Tool..."
    Start-Process -FilePath $odtPath -ArgumentList "/quiet /extract:$odtExtractPath" -Wait
    Write-Host "Office Deployment Tool extracted successfully."
} else {
    Write-Host "Office Deployment Tool already extracted."
}

# Step 4: Create the Configuration XML File for Office 365 Installation
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
"@

# Save the configuration file
$configXmlContent | Out-File -FilePath $configFile -Force
Write-Host "Configuration file created."

# Step 5: Install Office 365 using the Office Deployment Tool
Write-Host "Starting Office 365 installation..."
Start-Process -FilePath "$odtExtractPath\setup.exe" -ArgumentList "/configure `"$configFile`"" -Wait

Write-Host "Office 365 installation completed!"

# Step 1: Define paths and URLs for Adobe Reader
$readerUrl = "https://get.adobe.com/reader/download/?installer=Reader_DC_zh_CN&standalone=1" # You may need to update the URL for your specific version or language.
$installerPath = "C:\Temp\AcrobatReaderInstaller.exe"

# Step 2: Download the Adobe Acrobat Reader installer
if (!(Test-Path $installerPath)) {
    Write-Host "Downloading Adobe Acrobat Reader..."
    Invoke-WebRequest -Uri $readerUrl -OutFile $installerPath
    Write-Host "Adobe Acrobat Reader downloaded successfully."
} else {
    Write-Host "Adobe Acrobat Reader installer already downloaded."
}

# Step 3: Install Adobe Acrobat Reader silently
Write-Host "Starting Adobe Acrobat Reader installation..."
Start-Process -FilePath $installerPath -ArgumentList "/sAll /msi EULA_ACCEPT=YES" -Wait
Write-Host "Adobe Acrobat Reader installation completed!"



# Set Chrome as the default browser via registry 
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice" -Name "ProgId" -Value "ChromeHTML"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice" -Name "ProgId" -Value "ChromeHTML"



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


# Set timezone to EST
Set-TimeZone -Id "EST"

# Open Windows Update settings
Start-Process "C:\Windows\System32\control.exe" -ArgumentList "/name Microsoft.WindowsUpdate"
