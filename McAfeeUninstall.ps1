# Uninstall McAfee using official cleanup tool
$DebloatFolder = 'C:\MedicusIt'
$URL = 'https://github.com/andrew-s-taylor/public/raw/main/De-Bloat/mcafeeclean.zip'
$destination = join-path $DebloatFolder mcAfeeUninstall.zip

Invoke-WebRequest -Uri $URL -OutFile $destination -Method Get
Expand-Archive $destination -DestinationPath $DebloatFolder -Force

start-process (Join-Path $debloatFolder Mccleanup.exe) -ArgumentList "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s"
