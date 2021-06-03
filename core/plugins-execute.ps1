Write-Output "------------------------------------------"
Write-Output "Custom script: plugins-execute.ps1"
Write-Output "------------------------------------------"

$filenamesPluginAll = @(
    ##"plugin-sf-SDK-choco",
    "plugin-sf-SDK-orig.reg",
    "plugin-sf-SDK-temp.reg",
    "plugin-sf-SDK.ps1",
    "plugin-sf-network.ps1",
    "plugin-exclude-sf-defender.ps1"
)


for ($i=0; $i -lt $filenamesPluginAll.Count; $i++) {
    $filenamePluginAll = $filenamesPluginAll[$i]
    $psfilePluginAll = "$($filenamePluginAll)";
    $fileDownloadedPluginAll = "$($env:TEMP)\$($psfilePluginAll)"
    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/$($psfilePluginAll)" `
        -OutFile $fileDownloadedPluginAll -UseBasicParsing

    if ($psfilePluginAll.Contains(".ps1")) {
        . $env:TEMP\$psfilePluginAll *>> "$($env:TEMP)\$($filenamePluginAll).log"
    }

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
