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
Write-Output "Features=$($f_features)"
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

        ## https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019
        Write-Output "Start vs_BuildTools.exe to save installations offline"

        Start-Process -Wait "$($env:temp)\vs_BuildTools.exe" -ArgumentList @("--layout", "$($location)", "--lang", "En-us", "--add", "Microsoft.VisualStudio.Workload.MSBuildTools", "--add", "Microsoft.VisualStudio.Workload.NetCoreBuildTools", "-add", "Microsoft.VisualStudio.Component.VSSDKBuildTools", "-add", "Microsoft.VisualStudio.Workload.WebBuildTools", "--includeRecommended", "--passive", "--wait", "--norestart")

        Write-Output "Start vs_setup.exe to install ms build tools and friends - takes a few minutes"
        Start-Process -Wait "$($location)\vs_setup.exe" -ArgumentList @("--nocache", "--wait", "--noUpdateInstaller", "--noWeb", "--add", "Microsoft.VisualStudio.Workload.MSBuildTools", "--add", "Microsoft.VisualStudio.Workload.NetCoreBuildTools", "-add", "Microsoft.VisualStudio.Component.VSSDKBuildTools", "-add", "Microsoft.VisualStudio.Workload.WebBuildTools", "--includeRecommended", "--passive", "--norestart")

        Write-Output "installation done"

    } else {
        Write-Output "Visual Studio Build Tools already installed"
    }


}


Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
 
