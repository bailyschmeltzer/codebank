## This script pulls a report for the last time a folder was accessed.  Written by STR ##

# Set Folder location and output location
$folderPath = "C:\path\to\folder" # Change this to the path of the folder you want to check
$reportPath = "C:\path\to\report.csv" # Change this to the path where you want to save the report

# Create Folder path if not already created


# Get the last access times of all subfolders
$folderATimes = Get-ChildItem $folderPath -Directory | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        LastAccessTime = $_.LastAccessTime
    }
}

# Export the report to a CSV file
$folderATimes | Export-Csv $reportPath -NoTypeInformation

# Print a message to indicate that the report has been generated
Write-Output "Report generated at $reportPath"
