
<#
.SYNOPSIS
    Generate P2S VPN client certificate.
.DESCRIPTION
    Generate P2S VPN client certificate. Export avaliable only from admin user.

#>
[CmdletBinding()]
param (
    # Password protection for certificate export
    [Parameter(Mandatory = $true)]
    [SecureString]
    $password,
    # User email
    [Parameter(Mandatory = $true)]
    [string]
    $email,
    # Type of VPN to connect
    [Parameter(Mandatory = $true)]
    [string]
    $zone
)

function GenerateCert {
    param (
        $email, $zone
    )
    [string]$rootThumbprint = (Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Subject -like "CN=P2SRootCertEnable$zone" }).Thumbprint    
    $rootCert = Get-ChildItem -Path "Cert:\CurrentUser\My\$rootThumbprint"
    $clientCert = New-SelfSignedCertificate -Type Custom -DnsName "$email" -KeySpec Signature `
        -Subject "CN=$email" -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 -KeyLength 2048 `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -Signer $rootCert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
    return $clientCert.Thumbprint
}

$clientThumb = GenerateCert -email $email -zone $zone
Get-ChildItem -Path cert:\CurrentUser\my\$clientThumb | Export-PfxCertificate -FilePath C:\P2SRootClientEnable$zone.pfx -Password $password
