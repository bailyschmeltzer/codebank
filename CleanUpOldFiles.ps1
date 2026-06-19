# Clean Up Old Files and Folders
# Removes files older than specified number of days

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [int]$DaysOld = 30,
    [switch]$RemoveEmptyFolders,
    [switch]$WhatIf
)

if (-not (Test-Path $Path)) {
    Write-Error "Path not found: $Path"
    exit
}

$cutoffDate = (Get-Date).AddDays(-$DaysOld)

# Get files older than cutoff date
$oldFiles = Get-ChildItem -Path $Path -File -Recurse | 
    Where-Object {$_.LastWriteTime -lt $cutoffDate}

Write-Host "Found $($oldFiles.Count) files older than $DaysOld days"

# Delete files
ForEach ($file in $oldFiles) {
    if ($WhatIf) {
        Write-Host "Would delete: $($file.FullName)" -ForegroundColor Yellow
    } else {
        Remove-Item -Path $file.FullName -Force
        Write-Host "Deleted: $($file.FullName)"
    }
}

# Remove empty folders
if ($RemoveEmptyFolders) {
    $emptyFolders = Get-ChildItem -Path $Path -Directory -Recurse | 
        Where-Object {(Get-ChildItem -Path $_.FullName -Recurse | Measure-Object).Count -eq 0}
    
    ForEach ($folder in $emptyFolders) {
        if ($WhatIf) {
            Write-Host "Would remove empty folder: $($folder.FullName)" -ForegroundColor Yellow
        } else {
            Remove-Item -Path $folder.FullName -Force
            Write-Host "Removed empty folder: $($folder.FullName)"
        }
    }
}
