# Import the ActiveDirectory module if not already loaded
Import-Module ActiveDirectory

# Specify the OU you want to target
$OU = "OU=YourOU,DC=YourDomain,DC=com"

# Get all users in the specified OU
$Users = Get-ADUser -Filter * -SearchBase $OU -Properties MemberOf

# Loop through each user
ForEach ($User in $Users) {
    # Get all groups the user is a member of
    $Groups = $User.MemberOf

    # Remove the user from each group (except "Domain Users")
    ForEach ($Group in $Groups) {
        if ($Group -notlike "*Domain Users*") {
            Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false
        }
    }
}