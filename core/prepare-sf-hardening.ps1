Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-sf-hardening.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features="$($args[5])"
Write-Output "Features=$($f_features)"
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

if ($True -or ($f_featurearray.Contains("hardening"))) {
    
}

Write-Output "------------------------------------------"
Write-Output "prepare-sf-hardening.ps1"
Write-Output "------------------------------------------"
$True
