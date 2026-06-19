# Bulk-assign ManagedBy owners to a sequence of distribution groups.

Connect-ExchangeOnline

# Configuration
$domain = "contoso.com"  # Set to empty string to use alias-only identities.
$owners = @(
    "owner1@contoso.com"
)
$groups = 1..8 | ForEach-Object {
    if ([string]::IsNullOrWhiteSpace($domain)) { "supervisor$_" } else { "supervisor$_@$domain" }
}

foreach ($g in $groups) {
    foreach ($o in $owners) {
        Write-Host "Adding owner $o to $g..."
        Set-DistributionGroup -Identity $g -ManagedBy @{ Add = $o } -BypassSecurityGroupManagerCheck:$true -ErrorAction Stop
    }
}

Write-Host "Owner assignment complete."
