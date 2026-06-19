# Get Installed Software Inventory
# Lists all installed software from registry

$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

$SoftwareInfo = ForEach ($obj in $InstalledSoftware) {
    New-Object -TypeName PSObject -Property @{
        DisplayName = $obj.GetValue('DisplayName')
        DisplayVersion = $obj.GetValue('DisplayVersion')
        Publisher = $obj.GetValue('Publisher')
        UninstallString = $obj.GetValue('UninstallString')
    }
}

$SoftwareInfo | Format-Table DisplayName, DisplayVersion, Publisher
$SoftwareInfo | Export-Csv -NoTypeInformation -Path "C:\Reports\InstalledSoftware.csv"
