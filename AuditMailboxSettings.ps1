# Audit and Report Office 365 Mailbox Settings
# Gets mailbox forwarding, delegates, and external sharing settings

Connect-ExchangeOnline -ErrorAction Stop

$mailboxes = Get-Mailbox -ResultSize Unlimited

$mailboxAudit = ForEach ($mailbox in $mailboxes) {
    $forwarding = Get-Mailbox -Identity $mailbox.Identity | Select-Object ForwardingAddress, ForwardingSmtpAddress
    $delegates = Get-MailboxPermission -Identity $mailbox.Identity | Where-Object {$_.User -ne 'NT AUTHORITY\SELF'}
    
    [PSCustomObject]@{
        DisplayName = $mailbox.DisplayName
        UserPrincipalName = $mailbox.UserPrincipalName
        ForwardingAddress = $forwarding.ForwardingAddress
        ForwardingSmtpAddress = $forwarding.ForwardingSmtpAddress
        DelegateCount = $delegates.Count
        MailboxType = $mailbox.RecipientTypeDetails
    }
}

$mailboxAudit | Format-Table -AutoSize

# Alert on forwarding mailboxes
$forwardingMailboxes = $mailboxAudit | Where-Object {$_.ForwardingAddress -or $_.ForwardingSmtpAddress}
if ($forwardingMailboxes) {
    Write-Warning "Mailboxes with forwarding enabled: $($forwardingMailboxes.Count)"
}

# Export to CSV
# $mailboxAudit | Export-Csv -Path "C:\Reports\MailboxAudit_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
