Write-Output "------------------------------------------"
Write-Output "Custom script: plugins-execute.ps1"
Write-Output "------------------------------------------"

$filenames = @(
    "plugin-sf-network",
    "plugin-exclude-sf-defender"
)


for ($i=0; $i -lt $filenames.Count; $i++) {
    $filename = $filenames[$i]
    $psfile = "$($filename).ps1";
    $fileDownloaded = "$($env:TEMP)\$($psfile)"
    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/$($psfile)" `
        -OutFile $fileDownloaded -UseBasicParsing

    . $env:TEMP\$psfile >> "$($env:TEMP)\$($filename).log"

}

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
