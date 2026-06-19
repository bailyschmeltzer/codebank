# Add a user as site collection admin across SharePoint Online sites.
# Uses PnP.PowerShell interactive auth.

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module PnP.PowerShell -Scope CurrentUser -Force
}
Import-Module PnP.PowerShell

# Configuration
$adminCenterUrl = "https://<tenant>-admin.sharepoint.com"
$tenant = "<tenant>.onmicrosoft.com"
$clientId = "<app-client-id-guid>"
$newOwner = "admin@contoso.com"
$skipUsers = @("existing.owner1@contoso.com", "existing.owner2@contoso.com")
$logFile = "C:\Temp\SiteOwnerUpdateLog.csv"

if (Test-Path $logFile) { Remove-Item $logFile -Force }

try {
    $connection = Connect-PnPOnline -Url $adminCenterUrl -ClientId $clientId -Tenant $tenant -Interactive -ReturnConnection
    $sites = Get-PnPTenantSite -Connection $connection -ErrorAction Stop
}
catch {
    Write-Error "Unable to connect or retrieve sites: $($_.Exception.Message)"
    exit 1
}

foreach ($site in $sites) {
    try {
        $siteConnection = Connect-PnPOnline -Url $site.Url -ClientId $clientId -Tenant $tenant -Interactive -ReturnConnection
        $owners = Get-PnPSiteCollectionAdmin -Connection $siteConnection | Select-Object -ExpandProperty Email

        if (($owners -contains $newOwner) -or ($owners | Where-Object { $_ -in $skipUsers })) {
            [PSCustomObject]@{
                SiteUrl = $site.Url
                Action = "Skipped"
                Reason = "Owner already present or skip user found"
            } | Export-Csv -Path $logFile -Append -NoTypeInformation
            continue
        }

        Add-PnPSiteCollectionAdmin -Owners $newOwner -Connection $siteConnection -ErrorAction Stop

        [PSCustomObject]@{
            SiteUrl = $site.Url
            Action = "Added"
            Reason = "$newOwner added"
        } | Export-Csv -Path $logFile -Append -NoTypeInformation
    }
    catch {
        [PSCustomObject]@{
            SiteUrl = $site.Url
            Action = "Error"
            Reason = $_.Exception.Message
        } | Export-Csv -Path $logFile -Append -NoTypeInformation
    }
}

Write-Host "Completed. Log: $logFile"
