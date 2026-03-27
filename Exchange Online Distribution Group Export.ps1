# === Module Check ===
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Installing ImportExcel module..."
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}
Import-Module ImportExcel

if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing ExchangeOnlineManagement module..."
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
}
Import-Module ExchangeOnlineManagement

# === Connect to Exchange Online (WAM interactive login) ===
Write-Host "Connecting to Exchange Online using Windows sign-in..."
Connect-ExchangeOnline

# === Define Groups ===
$Groups = Get-DistributionGroup | Select-Object -ExpandProperty Name

# === Prepare Export Path ===
$ExportFolder = "C:\Temp"
if (-not (Test-Path $ExportFolder)) {
    New-Item -ItemType Directory -Force -Path $ExportFolder | Out-Null
}

$Timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")
$OutputPath = "$ExportFolder\DistributionGroupMembers_$Timestamp.xlsx"

if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }

# === Process Each Group ===
foreach ($Group in $Groups) {
    Write-Host "`nProcessing group: $Group"

    try {
        $GroupObj = Get-DistributionGroup -Identity $Group -ErrorAction Stop
    } catch {
        Write-Warning "Group not found: $Group"
        continue
    }

    # --- Attempt primary method ---
    try {
        $Members = Get-DistributionGroupMember -Identity $Group -ResultSize Unlimited -ErrorAction Stop
    } catch {
        Write-Warning "Failed using Get-DistributionGroupMember for $Group"
        $Members = @()
    }

    # --- If we didn't get enough members, use Get-Recipient fallback ---
    if (-not $Members -or $Members.Count -lt 1) {
        Write-Host "Using Get-Recipient fallback for group: $Group"
        $Members = Get-Recipient -Filter "MemberOfGroup -eq '$Group'" -ResultSize Unlimited
    }

    # --- Expand nested groups if any ---
    $GroupResults = @()
    foreach ($Member in $Members) {
        if ($Member.RecipientType -like "*Group") {
            Write-Host "Expanding nested group: $($Member.DisplayName)"
            try {
                $NestedMembers = Get-DistributionGroupMember -Identity $Member.PrimarySmtpAddress -ResultSize Unlimited
                foreach ($Nested in $NestedMembers) {
                    $GroupResults += [PSCustomObject]@{
                        DisplayName        = $Nested.DisplayName
                        PrimarySMTPAddress = $Nested.PrimarySmtpAddress
                        RecipientType      = "$($Nested.RecipientType) (Nested)"
                    }
                }
            } catch {
                Write-Warning "Failed to expand nested group: $($Member.DisplayName)"
            }
        } else {
            $GroupResults += [PSCustomObject]@{
                DisplayName        = $Member.DisplayName
                PrimarySMTPAddress = $Member.PrimarySmtpAddress
                RecipientType      = $Member.RecipientType
            }
        }
    }

    # --- Export results to Excel ---
    if ($GroupResults.Count -gt 0) {
        Write-Host "Exporting $($GroupResults.Count) members from '$Group'..."
        $GroupResults | Export-Excel -Path $OutputPath -WorksheetName $Group -AutoSize -FreezeTopRow -BoldTopRow -Append
    } else {
        Write-Warning "No members found in group: $Group"
    }
}

# === Cleanup ===
Write-Host "`nDisconnecting from Exchange Online..."
Disconnect-ExchangeOnline -Confirm:$false

Write-Host "`nExport complete!"
Write-Host "Excel file saved to: $OutputPath"
Write-Host "`nPress Enter to close..."
Read-Host
