Write-Output "------------------------------------------"
Write-Output "Custom script: install-node.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]

if ($f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" }).Contains("sfsdk")) {
    $msi = "WebPlatformInstaller_x64_en-US.msi"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://download.microsoft.com/download/8/4/9/849DBCF2-DFD9-49F5-9A19-9AEE5B29341A/WebPlatformInstaller_x64_en-US.msi" `
            -OutFile $fileDownloaded -UseBasicParsing
    }
    Start-Process "msiexec" -ArgumentList '/i', "$($fileDownloaded)", '/passive', '/quiet', '/norestart', '/qn' -NoNewWindow -Wait; 

    & "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" /Install /Products:MicrosoftAzure-ServiceFabric-CoreSDK /AcceptEULA

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
