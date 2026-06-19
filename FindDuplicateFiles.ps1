# Find Duplicate Files in Directory
# Identifies duplicate files based on hash

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$OutputFile = "C:\Reports\DuplicateFiles_$(Get-Date -Format 'yyyyMMdd').csv"
)

if (-not (Test-Path $Path)) {
    Write-Error "Path not found: $Path"
    exit
}

Write-Host "Scanning for duplicate files in: $Path"

# Get all files and calculate hashes
$files = Get-ChildItem -Path $Path -File -Recurse
$fileHashes = @{}
$duplicates = @()

ForEach ($file in $files) {
    try {
        $hash = (Get-FileHash -Path $file.FullName -ErrorAction SilentlyContinue).Hash
        
        if ($hash) {
            if ($fileHashes.ContainsKey($hash)) {
                $duplicates += [PSCustomObject]@{
                    Hash = $hash
                    OriginalFile = $fileHashes[$hash]
                    DuplicateFile = $file.FullName
                    FileSize_MB = [math]::Round($file.Length / 1MB, 2)
                }
            } else {
                $fileHashes[$hash] = $file.FullName
            }
        }
    } catch {
        Write-Warning "Error hashing $($file.FullName): $_"
    }
}

if ($duplicates) {
    Write-Host "Found $($duplicates.Count) duplicate files"
    $duplicates | Format-Table -AutoSize
    $duplicates | Export-Csv -Path $OutputFile -NoTypeInformation
    Write-Host "Exported to: $OutputFile"
} else {
    Write-Host "No duplicate files found"
}
