# Purpose: Audit mailboxes forwarding to a specified recipient.
Connect-ExchangeOnline 
$UPN="UPN" #UPN should be enclosed between double quotes 
$RecipientIdentity=(Get-Recipient $UPN ).Identity  
# Match both internal forwarding objects and SMTP forwarding addresses.
Get-Mailbox | where {($_.ForwardingAddress -eq $RecipientIdentity) -or ($_.ForwardingSMTPAddress -match $UPN) } | select Name, Alias 