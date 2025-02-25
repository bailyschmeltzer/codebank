# Define the path to the folder whose permissions you want to view
$folderPath = "E:\Share Drive\IT"
 
# Import the ImportExcel module
Import-Module ImportExcel
 
# Create an empty array to store the permissions data
$permissionsData = @()
 
# Get a list of all folders in the specified directory
$folders = Get-ChildItem -Path $folderPath -Directory
 
# Loop through each folder and collect its permissions
foreach ($folder in $folders) {
    $acl = Get-Acl -Path $folder.FullName
    $permissions = $acl.Access | ForEach-Object {
        [PSCustomObject]@{
            FolderPath = $folder.FullName
            Identity = $_.IdentityReference
            Permissions = $_.FileSystemRights
            Type = $_.AccessControlType
        }
    }
    $permissionsData += $permissions
}
 
# Export the permissions data to an Excel file. This will paste to the location specified before ran
$permissionsData | Export-Excel -Path "PermissionsReport.xlsx" -AutoSize -ClearSheet -Title "Folder Permissions" -WorksheetName "Permissions"
 
Write-Host "Permissions retrieval process completed. Permissions report exported to PermissionsReport.xlsx."