## JAROWA AG, Industriestrasse 47, 6300 Zug
## owner: lorenz-haenggi-jarowa
## this script is used to prepare a VM and format disk including mapping a drive
## for us it is used as a dependency to use Service Fabric not on a TEMP drive but on a addition Disk
## 
## 1. used to map a drive to a file share on storage account in azure
## 2. formatting all defined Disks per VM or VMSS in Azure
##
. $PSScriptRoot\map-file-share.ps1 @args >> "$($env:TEMP)\map-file-share.log"
. $PSScriptRoot\prepare-vm-disk.ps1 >> "$($env:TEMP)\prepare-vm-disk.log"
