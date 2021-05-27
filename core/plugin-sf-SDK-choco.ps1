Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-SDK-choco.ps1"
Write-Output "------------------------------------------"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 
$logpath="C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
if (!(Test-Path $logpath)) {
    mkdir "C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
}


Write-Output "Installing /webpicmd"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 
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


Write-Output "Installing /choco"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

powershell.exe -NoProfile Get-ExecutionPolicy -Scope CurrentUser

Write-Output "Installing /ServiceFabricMeshSDK_4_2_CU7"
choco install ServiceFabricMeshSDK_4_2_CU7  --source webpi  --confirm

Write-Output "Installed /ServiceFabricMeshSDK_4_2_CU7"

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
