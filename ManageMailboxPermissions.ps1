# Manage Mailbox Permissions
# Add/Remove full access permissions to a mailbox (useful for shared mailbox access)

$mailboxes = Get-Mailbox
$UserWithRights = $mailboxes | Out-GridView -PassThru -Title "Select user whose rights will be modified"

if ($UserWithRights) {
    $MailboxToOperate = $mailboxes | Out-GridView -PassThru -Title "Select mailbox to change permissions"
    
    if ($MailboxToOperate) {
        # Remove existing full access rights
        Remove-MailboxPermission -Identity $MailboxToOperate.Identity -AccessRights FullAccess `
            -User $UserWithRights -Confirm:$false
        
        # Add full access rights without automapping (won't show in Outlook)
        Add-MailboxPermission -Identity $MailboxToOperate.Identity -AccessRights FullAccess `
            -User $UserWithRights -AutoMapping $false
        
        Write-Host "Permissions updated for $($UserWithRights.DisplayName)"
    }
}
