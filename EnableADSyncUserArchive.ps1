# Disable Online Archive for AD Synced Users
# First, connect to Exchange Online
Connect-ExchangeOnline  # install-module exchangeonline if needed

# Interactive selection of user to enable archive
get-mailbox | ogv -PassThru -Title "Pick User to enable archive" | Enable-Mailbox -Archive

# Alternative method using Active Directory (may not be necessary)
<#
$users = get-aduser -filter *
$user = $users | ogv -passthru -title "Pick the user that needs the archive enabled"
set-aduser -Identity $user -Add @{msExchArchiveName = "Online Archive - $($user.Userprincipalname)"}
#>
