 Write-Output "------------------------------------------"
Write-Output "Custom script: install-dotnet-sdk.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features="$($args[5])"
Write-Host "Features=$($f_features)"
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

## https://silentinstallhq.com/visual-studio-build-tools-2019-silent-install-how-to-guide/
## use additional parameters : https://github.com/MicrosoftDocs/visualstudio-docs/blob/master/docs/install/workload-and-component-ids.md
## documented workload IDs: https://github.com/MicrosoftDocs/visualstudio-docs/blob/master/docs/install/includes/vs-2019/workload-component-id-vs-build-tools.md
## search for MSBuild
## install silently
if ($f_featurearray.Contains("msbuildtools")) {

    #$installedTools=((gp HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match "Visual Studio Build Tools").Count
    $installedTools=0

    if ($installedTools -eq 0) { 
        $msi = "vs_BuildTools.exe"
        $fileDownloaded = "$($env:TEMP)\$($msi)"
        if (!(Test-Path $fileDownloaded -PathType leaf)) {
            Invoke-WebRequest `
                -Uri "https://aka.ms/vs/16/release/$($msi)" `
                -OutFile $fileDownloaded
        }

        $location="$($env:temp)\vs_BuildTools"
        $installationDoneFile="vs_installer.version.json"
        Remove-Item -path "$($location)\*" -include $installationDoneFile -Force -ErrorAction SilentlyContinue

        & "$($env:temp)\vs_BuildTools.exe" --layout "$($location)" --lang En-us --add Microsoft.VisualStudio.Workload.MSBuildTools Microsoft.VisualStudio.Workload.NetCoreBuildTools Microsoft.VisualStudio.Workload.AzureBuildTools --includeRecommended --quiet --wait --norestart

        $fileToCheck="$($location)\$($installationDoneFile)"
        do{
            Write-Host "Wait 10s - for $($installationDoneFile)"
            Start-Sleep 10
        }
        until (Test-Path $fileToCheck -PathType leaf)

        ## this process runs async - we need to check for Layout
        & "$($location)\vs_setup.exe" --nocache --wait --noUpdateInstaller --noWeb --add Microsoft.VisualStudio.Workload.MSBuildTools Microsoft.VisualStudio.Workload.NetCoreBuildTools Microsoft.VisualStudio.Workload.AzureBuildTools --includeRecommended --quiet --norestart
    } else {
        Write-Host "Visual Studio Build Tools already installed"
    }


}


Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
 
