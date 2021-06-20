Import-Module Az.ServiceFabric
function Usage() { 
    Write-Output "Descr: decrypts or encrypts or de-and-encrypts services fabric application file"
    Write-Output "Usage: de-en-crypted.ps1 <file-name> ['new thumbprint to encrypt'] [--NewKeyVault 'name' 'munich-prod' ]";
    Write-Output "examples:"
    Write-Output "   decrypt = de-en-crypt-sf-ps1 file.xml"
    Write-Output ""
    Write-Output "             ---> decrypts into 'file.xml.private.xml' based on LocalMachine SF thumbprint"
    Write-Output "             writes new file.xml.private.xml"
    Write-Output ""
    Write-Output "   encrypt = de-en-crypt-sf-ps1 'file.private.xml' '23425-thumbprint'"
    Write-Output ""
    Write-Output "             ---> decrypts and encrypts with new thumprint"
    Write-Output "             writes new file.xml.23425-thumbprint.xml"
    Write-Output ""
    Write-Output "   encrypt = de-en-crypt-sf-ps1 file.xml '23425-thumbprint'"
    Write-Output ""
    Write-Output "             ---> decrypts and encrypts with new thumprint"
    Write-Output "             writes new file.xml.23425-thumbprint.xml all in one"
}

if ($args.Count -lt 1 -or $args.Count -gt 5) {
    Usage
    return
}
$filePath = $args[0]
$thumbprint = $args[1]
$encryptAgain = if ([string]::IsNullOrWhiteSpace($thumbprint)) { 0 } else { 1 }
$newKeyVault = ""
$newCertSuffix = "cluster"
$hasNewKeyVault = 0
if ($args.Count -gt 2) {
    if ($thumbprint -eq "--NewKeyVault") {
        ## no thumbnail is set
        $encryptAgain = 0
        ## 3th parameter is new KeyVault
        $newKeyVault = $args[2]
        $hasNewKeyVault = 1
        $newCertSuffix = $args[3]
        $thumbprint = ""
    } elseif ($args.Count -eq 3) {
        ## number of args < 4
        Usage
        return
    } else {
        ## 4th parameter is new KeyVault
        $thumbprint = $args[1]
        $newKeyVault = $args[3]
        $newCertSuffix = $args[4]
        $hasNewKeyVault = 1
    }
}

Write-Output "encryptAgain=$($encryptAgain), thumbprint=$($thumbprint), hasNewKeyVault=$($hasNewKeyVault), vault=$($newKeyVault), suffix=$($newCertSuffix)"

$fileExists = Test-Path $filePath -PathType Leaf

if (!$fileExists) {
    Write-Output "error parameter file '$($filePath)' does not exists";
    return 
}

[xml]$sfXml = Get-Content $filePath
$parameters = $sfXml.Application.Parameters.Parameter

function GetThumbprint([string] $keyString, [string] $valueString) {
    if ($hasNewKeyVault -eq 1) {
        Write-Host "Serarch for Cert $($newKeyVault) / $($keyString)"
        $kvCert = GetKeyVaultCert $newKeyVault $keyString
        return $kvCert.Thumbprint
    } else {
        return $valueString
    }
}

function GetKeyVaultCert([String]$kvName, [String] $certName) {
    Write-Host "Serarch for Keyvault Cert $($kvName) / $($certName)"
    $kvCert = Get-AzKeyVaultCertificate -VaultName $newKeyVault -Name $keyString
    if (!$kvCert) {
        Write-Error "Cert '$($keyString)' not found in keyvault '$($newKeyVault)'"
        throw    
    }
    return $kvCert
}
function GetClusterIp([string] $keyString, [string] $valueString, [int]$network) {
    if ($hasNewKeyVault -eq 1) {
        $kvCert = GetKeyVaultCert $newKeyVault $keyString
        $cnHostName = $kvCert.Certificate.Subject
        Write-Host "cname=$($cnHostName)"
        $hostName = $cnHostName -replace "CN=", ""
        $ip = (Resolve-DnsName -Name $hostName  -DnsOnly -Type A).IPAddress
        if ($network -eq 1) {
            $ip = "$($ip)/32"
        }
        return "$($ip)"
    } else {
        return $valueString
    }
}

function Log([string]$keyString, [string]$a, [string]$b) {
    if (!($a -eq $b)) {
        Write-Host "test replace for $($keyString)='$($b)' (old=$($a))"
    }
    return $b
}
function ReplaceKeyVaultValues([string]$keyString, [string] $valueString) {
    $result = $valueString
    if ($hasNewKeyVault -eq 1) {

        switch ($keyString)
        {
            {$_ -in 'TokenSigningCertificateSource_FindValue', 'TokenSigningCertificateThumbprint'} {
                return GetThumbprint "cert-enable-tokenSigning-$($newCertSuffix)" $valueString
            }
            {$_ -in 'SamlSigningCertificateSource_FindValue', 'SamlSigningCertificateThumbprint'} {
                return GetThumbprint "cert-enable-samlSigning-$($newCertSuffix)" $valueString
            }
            'DataEnciphermentCertThumbprint' {
                if ($encryptAgain) {
                    return $thumbprint
                } else {
                    return $valueString;
                }
            }
            'AuditDB_ConnectionString' {
                return "no-sql-db"
            }
            'Environment' {
                return $newCertSuffix
            }
            'Integration_ConfigEncryptionCertificateThumbprint' {
                return GetThumbprint "cert-enable-dataEncipherment-$($newCertSuffix)" $valueString
            }
            {$_ -in 'ClusterCertThumbprint','TransportSettings_CertificateFindValue', 'TransportSettings_CertificateRemoteThumbprints', 'InternalServicesCertThumbprint'} {
                return GetThumbprint "cert-enable-primary-$($newCertSuffix)" $valueString
            }
            {$_ -in 'KnownProxyIP_1', 'KnownProxyIP_2'} {
                return GetClusterIp "cert-enable-primary-$($newCertSuffix)" $valueString 0
            }
            {$_ -in 'KnownNetworkIP_1', 'KnownNetworkIP_2'} {
                return GetClusterIp "cert-enable-primary-$($newCertSuffix)" $valueString 1
            }
            Default {
                return $result
            }
        }
        Write-Host "Replace $($keyString) = '$($newValue)'"
    }
    return $result;
}
function LoggedReplaceKeyVaultValues([string]$keyString, [string] $valueString) {
    $replaced = ReplaceKeyVaultValues $keyString $valueString
    return Log $keyString $valueString $replaced
}




foreach ($par in $parameters) {
    if (!($null -eq $par.Value) -and $par.Value.StartsWith("MII")) {
        Write-Host "parameter=$($par.Name)"
        $decryptedValue = Invoke-ServiceFabricDecryptText "$($par.Value)" -StoreLocation "LocalMachine"
        if ($encryptAgain) {
            $replacedValue = LoggedReplaceKeyVaultValues $par.Name "$($decryptedValue)"
            $encryptedValue = Invoke-ServiceFabricEncryptText "$($replacedValue)" -CertStore -CertThumbprint $thumbprint -StoreLocation "LocalMachine" -StoreName "My"
            $par.Value = "$($encryptedValue)"
        } else {
            $replacedValue = LoggedReplaceKeyVaultValues $par.Name "$($decryptedValue)"
            $par.Value = "$($replacedValue)"
            $par.SetAttribute("Private", "True");
        }
    } else {
        $decryptedValue = if ([string]::IsNullOrWhiteSpace($par.Value)) { "" } else { $par.Value }
        $replacedValue = LoggedReplaceKeyVaultValues $par.Name "$($decryptedValue)"
        if (![string]::IsNullOrWhiteSpace($par.Private) -and $par.Private -eq "True") {
            if ($encryptAgain) {
                $encryptedValue = Invoke-ServiceFabricEncryptText "$($replacedValue)" -CertStore -CertThumbprint $thumbprint -StoreLocation "LocalMachine" -StoreName "My"
                $par.Value = "$($encryptedValue)"
                $par.RemoveAttribute("Private");
            }
        } else {
            if ($null -eq $par.Value -and "$($replacedValue)" -eq "") {
                ## dont add value
            } else {
                $par.SetAttribute("Value", "$($replacedValue)")
            }
        }
    }
}
function GetNewFile([string]$filePath) {
    $exists = Test-Path $filePath -PathType Leaf
    if ($exists) {
        $i = 1
        while (Test-Path "$($filePath).$($i)" -PathType Leaf) {
            $i = $i + 1
        }
        return "$($filePath).$($i)"    
    } else {
        return $filePath
    }
}

$path = (Get-Location).Path;
$outputfile = "";
if ($encryptAgain) {
    $filePath = $filePath -replace ".private.xml", ""
    $outputfile = "$($path)\$($filePath).$($newCertSuffix).xml"
    $outputfile = GetNewFile $outputfile
    Write-Output "Write encrypted to file $($outputfile)"
} elseif ($hasNewKeyVault -eq 1) {
    $filePath = $filePath -replace ".private.xml", ""
    $outputfile = "$($path)\$($filePath).$($newCertSuffix).private.xml"
    $outputfile = GetNewFile $outputfile
    Write-Output "ATTENTION: Write decrypted to file $($outputfile)"
} else {
    $outputfile = "$($path)\$($filePath).private.xml"
    $outputfile = GetNewFile $outputfile
    Write-Output "ATTENTION: Write decrypted to file $($outputfile)"
}
$sfXml.Save($outputfile)
