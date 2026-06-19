# Disable Windows Firewall
# Temporarily disables all firewall profiles

# Disable all firewall profiles
Get-NetFirewallProfile | ForEach-Object {
    Set-NetFirewallProfile -Enabled $false -Name $_.Name
}

# Re-enable all firewall profiles
# Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled $true
