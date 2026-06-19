# Monitor Scheduled Tasks on Local and Remote Servers
# Lists all scheduled tasks and their status

param(
    [string[]]$ComputerNames = @($env:COMPUTERNAME)
)

$taskInfo = @()

ForEach ($computer in $ComputerNames) {
    try {
        $tasks = Get-ScheduledTask -CimSession (New-CimSession -ComputerName $computer -ErrorAction Stop) |
            Where-Object {$_.State -ne 'Disabled'}
        
        ForEach ($task in $tasks) {
            $lastResult = Get-ScheduledTaskInfo -CimSession (New-CimSession -ComputerName $computer) -TaskName $task.TaskName -TaskPath $task.TaskPath
            
            $taskInfo += [PSCustomObject]@{
                ComputerName = $computer
                TaskName = $task.TaskName
                TaskPath = $task.TaskPath
                State = $task.State
                Enabled = $task.Settings.Enabled
                LastResult = $lastResult.LastTaskResult
                LastRun = $lastResult.LastRunTime
            }
        }
    } catch {
        Write-Warning "Failed to connect to $computer : $_"
    }
}

$taskInfo | Format-Table -AutoSize
