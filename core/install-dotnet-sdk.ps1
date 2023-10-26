Write-Output "------------------------------------------"
Write-Output "Custom script: install-dotnet-sdk.ps1"
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

## always install both versions all the time
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol
$channel="7.0"

$location="$($env:programfiles)\dotnet"
. $PSScriptRoot\dotnet-install.ps1 -Channel "$($channel)" -InstallDir "$($location)"

$newPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if (!$newPath.Contains("dotnet")) {
    $newPath += ";$($location)"
    $newPath = [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Output "added dotnet to path"
} else {
    Write-Output "dotnet is already in path"
}

$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol
$channel="6.0"

$location="$($env:programfiles)\dotnet"
. $PSScriptRoot\dotnet-install.ps1 -Channel "$($channel)" -InstallDir "$($location)"

$newPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if (!$newPath.Contains("dotnet")) {
    $newPath += ";$($location)"
    $newPath = [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Output "added dotnet to path"
} else {
    Write-Output "dotnet is already in path"
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
