<#
=============================================================================================
Name:           Microsoft 365 Group Report
Description:    Exports Microsoft 365 groups and their membership to CSV
Version:        1.1
Source:         Adapted from o365reports.com reference script
============================================================================================
#>

Param
(
    [Parameter(Mandatory = $false)]
    [string]$GroupIDsFile,
    [switch]$DistributionList,
    [switch]$Security,
    [switch]$MailEnabledSecurity,
    [switch]$IsEmpty,
    [int]$MinGroupMembersCount,
    [string]$UserName,
    [string]$Password
)

Function Get_Members
{
    $DisplayName = $_.DisplayName
    Write-Progress -Activity "Processed Group count: $Count" -Status "Getting members of: $DisplayName"
    $EmailAddress = $_.EmailAddress
    $GroupType = $_.GroupType
    $ObjectId = $_.ObjectId
    $Recipient = ""
    $RecipientHash = @{}

    for ($KeyIndex = 0; $KeyIndex -lt $RecipientTypeArray.Length; $KeyIndex += 2)
    {
        $key = $RecipientTypeArray[$KeyIndex]
        $Value = $RecipientTypeArray[$KeyIndex + 1]
        $RecipientHash.Add($key, $Value)
    }

    $Members = Get-MsolGroupMember -All -GroupObjectId $ObjectId
    $MembersCount = $Members.Count

    if (($Security.IsPresent) -and ($GroupType -ne "Security")) { return }
    if (($DistributionList.IsPresent) -and ($GroupType -ne "DistributionList")) { return }
    if (($MailEnabledSecurity.IsPresent) -and ($GroupType -ne "MailEnabledSecurity")) { return }

    if (($PSBoundParameters.ContainsKey('MinGroupMembersCount')) -and ($MembersCount -lt [int]$MinGroupMembersCount))
    {
        return
    }
    elseif ($MembersCount -eq 0)
    {
        $MemberName = "No Members"
        $MemberEmail = "-"
        $RecipientTypeDetail = "-"
        Print_Output
    }
    else
    {
        foreach ($Member in $Members)
        {
            if ($IsEmpty.IsPresent) { return }

            $MemberName = $Member.DisplayName
            $MemberType = $Member.GroupMemberType
            $MemberEmail = $Member.EmailAddress
            if ([string]::IsNullOrWhiteSpace($MemberEmail))
            {
                $MemberEmail = "-"
            }

            foreach ($key in [object[]]$RecipientHash.Keys)
            {
                if ($MemberType -eq $key)
                {
                    [int]$RecipientHash[$key] += 1
                }
            }
            Print_Output
        }
    }

    $Hash = @{}
    $Hash = $RecipientHash.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
        if ([int]$($_.Value) -gt 0)
        {
            if ($Recipient -ne "") { $Recipient += ";" }
            $Recipient += @("$($_.Key) - $($_.Value)")
        }
        if ($Recipient -eq "") { $Recipient = "-" }
    }

    $Result = @{
        'DisplayName' = $DisplayName
        'EmailAddress' = $EmailAddress
        'GroupType' = $GroupType
        'GroupMembersCount' = $MembersCount
        'MembersCountByType' = $Recipient
    }

    $Results = New-Object PSObject -Property $Result
    $Results | Select-Object DisplayName, EmailAddress, GroupType, GroupMembersCount, MembersCountByType |
        Export-Csv -Path $ExportSummaryCSV -NoTypeInformation -Append
}

Function Print_Output
{
    $Result = @{
        'GroupName' = $DisplayName
        'GroupEmailAddress' = $EmailAddress
        'Member' = $MemberName
        'MemberEmail' = $MemberEmail
        'MemberType' = $MemberType
    }

    $Results = New-Object PSObject -Property $Result
    $Results | Select-Object GroupName, GroupEmailAddress, Member, MemberEmail, MemberType |
        Export-Csv -Path $ExportCSV -NoTypeInformation -Append
}

Function Main
{
    $Module = Get-Module -Name MSOnline -ListAvailable
    if ($Module.Count -eq 0)
    {
        Write-Host "MSOnline module is not available" -ForegroundColor Yellow
        $Confirm = Read-Host "Install module now? [Y] Yes [N] No"
        if ($Confirm -match "[yY]")
        {
            Install-Module MSOnline -Scope CurrentUser
            Import-Module MSOnline
        }
        else
        {
            Write-Host "MSOnline module is required. Install with: Install-Module MSOnline" -ForegroundColor Red
            Exit
        }
    }

    Write-Host "Connecting to Office 365..."
    if (($UserName -ne "") -and ($Password -ne ""))
    {
        $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
        $Credential = New-Object System.Management.Automation.PSCredential $UserName, $SecuredPassword
        Connect-MsolService -Credential $Credential
    }
    else
    {
        Connect-MsolService | Out-Null
    }

    $ExportCSV = ".\M365Group-DetailedMembersReport_$((Get-Date -Format 'yyyy-MMM-dd-ddd hh-mm tt').ToString()).csv"
    $ExportSummaryCSV = ".\M365Group-SummaryReport_$((Get-Date -Format 'yyyy-MMM-dd-ddd hh-mm tt').ToString()).csv"

    # Built-in recipient member types to avoid external file dependency.
    $RecipientTypeArray = @(
        'User', 0,
        'Group', 0,
        'Contact', 0,
        'Unknown', 0
    )

    $Result = ""
    $Results = @()
    $Count = 0

    if ([string]::IsNullOrWhiteSpace($GroupIDsFile) -eq $false)
    {
        $DG = Import-Csv -Header "DisplayName" $GroupIDsFile
        foreach ($item in $DG)
        {
            Get-MsolGroup -ObjectId $item.DisplayName | ForEach-Object {
                $Count++
                Get_Members
            }
        }
    }
    else
    {
        Get-MsolGroup -All | ForEach-Object {
            $Count++
            Get_Members
        }
    }

    Write-Host "`nScript executed successfully"
    if (Test-Path -Path $ExportCSV)
    {
        Write-Host "Detailed report available in: $ExportCSV"
        Write-Host "Summary report available in: $ExportSummaryCSV"

        $Prompt = New-Object -ComObject wscript.shell
        $UserInput = $Prompt.Popup("Do you want to open output files?", 0, "Open Output File", 4)
        if ($UserInput -eq 6)
        {
            Invoke-Item $ExportCSV
            Invoke-Item $ExportSummaryCSV
        }
    }
    else
    {
        Write-Host "No group found."
    }
}

. Main
