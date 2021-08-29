function GetCertificate($srcStore, [String] $SubjectLike) {
    return $srcStore.certificates | Where-Object { $_.Subject -like "$($SubjectLike)"}
}
function GetThumbprint($cert, [bool] $withSpaces) {
    $thumbprint = $cert.Thumbprint
    Write-Host "thumbprint=$($thumbprint)"
    if ($withSpaces) {
        $result = "";
        for ($thi = 0; $thi -lt $thumbprint.Length; $thi+) {
            $c = $thumbprint[$i]
            if ($thi -gt 0 -and $thi % 2 -eq 0) {
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

    $srcStoreScope = 'LocalMachine'
    $srcStoreName = 'My'
    $srcStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $srcStoreName, $srcStoreScope
    $srcStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

    $secondary = GetCertificate -srcStore $srcStore -SubjectLike "CN=secondary-*"
    Write-Host "$($secondary.Subject)"
    $adminContinent = GetCertificate -srcStore $srcStore -SubjectLike "CN=admin-*.enable.*"
       Write-Host "$($adminContinent.Subject)"
 
Write-Host "Connection to SF cluster:"
Write-Host "- using installed LocalMachine certs (secondary, admin)"
Write-Host "----------------------------------------------------------"

$env:path = $env:path+";C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code"

$hname = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
$ClusterName= "$($hname):19000"
Write-Host "Hostname = $($ClusterName)"

Write-Host "Cluster Thumbprint:"
$CertThumbprint = (GetThumbprint -cert $secondary -withSpaces $True)
Write-Host "Client Certificate Thumbprint:"
$AdminThumbprint = (GetThumbprint -cert $adminContinent -withSpaces $True)

Connect-serviceFabricCluster -ConnectionEndpoint $ClusterName -KeepAliveIntervalInSec 10 `
    -X509Credential `
    -ServerCertThumbprint $CertThumbprint  `
    -FindType FindByThumbprint `
    -FindValue $CertThumbprint `
    -StoreLocation LocalMachine `
    -StoreName My
	
	