# Export quick Exchange recipient summaries.
# Requires Exchange Online module and appropriate permissions.

Connect-ExchangeOnline

Write-Host "Users with mailboxes" -ForegroundColor Cyan
Get-User -ResultSize Unlimited |
    Get-Mailbox |
    Select-Object DisplayName, UserPrincipalName, RecipientTypeDetails

Write-Host "Room mailboxes" -ForegroundColor Cyan
Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails RoomMailbox |
    Select-Object DisplayName, UserPrincipalName, PrimarySmtpAddress

Write-Host "Shared mailboxes" -ForegroundColor Cyan
Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox |
    Select-Object DisplayName, UserPrincipalName, PrimarySmtpAddress
