Write-Host "----------------------------------------------------------"
Write-Host "$(Get-Date) - Start prepare script in location '$($PSScriptRoot)'"
Write-Host "----------------------------------------------------------"
$allargs = $args
Write-Host "Args: $($args)"
function DownloadAndSaveScript([String]$scriptUrl, [String]$scriptName, [String] $folderName) {
    $scriptFullName = "$($folderName)\$($scriptName)"

    Write-Host "$(Get-Date) - download from    : $($scriptUrl)"
    Write-Host "$(Get-Date) - script name      : $($scriptName)"
    Write-Host "$(Get-Date) - folder name      : $($folderName)"
    Write-Host "$(Get-Date) - script full name : $($scriptFullName)"

    mkdir $folderName -ea Ignore
    cd $folderName
    Write-Host "$(Get-Date) - changed to folder : $($folderName)"

    Write-Host "$(Get-Date) - start downloading from '$($scriptUrl)'"
    (Invoke-WebRequest -UseBasicParsing -Uri "$($scriptUrl)").Content | Out-File -FilePath "$($scriptFullName)"
    Write-Host "$(Get-Date) - successfully saved to '$($scriptFullName)'"

    Write-Host "$(Get-Date) - start powershell with command: 'powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -file $($scriptFullName)'"
    powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -file "$($scriptFullName)" $allargs
    Write-Host "$(Get-Date) - executed"
}

DownloadAndSaveScript "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/hello/hello-vmss.ps1" `
    "hello-vmss.ps1" `
    "y:\customScripts"

