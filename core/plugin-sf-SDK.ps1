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
    if (Get-LocalUser -Name master -ErrorAction Ignore) {
        Get-LocalUser -Name master | Set-LocalUser -PasswordNeverExpires $True
    }

    # installation docs: https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-cluster-creation-for-windows-server
    # all releases SF     - https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-versions
    # List of all SF cabs - https://docs.microsoft.com/en-us/samples/azure-samples/service-fabric-dotnet-standalone-cluster-configuration/service-fabric-standalone-cluster-configuration/
    # List of SF + SDK    - https://learn.microsoft.com/en-us/azure/service-fabric/service-fabric-get-started#install-the-sdk-and-tools
    #$version = "7.2.413.9590"
    #$version = "8.0.521.9590"
    #$version = "9.0.1017.9590"
    #$version = "9.0.1048.9590"
    #$version = "9.1.1436.9590"
    $version = "10.1.1951.9590"
    $sdkversion = "7.1.1951"

    # https://stackoverflow.com/questions/29723429/chef-webpi-cookbook-fails-install-in-azure
    # webpicmd installer has some issues with writing log files to app settings
    # only hack described above in link

    Write-Output "Reset LocalApp Folder to TEMP"
    Start-Process "$($env:windir)\regedit.exe" -ArgumentList "/s", "$($env:TEMP)\plugin-sf-SDK-temp.reg"

    $testToRemove = "C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code\CleanFabric.ps1"
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
    $msiname = "MicrosoftServiceFabric.$($version)"
    Write-Output "Installing /Products:$($msiname)"
    $msi = "$($msiname).exe"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://download.microsoft.com/download/b/8/a/b8a2fb98-0ec1-41e5-be98-9d8b5abf7856/$($msi)" `
            -OutFile $fileDownloaded -UseBasicParsing
    }
    Start-Sleep -Seconds 10
    Start-Process "$($env:TEMP)\$($msi)" -ArgumentList '/AcceptEULA', "/force", "/quiet" -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\$($msiname).log"  -RedirectStandardError "$($env:TEMP)\$($msiname).error.log" 

    $msiname = "MicrosoftServiceFabricSDK.$($sdkversion)"
    Write-Output "Installing /Products:$($msiname)"
    $msi = "$($msiname).msi"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://download.microsoft.com/download/b/8/a/b8a2fb98-0ec1-41e5-be98-9d8b5abf7856/$($msi)" `
            -OutFile $fileDownloaded -UseBasicParsing
    }
    Start-Sleep -Seconds 10
    & "$($env:TEMP)\$($msi)" /qn /norestart /quiet /log "$($env:TEMP)\$($msiname)-install.log"

    Start-Sleep -Seconds 20 

    ## Write-Output "Reset LocalApp Folder to ORIG"
    ## Start-Process "$($env:windir)\regedit.exe" -ArgumentList "/s", "$($env:TEMP)\plugin-sf-SDK-orig.reg"
} else {
    Write-Output "SFSDK not installed"
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
