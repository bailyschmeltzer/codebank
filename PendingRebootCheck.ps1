# Purpose: Check common registry flags indicating a pending reboot.
$pending = $false
$reasons = @()

if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
    $pending = $true
    $reasons += "Component Based Servicing"
}

if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
    $pending = $true
    $reasons += "Windows Update"
}

$sessMgr = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ErrorAction SilentlyContinue
# Pending file rename operations typically indicate reboot-needed file replacements.
if ($sessMgr.PendingFileRenameOperations) {
    $pending = $true
    $reasons += "Pending File Rename Operations"
}

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    PendingReboot = $pending
    Reasons = ($reasons -join "; ")
} | Format-List