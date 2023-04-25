Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-pwsh.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features="$($args[5])"
Write-Output "Features=$($f_features)"
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

## install directly from github
## https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4

if ($f_featurearray.Contains("msbuildtools")) {
    $location="C:\Program Files\PowerShell\7"
    if (!(Test-Path $location\pwsh.exe -PathType leaf)) {

        $msiVersion = "7.3.4"
        $msi = "PowerShell-$($msiVersion)-win-x64.zip"
        $fileDownloaded = "$($env:TEMP)\$($msi)"
        if (!(Test-Path $fileDownloaded -PathType leaf)) {
            Invoke-WebRequest `
                -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$($msiVersion)/$($msi)" `
                -OutFile $fileDownloaded
        }
        mkdir -p "$($location)"
        Expand-Archive $fileDownloaded "$($location)" -Force
    } else {
        Write-Output "pwsh already installed"
    }
    $newPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (!$newPath.Contains("PowerShell\7")) {
        $newPath += ";$($location)"
        $newPath = [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Output "added pwsh to path"
    } else {
        Write-Output "pwsh is already in path"
    }
}


Write-Output "------------------------------------------"
Write-Output "plugin-pwsh.ps1"
Write-Output "------------------------------------------"
$True
 
