# Audit Active Directory Group Membership Changes
# Find users recently added to or removed from groups

param(
    [int]$Days = 7
)

$startTime = (Get-Date).AddDays(-$Days)
$domainName = (Get-ADDomain).Name

# Search for group membership modification events
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4728, 4729, 4730, 4731, 4732, 4733, 4734, 4735, 4740  # Group membership change events
    StartTime = $startTime
} -ErrorAction SilentlyContinue

$groupChanges = ForEach ($event in $events) {
    $xml = [xml]$event.ToXml()
    [PSCustomObject]@{
        TimeCreated = $event.TimeCreated
        EventID = $event.Id
        EventType = switch($event.Id) {
            4728 { 'User Added to Global Group' }
            4729 { 'User Removed from Global Group' }
            4732 { 'User Added to Local Group' }
            4733 { 'User Removed from Local Group' }
            default { 'Group Modification' }
        }
        TargetGroup = $xml.Event.EventData.Data[0].'#text'
        SubjectAccount = $xml.Event.EventData.Data[1].'#text'
    }
}

$groupChanges | Format-Table TimeCreated, EventType, TargetGroup, SubjectAccount -AutoSize
