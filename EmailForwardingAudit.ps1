Connect-ExchangeOnline 
$UPN="UPN" #UPN should be enclosed between double quotes 
$RecipientIdentity=(Get-Recipient $UPN ).Identity  
Get-Mailbox | where {($_.ForwardingAddress -eq $RecipientIdentity) -or ($_.ForwardingSMTPAddress -match $UPN) } | select Name, Alias 