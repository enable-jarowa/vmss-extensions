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

if ($f_featurearray.Contains("verdaccio")) {
    $version="node-v15.14.0-win-x86"
    $msi = "$($version).zip"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://nodejs.org/download/release/v15.14.0/node-v15.14.0-win-x86.zip" `
            -OutFile $fileDownloaded
    }
    if (!(Test-Path "c:\verdaccio\node\$($version)")) {
        ## create folder c:\verdaccio\node
        mkdir c:\verdaccio
        mkdir c:\verdaccio\node
        Expand-Archive -Path $fileDownloaded -DestinationPath c:\verdaccio\node
    }
    if (!(Test-Path "c:\verdaccio\node\current")) {
        cmd /c mklink /d c:\verdaccio\node\current c:\verdaccio\node\$version
    }

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
