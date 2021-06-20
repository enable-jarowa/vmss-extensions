  Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-sf-standalone.ps1"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]
#$f_certCN=$args[6]
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });



function FindAndReplace([string]$filePath, [string]$toReplace, [string]$newString)
{
    (Get-Content $filePath) | ForEach-Object {$_ -replace $toReplace, $newString } | Set-Content $filePath
}

function GetVmssName([bool]$useMachineName)
{
    $machineName = 'localhost';
    if ($useMachineName)
    {
        $machineName = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName;
        ## remove index no of vmss - e.g. vmssbre00000000 --> vmssbre
        $machineName = $machineName.Split("0").Trim()[0]
    }
    return $machineName;
}

function GetIpAddress() {
    return (Get-NetIPAddress -AddressFamily IPV4 | where-object { $_.PrefixOrigin -eq 'Dhcp'}).IPAddress
}
function GetCertificate($srcStore, [String] $SubjectLike) {
    return $srcStore.certificates | Where-Object { $_.Subject -like "$($SubjectLike)"}
}
function GetThumbprint($cert, [bool] $withSpaces) {
    $thumbprint = $cert.Thumbprint
    Write-Host "thumbprint=$($thumbprint)"
    if ($withSpaces) {
        $result = "";
        for ($i = 0; $i -lt $thumbprint.Length; $i++) {
            $c = $thumbprint[$i]
            if ($i -gt 0 -and $i % 2 -eq 0) {
                $result = $result + " $($c)"
            } else {
                $result = $result + "$($c)"
            }
        }
        return $result.ToLower()
    } else {
        return $thumbprint.ToLower()
    }
}
function GetCommonName($cert) {
    ##CN=admin-swiss-pool.enable.jarowa.ch, DC=dev, OU=enable, O=JAROWA AG, L=Zug, S=ZG, C=CH
    ##  --> admin-swiss-pool.enable.jarowa.ch
    ##CN=primary-sf-enable-bern-pool.switzerlandnorth.cloudapp.azure.com
    ##  --> primary-sf-enable-bern-pool.switzerlandnorth.cloudapp.azure.com
    $subject=$cert.Subject
    $cnPart = ($subject.Split(",")) | Where-Object { $_ -like "CN=*" }
    $cn = ($cnPart.Split("="))[1]
    Write-Host "$($cn)"
    return $cn
}


function PrepareClusterManifest([string]$manifestFileTemplate)
{
    $manifestFile = Join-Path -Path $env:TEMP -ChildPath 'ClusterConfig.X509.OneNode.Instance.json'
    Copy-Item $manifestFileTemplate $manifestFile -Force

    $vmssName = GetVmssName -useMachineName $True
    $ipAddress = GetIpAddress

    FindAndReplace -filePath $manifestFile -toReplace '\[vmssName\]' -newString $vmssName
    FindAndReplace -filePath $manifestFile -toReplace '\[IpAddress\]' -newString $ipAddress

    $drive = "S:"
    if ($null -eq (Get-PSDrive S -ErrorAction ignore)) {
        $drive = "C:"
    }
    FindAndReplace -filePath $manifestFile -toReplace '\[SF-log-root-drive\]' -newString $drive
    FindAndReplace -filePath $manifestFile -toReplace '\[SF-data-root-drive\]' -newString $drive
    FindAndReplace -filePath $manifestFile -toReplace '\[SF-diag-root-drive\]' -newString $drive
    

    $srcStoreScope = 'LocalMachine'
    $srcStoreName = 'My'
    $srcStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $srcStoreName, $srcStoreScope
    $srcStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

    $primary = GetCertificate -srcStore $srcStore -SubjectLike "CN=primary-*"
    Write-Host "$($primary.Subject)"
    $secondary = GetCertificate -srcStore $srcStore -SubjectLike "CN=secondary-*"
    Write-Host "$($secondary.Subject)"
    $proxy = GetCertificate -srcStore $srcStore -SubjectLike "CN=proxy-*"
    Write-Host "$($proxy.Subject)"
    $admin = GetCertificate -srcStore $srcStore -SubjectLike "CN=admin-*.azure.com"
    Write-Host "$($admin.Subject)"
    $adminContinent = GetCertificate -srcStore $srcStore -SubjectLike "CN=admin-*.enable.*"
       Write-Host "$($adminContinent.Subject)"
 
    FindAndReplace -filePath $manifestFile -toReplace '\[primary-Thumbprint\]' -newString (GetThumbprint -cert $primary -withSpaces $True)
    FindAndReplace -filePath $manifestFile -toReplace '\[secondary-Thumbprint\]' -newString (GetThumbprint -cert $secondary -withSpaces $True)
    FindAndReplace -filePath $manifestFile -toReplace '\[proxy-Thumbprint\]' -newString (GetThumbprint -cert $proxy -withSpaces $True)
    
    FindAndReplace -filePath $manifestFile -toReplace '\[admin-Thumbprint\]' -newString (GetThumbprint -cert $admin -withSpaces $True)
    FindAndReplace -filePath $manifestFile -toReplace '\[admin-continent-Thumbprint\]' -newString (GetThumbprint -cert $adminContinent -withSpaces $True)
    FindAndReplace -filePath $manifestFile -toReplace '\[admin-CertificateCommonName\]' -newString (GetCommonName -cert $admin)
    FindAndReplace -filePath $manifestFile -toReplace '\[admin-continent-CertificateCommonName\]' -newString (GetCommonName -cert $adminContinent)

    $srcStore.Close()

    return $manifestFile
}



#Write-Output "Features=$($f_features)"
#Write-Output "CN=$($f_certCN)"
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

    # for demo
    #. $env:TEMP\Microsoft.Azure.ServiceFabric.WindowsServer.7.2.413.9590\CreateServiceFabricCluster.ps1 -ClusterConfigFilePath "$($env:TEMP)\ClusterConfig.X509.OneNode.json" -AcceptEULA 

    $newManifestFile = PrepareClusterManifest -manifestFileTemplate "$($env:TEMP)\ClusterConfig.X509.OneNode-template.json"
    Write-Output "Result manifest: $($newManifestFile)"

    . $env:TEMP\$versionFolder\CreateServiceFabricCluster.ps1 -ClusterConfigFilePath "$($newManifestFile)" -AcceptEULA *>> "$($env:TEMP)\plugin-sf-standalone-CreateServiceFabricCluster.log"

} else {
    Write-Output "SF standalone cluster is not installed"
}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
 
 
