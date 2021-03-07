Write-Host "------------------------------------------"
Write-Host "Custom script: map-file-share.ps1"
Write-Host "------------------------------------------"
Write-Host "$($args.Count) received"
Write-Host "------------------------------------------"
Write-Host "Hello Vmss"
Write-Host "Nof arguments: $($args.Count)"
## dont do this if you pass secure arguments
Write-Host "Arguments: $($args)"
Write-Host "------------------------------------------"
Write-Host "done"
Write-Host "------------------------------------------"
$True
