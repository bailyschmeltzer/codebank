# Create Scheduled Task in PowerShell
# This example creates a scheduled task to run daily at 3 AM

# Create a new task action
$taskAction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-File C:\Scripts\RDSCollectionMonitoring.ps1'

# Create daily trigger for 3 AM
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 3AM

# Naming with '\' creates subfolder structure
$taskName = "MedicusIT\RDS Monitoring"

# Describe the scheduled task
$description = "Monitor RDS Sessions"

# Register the scheduled task
Register-ScheduledTask `
    -TaskName $taskName `
    -RunLevel ([Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.RunLevelEnum]::Limited) `
    -Action $taskAction `
    -Trigger $taskTrigger `
    -Description $description

# Modify task to run every 30 minutes instead
$TaskToModify = Get-ScheduledTask -TaskName "RDS Monitoring" -TaskPath '\MedicusIT\'
$TaskToModify.Triggers[0].Repetition.Duration = "P1D"
$TaskToModify.Triggers[0].Repetition.Interval = "PT30M"
$TaskToModify | Set-ScheduledTask -User "NT AUTHORITY\SYSTEM"
