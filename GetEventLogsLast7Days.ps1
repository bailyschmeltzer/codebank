# Get Event Log entries from past 7 days
# Searches for Terminal Services or Remote Desktop related logs

$Yesterday = (Get-Date).AddDays(-7)
Get-WinEvent -ListLog * -EA SilentlyContinue | 
    Where-Object {($_.LogName -match 'Terminal' -or $_.LogName -match 'Remote') -and $_.lastwritetime -gt $Yesterday} | 
    ForEach-Object {Get-WinEvent -LogName $_.LogName -MaxEvents 50}
