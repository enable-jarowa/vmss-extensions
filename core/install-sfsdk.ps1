Write-Output "------------------------------------------"
Write-Output "Custom script: install-sfsdk.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

if ($f_featurearray.Contains("sfsdk")) {
     Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 

    $msi = "MicrosoftServiceFabricSDK.4.2.477.msi"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://download.microsoft.com/download/f/c/3/fc39707f-f67c-4c1b-9274-a055a3eb51b8/MicrosoftServiceFabricSDK.4.2.477.msi" `
            -OutFile $fileDownloaded -UseBasicParsing
    }
    Start-Process "msiexec" -ArgumentList '/i', "$($fileDownloaded)", '/passive', '/quiet', '/norestart', '/qn' -NoNewWindow -Wait; 

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
