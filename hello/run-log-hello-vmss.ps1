## run the hello-vmss.ps1 and write output into the TEMP directory for debugging
. $PSScriptRoot\hello-vmss.ps1 @args >> "$($env:TEMP)\run-hello-vmss.log"
