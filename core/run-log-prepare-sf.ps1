## JAROWA AG, Industriestrasse 47, 6300 Zug
## owner: lorenz-haenggi-jarowa
## this script is used to prepare a VM and format disk including mapping a drive
## for us it is used as a dependency to use Service Fabric not on a TEMP drive but on a addition Disk
## 
## 1. used to map a drive to a file share on storage account in azure
## 2. formatting all defined Disks per VM or VMSS in Azure
##
#. $PSScriptRoot\map-file-share.ps1 @args *>> "$($env:TEMP)\map-file-share.log"
try {
    Set-MpPreference -DisableRealtimeMonitoring $true    
    Write-Output "Defender realtime switched off"
}
catch {
    Write-Output "Defender realtime switched off - failed. Still processing"
}

. $PSScriptRoot\prepare-vm-disk.ps1 *>> "$($env:TEMP)\prepare-vm-disk.log"
. $PSScriptRoot\install-dotnet-sdk.ps1 @args *>> "$($env:TEMP)\install-dotnet-sdk.log"

$filenamePlugin = "plugins-execute";
$psfilePlugin = "$($filenamePlugin).ps1";
$fileDownloadedPlugin = "$($env:TEMP)\$($psfilePlugin)"
Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/$($psfilePlugin)" `
    -OutFile $fileDownloadedPlugin -UseBasicParsing

. $env:TEMP\$psfilePlugin @args *>> "$($env:TEMP)\$($filenamePlugin).log"
. $PSScriptRoot\install-nodejs.ps1 @args *>> "$($env:TEMP)\install-nodejs.log"
. $PSScriptRoot\install-sfsdk.ps1 @args *>> "$($env:TEMP)\install-sfsdk.log"
. $PSScriptRoot\install-msbuild-tools.ps1 @args *>> "$($env:TEMP)\install-msbuild-tools.log"
. $PSScriptRoot\install-verdaccio.ps1 @args *>> "$($env:TEMP)\install-verdaccio.log"
