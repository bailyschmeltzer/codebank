# Purpose: Report enabled AD users inactive for 90+ days.
import-module activedirectory
$Date = Get-Date -Format yyyy.MM.dd
$90Days = (get-date).adddays(-90)
# Query for stale enabled accounts and write a dated CSV report.
Get-ADUser -properties * -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $90days) -AND (passwordlastset -le $90days) -AND 
    (enabled -eq $True) -and (PasswordNeverExpires -eq $false) -and (whencreated -le $90days)} | select-object name, SAMaccountname, 
    passwordExpired, PasswordNeverExpires, logoncount, whenCreated, lastlogondate, PasswordLastSet, lastlogontimestamp | export-csv "c:\$Date DayUserReport.csv"