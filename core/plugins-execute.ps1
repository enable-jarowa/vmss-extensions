Write-Output "------------------------------------------"
Write-Output "Custom script: plugins-execute.ps1"
Write-Output "------------------------------------------"

$filenamesPluginAll = @(
    ##"plugin-sf-SDK-choco",
    "plugin-sf-SDK",
    "plugin-sf-network",
    "plugin-exclude-sf-defender"
)


for ($i=0; $i -lt $filenamesPluginAll.Count; $i++) {
    $filenamePluginAll = $filenamesPluginAll[$i]
    $psfilePluginAll = "$($filenamePluginAll).ps1";
    $fileDownloadedPluginAll = "$($env:TEMP)\$($psfilePluginAll)"
    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/$($psfilePluginAll)" `
        -OutFile $fileDownloadedPluginAll -UseBasicParsing

    . $env:TEMP\$psfilePluginAll *>> "$($env:TEMP)\$($filenamePluginAll).log"

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
