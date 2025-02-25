########################################################################
#Creates PowerShell file to install a VPN adapter using Windows' adapter
#
#Created by Frog Fenton 
#Created on 07/11/2023
########################################################################

$outputPath = Read-Host "Please type in the output path of the VPN script"
$VPNName = Read-Host -Prompt "Please enter the Name of the VPN, EX: Name of the company"
$VPNAddress = Read-Host -Prompt "Please enter the address of the VPN host"
$VPNTunnel = Read-Host -Prompt "Please enter the Tunnel Type"
$VPNpsk = Read-Host -Prompt "Please enter the PSK"
$VPNAuth = Read-Host -Prompt "Please enter the Authentication Method"
$VpnEncryption = Read-Host -Prompt "Enter Encryption Type"
$VPNdns = Read-Host -Prompt "Enter the DNS suffix"
$VPNSplitTunnel = Read-host "Enable Split Tunneling Yes/No"
$VpnPresent = Read-Host "Please Enter random variable"
$Date = Get-Date -Format "MM.dd.yyyy"
Add-Content -path "$outputPath\vpn.ps1" -Value "########################################### `
#This is a new VPN for $VPNName `
#Created $Date
####################################

"
Add-Content -Path "$outputPath\vpn.ps1" -value "$VPNPresent = (Get-VpnConnection).Name"
$VPNSplitTunnel
If ($VPNSplitTunnel -ilike "yes"){
 Add-Content -Path "$outputpath\vpn.ps1" -value "If ($VPNPresent -notcontains '$VPNName'){

Add-VpnConnection -Name $VPNName -ServerAddress $VPNAddress -TunnelType $VPNTunnel -L2tpPSK $VPNpsk -AuthenticationMethod $VPNAuth -SplitTunneling -Encryptionlevel $VPNEncryption -DnsSuffix $VPNdns -force

}"
}
if ($VPNSplitTunnel -ilike "no"){
Add-Content -Path "$outputpath\vpn.ps1" -value "If ($VPNPresent -notcontains '$VPNName'){

Add-VpnConnection -Name $VPNName -ServerAddress $VPNAddress -TunnelType $VPNTunnel -L2tpPSK $VPNpsk -AuthenticationMethod $VPNAuth -EncryptionLevel $VPNEncryption -DnsSuffix $VPNdns -force

}"}

Write-Host "your VPN file is located at $outputpath\vpn.ps1"
Pause