Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-SDK.ps1"
Write-Output "------------------------------------------"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 

$msi = "WebPlatformInstaller_x64_en-US.msi"
$fileDownloaded = "$($env:TEMP)\$($msi)"
if (!(Test-Path $fileDownloaded -PathType leaf)) {
    Invoke-WebRequest `
        -Uri "https://download.microsoft.com/download/8/4/9/849DBCF2-DFD9-49F5-9A19-9AEE5B29341A/WebPlatformInstaller_x64_en-US.msi" `
        -OutFile $fileDownloaded -UseBasicParsing
}
Start-Process "msiexec" -ArgumentList '/i', "$($fileDownloaded)", '/passive', '/quiet', '/norestart', '/qn' -NoNewWindow -Wait; 

Write-Output "Installing /Products:ServiceFabricRuntime_7_2_CU7"
Start-Process "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" -ArgumentList '/Install', '/Products:"ServiceFabricRuntime_7_2_CU7"', '/AcceptEULA' -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
