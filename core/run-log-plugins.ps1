## JAROWA AG, Industriestrasse 47, 6300 Zug
## owner: lorenz-haenggi-jarowa
## this script is used to prepare a download software and install it
## based on a plugin-mechanism
## 
## download "plugins-execute.ps1"
## download all plugins and install them
## parameters: 6 (1=1 2=2 3=3 4=4 5=5 6="feature1,feature2,...")
## featurs
## - sfstandalone
## example: powershell.exe .\run-log-plugins.ps1 1 2 3 4 5 "sfstandalone"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$filenamePlugin = "plugins-execute";
$psfilePlugin = "$($filenamePlugin).ps1";
$fileDownloadedPlugin = "$($env:TEMP)\$($psfilePlugin)"
Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/$($psfilePlugin)" `
    -OutFile $fileDownloadedPlugin -UseBasicParsing

Write-Host "Check all logs files in folder '$($env:temp)'"
. $env:TEMP\$psfilePlugin @args *>> "$($env:TEMP)\$($filenamePlugin).log"

