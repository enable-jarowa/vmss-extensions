Write-Output "------------------------------------------"
Write-Output "Custom script: install-node.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]

if ($f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" }).Contains("nodejs10")) {
    $msi = "node-v10.24.1-x64.msi"
    $fileDownloaded = "$($env:TEMP)\$($msi)"
    if (!(Test-Path $fileDownloaded -PathType leaf)) {
        Invoke-WebRequest `
            -Uri "https://nodejs.org/download/release/v10.24.1/$($msi)" `
            -OutFile $fileDownloaded
    }
    Install-Package "$($fileDownloaded)" -Force

    $newPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (!$newPath.Contains("nodejs")) {
        $newPath += ";c:\program files\nodejs"
        $newPath = [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Host "added nodejs to path"
    } else {
        Write-Host "nodejs is already in path"
    }

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
