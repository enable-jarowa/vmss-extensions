Write-Output "------------------------------------------"
Write-Output "Custom script: install-verdaccio.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

## https://verdaccio.org/docs/en/windows using Using WinSW
## https://github.com/winsw/winsw
if ($f_featurearray.Contains("verdaccio_NOTUSED")) {
    $version="node-v14.17.0-win-x64"
    $msi = "$($version).zip"

    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://nodejs.org/dist/v14.17.0/node-v14.17.0-win-x64.zip" `
            -OutFile $fileDownloaded
    }
    ## create folder c:\verdaccio\node
    mkdir c:\verdaccio
    mkdir c:\verdaccio\app
    mkdir c:\verdaccio\node

    $datadrive="S"
    #$datadrive="C"
    mkdir "$($datadrive):\verdaccio"
    mkdir "$($datadrive):\verdaccio\app"
    mkdir "$($datadrive):\verdaccio\app\logs"
    mkdir "$($datadrive):\verdaccio\app\storage"
    if (!(Test-Path "c:\verdaccio\node\$($version)")) {
        Expand-Archive -Path $fileDownloaded -DestinationPath c:\verdaccio\node
    }
    if (!(Test-Path "c:\verdaccio\node\current")) {
        cmd /c mklink /d c:\verdaccio\node\current c:\verdaccio\node\$version
    }
    cd c:\verdaccio\app
    C:\verdaccio\node\current\npm.cmd set registry https://registry.npmjs.org/
    C:\verdaccio\node\current\npm.cmd install verdaccio -s

    $msi = "verdaccio-winsw.exe"
    $fileDownloaded = "c:\verdaccio\app\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://github.com/winsw/winsw/releases/download/v2.11.0/WinSW-x64.exe" `
            -OutFile $fileDownloaded
    }
    copy $PSScriptRoot\verdaccio-winsw.xml c:\verdaccio\app
    copy $PSScriptRoot\verdaccio-config.yaml c:\verdaccio\app

    cmd /c .\verdaccio-winsw.exe stop
    cmd /c .\verdaccio-winsw.exe uninstall
    cmd /c .\verdaccio-winsw.exe install
    cmd /c .\verdaccio-winsw.exe start

    C:\verdaccio\node\current\npm.cmd set registry http://localhost:4873/

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
