# Audit File and Folder Access Permissions
# Reports who has access to a specific file share

param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "Path not found: $Path"
    exit
}

$acl = Get-Acl -Path $Path
$permissions = @()

ForEach ($access in $acl.Access) {
    $permissions += [PSCustomObject]@{
        Path = $Path
        Identity = $access.IdentityReference
        AccessType = $access.AccessControlType
        Rights = $access.FileSystemRights
        Inheritance = $access.IsInherited
        PropagationFlags = $access.PropagationFlags
    }
}

$permissions | Format-Table -AutoSize

# Export to CSV
# $permissions | Export-Csv -Path "C:\Reports\Permissions_$(Split-Path $Path -Leaf).csv" -NoTypeInformation
