# Generate filename based on date in ISO 8601 format
$date = Get-Date
$fileName = [string]::format("{0}-{1,2:D2}-{2,2:D2}T{3,2:D2}{4,2:D2}{5,2:D2}",$date.year,$date.Month,$date.Day,$date.Hour,$date.Minute,$date.Second)
Write-Output $fileName
