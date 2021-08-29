Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-timezone.ps1"
Write-Output "------------------------------------------"

if (!(Get-TimeZone).DisplayName.Contains("Bern")) {

    ##
    $swissTZ=Get-TimeZone -ListAvailable | where ({$_.DisplayName.Contains("Bern")})
    Set-TimeZone -Id $swissTZ.Id
    Write-Host "New Timezone set to $($swissTZ)"

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
