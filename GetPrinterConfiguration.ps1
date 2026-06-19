# Get List of Printers and Their Configuration
# Reports on all network printers and their settings

param(
    [string]$PrinterName = "*"
)

$printers = Get-Printer -Name $PrinterName

$printerInfo = ForEach ($printer in $printers) {
    $status = if ($printer.PrinterStatus -eq 'Normal') { 'Online' } else { $printer.PrinterStatus }
    
    [PSCustomObject]@{
        Name = $printer.Name
        Status = $status
        Type = $printer.Type
        DriverName = $printer.DriverName
        Location = $printer.Location
        Comment = $printer.Comment
        Shared = $printer.Shared
        ShareName = $printer.ShareName
    }
}

$printerInfo | Format-Table -AutoSize

# Export to CSV
# $printerInfo | Export-Csv -Path "C:\Reports\Printers.csv" -NoTypeInformation
