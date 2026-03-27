# PowerShell script to import all Wi-Fi profiles from XML files in C:\
# Run this after running netsh wlan export profile key=clear folder="C:\wifi"
# You will need to copy these .xml files to the new machine. Copy the files straight to C:\ to run script as is, otherwise adjust path accordingly

# Get all XML files in C:\
$xmlFiles = Get-ChildItem -Path 'C:\' -Filter '*.xml' -File

foreach ($file in $xmlFiles) {
    Write-Host "Importing Wi-Fi profile from $($file.FullName)..." -ForegroundColor Cyan
    netsh wlan add profile filename="`"$($file.FullName)`""
}

Write-Host "All profiles processed." -ForegroundColor Green
