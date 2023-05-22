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
    $location="C:\Program Files\java"
    $msiVersion = "20"
    $msiArchitecture = "x64"

    if (!(Test-Path $location\jdk\bin\java.exe -PathType leaf)) {
        $msi = "jdk-$($msiVersion)_windows-$($msiArchitecture)_bin.zip"
        $fileDownloaded = "$($env:TEMP)\$($msi)"
        if (!(Test-Path $fileDownloaded -PathType leaf)) {
            Write-Output "https://download.oracle.com/java/$($msiVersion)/latest/$($msi)"
            Invoke-WebRequest `
                -Uri "https://download.oracle.com/java/$($msiVersion)/latest/$($msi)" `
                -OutFile $fileDownloaded
        }
        mkdir  -p "$($location)" -ErrorAction Ignore
        Write-Output "expand $fileDownloaded into $($location)"
        Expand-Archive $fileDownloaded "$($location)" -Force
        $installedFolder=(Get-ChildItem -Path "C:\Program Files\java").Name
        Rename-Item -Path "$($location)\$($installedFolder)" -NewName "jdk"

    } else {
        Write-Output "java already installed"
    }
    $newPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (!$newPath.Contains("java")) {
        $newPath += ";$($location)\jdk\bin"
        $newPath = [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Output "added java jdk to path"
    } else {
        Write-Output "java jdk is already in path"
    }

    $newPath = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
    if (!$newPath -or !$newPath.Contains("java")) {
        $newPath = "$($location)\jdk"
        $newPath = [Environment]::SetEnvironmentVariable("JAVA_HOME", $newPath, "Machine")
        Write-Output "added java jdk to JAVA_HOME"
    } else {
        Write-Output "java jdk is already in JAVA_HOME"
    }

    $newPath = [Environment]::GetEnvironmentVariable("JAVA_HOME_$($msiVersion)_$($msiArchitecture)", "Machine")
    if (!$newPath -or !$newPath.Contains("java")) {
        $newPath = "$($location)\jdk"
        $newPath = [Environment]::SetEnvironmentVariable("JAVA_HOME_$($msiVersion)_$($msiArchitecture)", $newPath, "Machine")
        Write-Output "added java jdk to JAVA_HOME_$($msiVersion)_$($msiArchitecture)"
    } else {
        Write-Output "java jdk is already in JAVA_HOME_$($msiVersion)_$($msiArchitecture)"
    }

}


Write-Output "------------------------------------------"
Write-Output "plugin-pwsh.ps1"
Write-Output "------------------------------------------"
$True
 
 
