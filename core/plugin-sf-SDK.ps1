Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-SDK.ps1"
Write-Output "------------------------------------------"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Scope CurrentUser 
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Scope LocalMachine 
$logpath="C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
if (!(Test-Path $logpath)) {
    mkdir "C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
}

$msi = "WebPlatformInstaller_x64_en-US.msi"
$fileDownloaded = "$($env:TEMP)\$($msi)"
if (!(Test-Path $fileDownloaded -PathType leaf)) {
    Invoke-WebRequest `
        -Uri "https://download.microsoft.com/download/8/4/9/849DBCF2-DFD9-49F5-9A19-9AEE5B29341A/WebPlatformInstaller_x64_en-US.msi" `
        -OutFile $fileDownloaded -UseBasicParsing
}
Start-Process "msiexec" -ArgumentList '/i', "$($fileDownloaded)", '/passive', '/quiet', '/norestart', '/qn' -NoNewWindow -Wait; 


$testToRemove = "C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code\CleanFabric.ps1"
$fileDownloaded = "$($env:TEMP)\$($msi)"
if (Test-Path $testToRemove -PathType leaf) {
    $sdkFound = Get-WmiObject -class win32_product -Filter "Name like '%Service Fabric%SDK%'"
    if ($null -ne $sdkFound) {
        Write-Host "Uninstall SDK - $($sdkFound.Name)"
        $sdkFound.Uninstall()
        Write-Host "Sleep until deinstalled 30s"
        Sleep 30
    }
    powershell.exe -File "C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code\CleanFabric.ps1"

}


Write-Output "Installing /Products:MicrosoftAzure-ServiceFabric-CoreSDK"
Start-Process "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" -ArgumentList '/Install', '/Products:"MicrosoftAzure-ServiceFabric-CoreSDK"', '/AcceptEULA', "/Log:$($env:TEMP)\WebPICMD-install-service-fabric-sdk.log" -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
