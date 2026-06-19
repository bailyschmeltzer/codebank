# Purpose: Export installed software inventory from uninstall registry keys.
$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$apps = foreach ($p in $paths) {
    Get-ItemProperty $p -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
}

# Sort and de-duplicate by display name before export.
$apps | Sort-Object DisplayName -Unique |
    Export-Csv ".\InstalledSoftware.csv" -NoTypeInformation

Write-Host "Exported to InstalledSoftware.csv"