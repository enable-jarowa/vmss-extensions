Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-SDK.ps1"
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
    $logpath="C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
    if (!(Test-Path $logpath)) {
        mkdir "C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\Web Platform Installer\logs\install\"
    }
    if (Get-LocalUser -Name master -ErrorAction Ignore) {
        Get-LocalUser -Name master | Set-LocalUser -PasswordNeverExpires $True
    }
    $msi = "WebPlatformInstaller_x64_en-US.msi"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://download.microsoft.com/download/8/4/9/849DBCF2-DFD9-49F5-9A19-9AEE5B29341A/WebPlatformInstaller_x64_en-US.msi" `
            -OutFile $fileDownloaded -UseBasicParsing
    }
    Start-Process "msiexec" -ArgumentList '/i', "$($fileDownloaded)", '/passive', '/quiet', '/norestart', '/qn' -NoNewWindow -Wait; 


    # https://stackoverflow.com/questions/29723429/chef-webpi-cookbook-fails-install-in-azure
    # webpicmd installer has some issues with writing log files to app settings
    # only hack described above in link

    Write-Output "Reset LocalApp Folder to TEMP"
    Start-Process "$($env:windir)\regedit.exe" -ArgumentList "/s", "$($env:TEMP)\plugin-sf-SDK-temp.reg"


    $testToRemove = "C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code\CleanFabric.ps1"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (Test-Path $testToRemove -PathType leaf) {
        $sdkFound = Get-WmiObject -class win32_product -Filter "Name like '%Service Fabric%SDK%'"
        if ($null -ne $sdkFound) {
            Write-Host "Uninstall SDK - $($sdkFound.Name)"
            $sdkFound.Uninstall()
            Write-Host "Sleep until deinstalled 30s"
            Start-Sleep 30
        }
        powershell.exe -File "C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code\CleanFabric.ps1"

    }

    # sleep just to be sure that the temp folder is really set
    Start-Sleep -Seconds 10
    Write-Output "Installing /Products:MicrosoftAzure-ServiceFabric-CoreSDK"
    Start-Process "$($env:programfiles)\microsoft\web platform installer\WebPICMD.exe" -ArgumentList '/Install', '/Products:"MicrosoftAzure-ServiceFabric-CoreSDK"', '/AcceptEULA', "/Log:$($env:TEMP)\WebPICMD-install-service-fabric-sdk.log" -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\WebPICMD.log"  -RedirectStandardError "$($env:TEMP)\WebPICMD.error.log" 

    ## Write-Output "Reset LocalApp Folder to ORIG"
    ## Start-Process "$($env:windir)\regedit.exe" -ArgumentList "/s", "$($env:TEMP)\plugin-sf-SDK-orig.reg"
} else {
    Write-Output "SFSDK not installed"
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
