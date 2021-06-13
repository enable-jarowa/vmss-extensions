Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-standalone.ps1"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]
$f_certCN=$args[6]
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

Write-Output "Features=$($f_features)"
Write-Output "CN=$($f_certCN)"
if ($f_featurearray.Contains("sfstandalone")) {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser 

    # installation docs: https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-cluster-creation-for-windows-server
    # List of all SF cabs - https://docs.microsoft.com/en-us/samples/azure-samples/service-fabric-dotnet-standalone-cluster-configuration/service-fabric-standalone-cluster-configuration/
    $versions = @{
       "v7.2.413.9590" = "https://download.microsoft.com/download/8/3/6/836E3E99-A300-4714-8278-96BC3E8B5528/7.2.413.9590/Microsoft.Azure.ServiceFabric.WindowsServer.7.2.413.9590.zip";
       "v8.0.521.9590" = "https://download.microsoft.com/download/8/3/6/836E3E99-A300-4714-8278-96BC3E8B5528/8.0.521.9590/Microsoft.Azure.ServiceFabric.WindowsServer.8.0.521.9590.zip";
    }
    $version = "7.2.413.9590"
    $versionKey = "v$($version)"
    $versionFolder = "Microsoft.Azure.ServiceFabric.WindowsServer.$($version)"
    $msi = "$($versionFolder).zip"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "$($versions[$versionKey])" `
            -OutFile $fileDownloaded -UseBasicParsing
    }

    $logpath="$($env:TEMP)\$($versionFolder)"
    if (!(Test-Path $logpath)) {
        mkdir "$($env:TEMP)\$($versionFolder)"
        Expand-Archive -LiteralPath "$($env:TEMP)\$($msi)" -DestinationPath "$($env:TEMP)\$($versionFolder)"
    } else {
         Write-Output "SF standalone cluster already installed $($versionFolder)"
    }

    . $env:TEMP\$versionFolder\CreateServiceFabricCluster.ps1 -ClusterConfigFilePath "$($env:TEMP)\ClusterConfig.X509.OneNode.json" -AcceptEULA *>> "$($env:TEMP)\EnableLocalSecureCluster.log"

} else {
    Write-Output "SF standalone cluster is not installed"
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
