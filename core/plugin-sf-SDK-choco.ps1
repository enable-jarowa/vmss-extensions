Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-SDK-choco.ps1"
Write-Output "------------------------------------------"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 
$logpath="C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
if (!(Test-Path $logpath)) {
    mkdir "C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
}

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
