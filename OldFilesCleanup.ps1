# Purpose: Report or remove old files based on age threshold.
param(
    [string]$Path = "C:\Temp",
    [int]$Days = 30,
    [switch]$Delete
)

$cutoff = (Get-Date).AddDays(-$Days)
$files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $cutoff }

$files | Select-Object FullName, LastWriteTime, Length | Export-Csv ".\OldFilesReport.csv" -NoTypeInformation
Write-Host "Report saved to OldFilesReport.csv"

if ($Delete) {
    # Only delete when -Delete is explicitly provided.
    $files | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "Deleted $($files.Count) files."
} else {
    Write-Host "Dry run only. Re-run with -Delete to remove files."
}