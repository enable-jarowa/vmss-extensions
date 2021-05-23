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
Write-Output "Features=$($f_features)"
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

if ($f_featurearray.Contains("sfsdk")) {
     Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 

    $msi = "WebPlatformInstaller_x64_en-US.msi"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://download.microsoft.com/download/8/4/9/849DBCF2-DFD9-49F5-9A19-9AEE5B29341A/WebPlatformInstaller_x64_en-US.msi" `
            -OutFile $fileDownloaded -UseBasicParsing
    }
    Start-Process "msiexec" -ArgumentList '/i', "$($fileDownloaded)", '/passive', '/quiet', '/norestart', '/qn' -NoNewWindow -Wait  -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

    Write-Output "Installing /Products:ServiceFabricSDK_4_2_CU7"
    Start-Sleep 10
    Start-Process "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" -ArgumentList '/Install', '/Products:"ServiceFabricSDK_4_2_CU7"', '/AcceptEULA' -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

    Start-Sleep 10
    Write-Output "Installing /Products:ServiceFabricRuntime_7_2_CU7"
    Start-Process "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" -ArgumentList '/Install', '/Products:"ServiceFabricRuntime_7_2_CU7"', '/AcceptEULA' -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

    Write-Output "Installing /Products:ServiceFabricSDK_4_2_CU7 again"
    Start-Sleep 10
    Start-Process "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" -ArgumentList '/Install', '/Products:"ServiceFabricSDK_4_2_CU7"', '/AcceptEULA' -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

    Write-Output "installation done"

} else {
    Write-Output "sfsdk - not installed"
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True