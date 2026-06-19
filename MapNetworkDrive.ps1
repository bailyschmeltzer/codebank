# Map Network Drive
# Quickly map a network share to a drive letter with optional persistence

param(
    [Parameter(Mandatory=$true)]
    [char]$DriveLetter,
    [Parameter(Mandatory=$true)]
    [string]$NetworkPath,
    [string]$UserName,
    [string]$Password,
    [switch]$Persistent
)

$driveName = "$($DriveLetter):"

try {
    $mapParams = @{
        LocalPath = $driveName
        RemotePath = $NetworkPath
        Persist = $Persistent
        ErrorAction = 'Stop'
    }
    
    if ($UserName -and $Password) {
        $credential = New-Object System.Management.Automation.PSCredential($UserName, (ConvertTo-SecureString $Password -AsPlainText -Force))
        $mapParams['Credential'] = $credential
    }
    
    New-PSDrive @mapParams
    
    Write-Host "Network drive mapped successfully" -ForegroundColor Green
    Write-Host "  Drive Letter: $driveName"
    Write-Host "  Network Path: $NetworkPath"
    Write-Host "  Persistent: $Persistent"
    
} catch {
    Write-Error "Failed to map network drive: $_"
}
