## To connect using Powershell, open an a new powershell window and connect using Connect-ServiceFabricCluster command (without any arguments).
## To connect using Service Fabric Explorer, run ServiceFabricExplorer and connect using Local/OneBox Cluster.
## To manage using Service Fabric Local Cluster Manager (system tray app), run ServiceFabricLocalClusterManager.exe
#=================================================
#
#Write-Host $outputString -ForegroundColor Green
#=======
param
(
    [Parameter(Mandatory=$False, Position=1)]
    [string] $jsonFileTemplate,
    #[string] $jsonFileTemplate = 'C:\\Program Files\\Microsoft SDKs\\Service Fabric\\ClusterSetup\\Secure\\OneNode\\ClusterManifestTemplate.json',

    [Parameter(Mandatory=$False, Position=3)]
    [switch] $AsSecureCluster = $True,
    
    [Parameter(Mandatory=$False, Position=4)]
    [switch] $UseMachineName,

    [Parameter(Mandatory=$False, Position=5)]
    [switch] $CreateOneNodeCluster = $True,

    [Parameter(Mandatory=$False, Position=6)]
    [switch] $Auto
)


function FindAndReplace([string]$filePath, [string]$toReplace, [string]$newString)
{
    (Get-Content $filePath) | ForEach-Object {$_ -replace $toReplace, $newString } | Set-Content $filePath
}

function ConstructManifestFileTemplate([string]$jsonTemplate)
{
	$runtimeInstallPath = (Get-ItemProperty 'HKLM:\Software\Microsoft\Service Fabric').FabricCodePath
    $deploymentmangager= Join-Path -Path $runtimeInstallPath -ChildPath 'Microsoft.ServiceFabric.DeploymentManager.dll'

	[Reflection.Assembly]::LoadFrom($deploymentmangager) > $null
	$manifestFileTemplate = [Microsoft.ServiceFabric.DeploymentManager.Common.StandaloneUtility]::GetClusterManifestFromJsonConfig($jsonTemplate, '', '')

	return $manifestFileTemplate
}

function GetMachineName([bool]$useMachineName)
{
    $machineName = 'localhost';

    if ($useMachineName)
    {
        $machineName = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName;
    }

    return $machineName;
}

function SetupImageStore([string]$clusterDataRoot, [bool]$useMachineName)
{    
    $ImageStoreConnectionString = 'fabric:ImageStore';
    
    if(!$useMachineName)
    {    
    $ImageStoreShare = Join-Path -Path $clusterDataRoot -ChildPath 'ImageStoreShare'

    New-Item $ImageStoreShare -type directory -force > $null
    AddWindowsFabricAcl $ImageStoreShare
    
    $ImageStoreConnectionString = 'file:' + $ImageStoreShare
    }

    return $ImageStoreConnectionString
}

function PrepareClusterManifest([string]$manifestFileTemplate,
                                [string]$imageStoreConnectionString,
                                [string]$machineName,
                                [bool]$isSecure = $False)
{
    $manifestFile = Join-Path -Path $env:TEMP -ChildPath 'computername-Server-ScaleMin.xml'

    Copy-Item $manifestFileTemplate $manifestFile -Force
    Write-Host "Manifestfile = $($manifestFile)"

    FindAndReplace -filePath $manifestFile -toReplace 'ComputerFullName' -newString $machineName
    FindAndReplace -filePath $manifestFile -toReplace 'ImageStoreConnectionStringPlaceHolder' -newString $imageStoreConnectionString

    if ($isSecure)
    {
        
        $srcStoreScope = 'LocalMachine'
        $srcStoreName = 'My'

        $srcStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $srcStoreName, $srcStoreScope
        $srcStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

        $certs = $srcStore.certificates -match 'CN=sf-enable-'
        # the primary is the first cerrt that is created - issue. name of certs are duplicates :-(
        $cert = ($certs | Sort-Object { $_.NotBefore.Ticks })[0]

        FindAndReplace -filePath $manifestFile -toReplace 'ServiceFabricDevClusterCertParameter' -newString $cert.Thumbprint.ToString()

        $srcStore.Close()
    }

    Test-ServiceFabricClusterManifest -ClusterManifestPath $manifestFile > $null
    if (!$?)
    {
        Write-Error 'Could not validate cluster manifest '+$manifestFile
        throw
    }

    return $manifestFile
}

function InstantiateJsonFromTemplate([string]$jsonFileTemplate,
                                     [string]$clusterDataRoot,                             
                                     [string]$clusterLogRoot)
{

	$configJson = Get-Content $jsonFileTemplate -Raw | ConvertFrom-Json
    $setupSetting = $configJson.properties.fabricSettings | where {$_.Name -eq 'Setup'}
    if($setupSetting -eq $null){
        $setupSetting = New-Object PSObject -Property @{
    		    name='Setup'
    		    parameters = @()
        }
        $configJson.properties.fabricSettings += $setupSetting
    }
    
    $dataroot = $setupSetting.parameters | where {$_.Name -eq 'FabricDataRoot'}
    if($dataroot -eq $null) {
        $parameter = New-Object PSObject -Property @{
    		name='FabricDataRoot'
    		value=$clusterDataRoot
        }
        $setupSetting.parameters += $parameter
    } else {
        $dataroot.value = $clusterDataRoot
    }
    
    $logroot = $setupSetting.parameters | where {$_.Name -eq 'FabricLogRoot'}
    if($logroot -eq $null) {
        $parameter = New-Object PSObject -Property @{
    		name='FabricLogRoot'
    		value=$clusterLogRoot
        }
        $setupSetting.parameters += $parameter
    } else {
        $logroot.value = $clusterLogRoot
    }
    
    $parameter = New-Object PSObject -Property @{
    		name='IsDevCluster'
    		value='true'
    }
    $setupSetting.parameters += $parameter

	$jsonObject = ConvertTo-Json $configJson -Depth 10
	$temporaryConfigPath = [System.IO.Path]::GetTempFileName() + '.json'
	$jsonObject > $temporaryConfigPath

    Write-Host 'The generated json path is '+$temporaryConfigPath

	return $temporaryConfigPath
}


function DeployNodeConfiguration([string]$clusterDataRoot, 
                                 [string]$clusterLogRoot, 
                                 [bool]$isSecure = $False,
                                 [bool]$useMachineName = $False,
								 [bool]$createOneNodeCluster = $False,
								 [string]$jsonFileTemplate )
{
	$jsonTemplate = InstantiateJsonFromTemplate -jsonFileTemplate $jsonFileTemplate -clusterDataRoot $clusterDataRoot -clusterLogRoot $clusterLogRoot
    $manifestFileTemplate = ConstructManifestFileTemplate -jsonTemplate $jsonTemplate
    $imageStoreConnectionString = SetupImageStore -clusterDataRoot $clusterDataRoot -useMachineName $useMachineName
    $machineName = GetMachineName -useMachineName $useMachineName

    $manifestFile = PrepareClusterManifest $manifestFileTemplate $imageStoreConnectionString $machineName $isSecure

    # Stop Fabric Host Service (if running just in case)
    Stop-Service FabricHostSvc -WarningAction SilentlyContinue

    New-ServiceFabricNodeConfiguration -ClusterManifest $manifestFile -FabricDataRoot $clusterDataRoot -FabricLogRoot $clusterLogRoot -RunFabricHostServiceAsManual
    if (!$?) 
    { 
        Write-Error 'Could not create Node configuration for '+$manifestFile
        throw
    }

    if($createOneNodeCluster)
    {
        Set-ItemProperty 'HKLM:\Software\Microsoft\Service Fabric SDK' -Name LocalClusterNodeCount -Value 1
    }
    else
    {
        Set-ItemProperty 'HKLM:\Software\Microsoft\Service Fabric SDK' -Name LocalClusterNodeCount -Value 5
    }
}



function IsLocalClusterSetup
{
    try
    {
        if($null -eq (Get-ServiceFabricNodeConfiguration -WarningAction SilentlyContinue))
        {
            return $false;
        }

        return $true;
        
    }
    catch [System.Exception]
    {
        return $false;
    }
}

function SetupDataAndLogRoot([string]$clusterDataRoot, [string]$clusterLogRoot, [string] $jsonFileTemplate, [bool]$isAuto = $False)
{
    if([System.String]::IsNullOrWhiteSpace($clusterDataRoot)){
        $clusterDataRoot = GetClusterRootValueFromJson -jsonFileTemplate $jsonFileTemplate -name 'FabricDataRoot'
    }

    if([System.String]::IsNullOrWhiteSpace($clusterLogRoot)){
        $clusterLogRoot = GetClusterRootValueFromJson -jsonFileTemplate $jsonFileTemplate -name 'FabricLogRoot'
    }    

    $clusterDataRoot = ComputeClusterRoot -clusterRoot $clusterDataRoot -rootName 'data'
    $clusterLogRoot = ComputeClusterRoot -clusterRoot $clusterLogRoot -rootName 'log'

    Write-Host ''
    Write-Host 'Using Cluster Data Root: '+$clusterDataRoot -ForegroundColor Green
    Write-Host 'Using Cluster Log Root: '+$clusterLogRoot -ForegroundColor Green
    Write-Host ''

    if(!$isAuto)
    {
        if(!(IsDirectoryEmpty -dirPath $clusterDataRoot))
        {
            Write-Host ''
            Write-Warning 'The cluster data root ('+$clusterDataRoot'+) is not empty. All files and subfolders under it will be deleted.'
            $response = Read-Host -Prompt 'Do you want to continue [Y/N]?'
            if($response -ine 'Y') { return @($False) }
        }

        if(!(IsDirectoryEmpty -dirPath $clusterLogRoot))
        {
            Write-Host ''
            Write-Warning 'The cluster log root ('+$clusterLogRoot+') is not empty. All files and subfolders under it will be deleted.'
            $response = Read-Host -Prompt 'Do you want to continue [Y/N]?'
            if($response -ine 'Y') { return @($False) }
        }
    }

    EnsureDirectoryCleaned $clusterDataRoot
    EnsureDirectoryCleaned $clusterLogRoot
        
    return @($clusterDataRoot, $clusterLogRoot)
}

function CleanExistingCluster
{
    Write-Host 'Removing cluster configuration...'
    Remove-ServiceFabricNodeConfiguration -Force > $null    

    # Wait for fabric processes to exit.
    Get-Process Fabric -ErrorAction Ignore | Foreach-Object { $_.WaitForExit() }
    Get-Process FabricGateway -ErrorAction Ignore | Foreach-Object { $_.WaitForExit() }
    Get-Process FabricHost -ErrorAction Ignore | Foreach-Object { $_.WaitForExit() }

    # Clear out the reg key indicating the local cluster node count.
    Set-ItemProperty 'HKLM:\Software\Microsoft\Service Fabric SDK' -Name LocalClusterNodeCount -Value ''
    
    Write-Host 'Stopping all logman sessions...'
    logman stop FabricAppInfoTraces > $null
    logman stop FabricCounters > $null
    logman stop FabricLeaseLayerTraces > $null
    logman stop FabricQueryTraces > $null
    logman stop FabricTraces > $null

    $logFolder = GetFabricLogRootFromRegistry
    $dataFolder = GetFabricDataRootFromRegistry

    Write-Output 'Cleaning log and data folder...'
    RemoveFolder $logFolder  > $null
    RemoveFolder $dataFolder > $null
}


function ExitWithCode($exitcode)
{
    if($Auto.IsPresent)
    {
        $host.SetShouldExit($exitcode)        
    }

    exit
}


function StartLocalCluster
{
    # Start Service Fabric on this Node
    Write-Host 'Starting service FabricHostSvc. This may take a few minutes...'
    Start-Service FabricHostSvc -WarningAction SilentlyContinue
    if (!$?) 
    { 
        Write-Error 'Could not start FabricHostSvc'
        throw
    }
}


function TryConnectToCluster([HashTable]$connParams, [int]$waitTime)
{
    [int]$connRetryInterval = 10
    [int]$maxExpConnTime = $waitTime
    [int]$timeSpentConn = 0

    $connParams.Add('TimeoutSec', $connRetryInterval)
    $connParams.Add('WarningAction', 'SilentlyContinue')

    $IsConnSuccesfull = $False

    Write-Host ''
    Write-Host 'Waiting for Service Fabric Cluster to be ready. This may take a few minutes...'

    do
    {
        try
        {
            [void](Connect-ServiceFabricCluster @connParams)
        
            #Test the connection
            $testWarnings = @()
            $IsConnSuccesfull = (Test-ServiceFabricClusterConnection -TimeoutSec 5 -WarningAction SilentlyContinue -WarningVariable testWarnings)
            
            if (($IsConnSuccesfull -eq $True) -and ($testWarnings.Count -eq 0)) 
            { 
                Write-Host 'Local Cluster ready status: 100% completed.'
                return
            }
        }
        catch [System.Exception]
        {
            # Retry
        }

        if($timeSpentConn -ge $maxExpConnTime)
        {
            Write-Warning 'Service Fabric Cluster is taking longer than expected to connect.'
            return
        }

        # Print progress and retry
        $timeSpentConn += $connRetryInterval
        $progress = [int]($timeSpentConn * 100 / $maxExpConnTime)
        Write-Host 'Local Cluster ready status: $progress% completed.'
    }
    while($True)
}

function GetConnectionParameters([bool]$isSecure = $False, [bool]$useMachineName = $False)
{
    [HashTable]$connParams = @{}
    
    $machineName = GetMachineName -useMachineName $useMachineName
    $connectionEndpoint = [string]::Concat($machineName, ':19000')

    $connParams.Add('ConnectionEndpoint', $connectionEndpoint)

    if ($isSecure)
    {
        $connParams.Add('X509Credential', $True)
        $connParams.Add('ServerCommonName', 'ServiceFabricDevClusterCert')
        $connParams.Add('FindType', 'FindBySubjectName')
        $connParams.Add('FindValue', 'CN=ServiceFabricDevClusterCert')
        $connParams.Add('StoreLocation', 'LocalMachine')
        $connParams.Add('StoreName', 'MY')
    }

    return $connParams
}


function CheckNamingServiceReady([HashTable]$connParams, [int]$waitTime)
{
    [int]$RetryInterval = 10
    [int]$maxExpTime = $waitTime
    [int]$timeSpent = 0

    Write-Host ''
    Write-Host 'Waiting for Naming Service to be ready. This may take a few minutes...'

    [void](Connect-ServiceFabricCluster @connParams)

    do
    {
        try
        {            
            $nsPartitions = Get-ServiceFabricPartition -ServiceName 'fabric:/System/NamingService'
            $isReady = $true
    
            foreach ($partition in $nsPartitions)
            {
                if(!$partition.PartitionStatus.Equals([System.Fabric.Query.ServicePartitionStatus]::Ready))
                {
                    $isReady = $false
                    break
                }
            }

            if($isReady)
            {
                Write-Host 'Naming Service is ready now...'
                Write-Host ''
                return;
            }
        }
        catch [System.Exception]
        {
            # Retry
        }

        if($timeSpent -ge $maxExpTime)
        {
            Write-Warning 'Naming Service is taking longer than expected to be ready...'
            return
        }
        
        Start-Sleep -s $RetryInterval
        
        # Print progress and retry
        $timeSpent += $RetryInterval
        $progress = [int]($timeSpent * 100 / $maxExpTime)
        Write-Host 'Naming Service ready status: '+$progress+'% completed.'
    }
    while($true)
}

function InstallCertificates
{
	
	Write-Host 'Get self-signed certificate'
	$cert =  ( Get-ChildItem -Path cert:\LocalMachine\My\E78759685556E1519AB1F71A2B5E186B46E60087 )
	Write-Host $cert

	Write-Host 'Store serfl-signed certificate as trusted into Root and Local'
	$rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList Root, Local
	$rootStore.Open('MaxAllowed')
	$rootStore.Add($cert)
	$rootStore.Close()
	Write-Host 'Cert stored successfully'
}

trap [System.Exception]
{   
  Write-Host $_
  break
  ExitWithCode 1
}

Get-Module -ListAvailable -Refresh --quiet *>$null

# Import the cluster setup utility module
$sdkInstallPath = (Get-ItemProperty 'HKLM:\Software\Microsoft\Service Fabric SDK').FabricSDKScriptsPath
$modulePath = Join-Path -Path $sdkInstallPath -ChildPath 'ClusterSetupUtilities.psm1'
Import-Module $modulePath

EnsureAdminPrivileges 'Not running as administrator. You need to run PoweShell with administrator privileges to setup the local cluster.'

if($CreateOneNodeCluster){
	$jsonFileTemplate = 'C:\Program Files\Microsoft SDKs\Service Fabric\ClusterSetup\Secure\OneNode\ClusterManifestTemplate.json'
}else{
	$jsonFileTemplate = 'C:\Program Files\Microsoft SDKs\Service Fabric\ClusterSetup\Secure\FiveNode\ClusterManifestTemplate.json';
}

if((IsLocalClusterSetup))
{
    if(!$Auto.IsPresent)
     {
        Write-Warning 'A local Service Fabric Cluster already exists on this machine and will be removed.'
        $response = Read-Host -Prompt 'Do you want to continue [Y/N]?'
        if($response -ine 'Y') { ExitWithCode 0 }
    }
        
    CleanExistingCluster
}


$PathToClusterDataRoot = 'S:\SfDevCluster\Data'
$PathToClusterLogRoot = 'S:\SfDevCluster\Log'
$clusterRoots = SetupDataAndLogRoot -clusterDataRoot $PathToClusterDataRoot -clusterLogRoot $PathToClusterLogRoot -jsonFileTemplate $jsonFileTemplate -isAuto $Auto.IsPresent

if($clusterRoots[0] -eq $False)
{
    ExitWithCode -exitcode 0
}

$clusterDataRoot = $clusterRoots[0]
$clusterLogRoot = $clusterRoots[1]

#remove this - already done by VMSS
#InstallCertificates

DeployNodeConfiguration $clusterDataRoot $clusterLogRoot $AsSecureCluster.IsPresent $UseMachineName.IsPresent -createOneNodeCluster $CreateOneNodeCluster.IsPresent $jsonFileTemplate
Write-Host 'cool - done until here'
throw

StartLocalCluster

$connParams = GetConnectionParameters -isSecure $True -useMachineName $UseMachineName.IsPresent

TryConnectToCluster -connParams $connParams -waitTime 240
CheckNamingServiceReady -connParams $connParams -waitTime 120

$outputString = @'

Local Service Fabric Cluster created successfully.

================================================= 
## To connect using Powershell, open an a new powershell window and connect using _Connect-ServiceFabricCluster_ command (without any arguments).

## To connect using Service Fabric Explorer, run ServiceFabricExplorer and connect using Local/OneBox Cluste.

## To manage using Service Fabric Local Cluster Manager (system tray app), run ServiceFabricLocalClusterManager.exe
=================================================
'@

Write-Host $outputString -ForegroundColor Green
