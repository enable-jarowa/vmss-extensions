Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-sf-network.ps1"
Write-Output "------------------------------------------"

$ruleName = "_Enable Service Fabric App Ports"
$enableRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore
if ($null -eq $enableRule) {
    New-NetFirewallRule -DisplayName '_Enable Service Fabric App Ports' `
        -Profile @('Domain', 'Private', 'Public') `
        -Direction Inbound -Action Allow -Protocol TCP `
        -LocalPort @('8000', '8001', '8002', '8003', '8010')
} else {
    Write-Host "$($ruleName) - Rule already exists"
}

$ruleName = "_Enable Service Fabric App Ports Special"
$enableRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore
if ($null -eq $enableRule) {
    New-NetFirewallRule -DisplayName '_Enable Service Fabric App Ports Special' `
        -Profile @('Domain', 'Private', 'Public') `
        -Direction Inbound -Action Allow -Protocol TCP `
        -LocalPort @('8008')
} else {
    Write-Host "$($ruleName) - Rule already exists"
}

$ruleName = "_Enable Service Fabric App Config Ports"
$enableRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore
if ($null -eq $enableRule) {
    New-NetFirewallRule -DisplayName '_Enable Service Fabric App Config Ports' `
        -Profile @('Domain', 'Private', 'Public') `
        -Direction Inbound -Action Allow -Protocol TCP `
        -LocalPort @('8020')
} else {
    Write-Host "$($ruleName) - Rule already exists"
}


Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
