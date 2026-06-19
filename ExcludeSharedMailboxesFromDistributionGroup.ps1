# Exclude Shared Mailboxes from _All Users_ Dynamic Distribution Groups
# Modify the dynamic distribution group filter to exclude shared mailboxes

# Select the dynamic distribution group to modify
$DynamicDistributionGroup = Get-DynamicDistributionGroup | Out-GridView -PassThru

# Get current filter
$currentFilter = $DynamicDistributionGroup.RecipientFilter
Write-Host "Current Filter: $currentFilter"

# Updated filter that excludes shared mailboxes
$newFilter = "((RecipientType -eq 'UserMailbox') -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'GuestMailUser')) -and (-not(RecipientTypeDetailsValue -eq 'SharedMailbox')))"

# Apply the new filter
Set-DynamicDistributionGroup -Identity $DynamicDistributionGroup -RecipientFilter $newFilter

Write-Host "Filter updated to exclude shared mailboxes"
