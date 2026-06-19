# List All Members of a Security Group Recursively
# Shows direct members and nested group members

param(
    [Parameter(Mandatory=$true)]
    [string]$GroupName
)

function Get-GroupMembersRecursive {
    param(
        [Parameter(Mandatory=$true)]
        $Group,
        [int]$Level = 0
    )
    
    $indent = "  " * $Level
    $members = Get-ADGroupMember -Identity $Group
    
    ForEach ($member in $members) {
        if ($member.ObjectClass -eq 'group') {
            Write-Host "$indent[GROUP] $($member.Name)"
            Get-GroupMembersRecursive -Group $member -Level ($Level + 1)
        } else {
            Write-Host "$indent[USER] $($member.Name)"
        }
    }
}

try {
    $group = Get-ADGroup -Identity $GroupName
    Write-Host "Members of group: $($group.Name)" -ForegroundColor Green
    Get-GroupMembersRecursive -Group $group
} catch {
    Write-Error "Group not found: $GroupName"
}
