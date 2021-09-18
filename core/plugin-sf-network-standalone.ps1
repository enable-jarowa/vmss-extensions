Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-sf-network-standalone.ps1"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

if ($f_featurearray.Contains("sfstandalone")) {
    $ruleName = "_Enable Service Fabric App Ports"
    $enableRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore
    if ($null -eq $enableRule) {
        New-NetFirewallRule -DisplayName "$($ruleName)" `
            -Profile @('Domain', 'Private', 'Public') `
            -Direction Inbound -Action Allow -Protocol TCP `
            -LocalPort @('8000', '8001', '8002', '8003', '8010', '443')
    } else {
        Write-Host "$($ruleName) - Rule already exists"
    }

    $ruleName = "_Enable Service Fabric App Admin Ports"
    $enableRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore
    if ($null -eq $enableRule) {
        New-NetFirewallRule -DisplayName "$($ruleName)" `
            -Profile @('Domain', 'Private', 'Public') `
            -Direction Inbound -Action Allow -Protocol TCP `
            -LocalPort @('19000', '19080')


    } else {
        Write-Host "$($ruleName) - Rule already exists"
    }


    $ruleName = "_Enable Service Fabric App Health Ports"
    $enableRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore
    if ($null -eq $enableRule) {
        New-NetFirewallRule -DisplayName "$($ruleName)" `
            -Profile @('Domain', 'Private', 'Public') `
            -Direction Inbound -Action Allow -Protocol TCP `
            -LocalPort @('49152-65534')
        New-NetFirewallRule -DisplayName "$($ruleName) UDP" `
            -Profile @('Domain', 'Private', 'Public') `
            -Direction Inbound -Action Allow -Protocol UDP `
            -LocalPort @('49152-65534')


    } else {
        Write-Host "$($ruleName) - Rule already exists"
    }
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
