Write-Host "----------------------------------------------------------"
Write-Host "Start prepare script in location '$($PSScriptRoot)'"
Write-Host "----------------------------------------------------------"

function DownloadAndSaveScript([String]$scriptUrl, [String]$scriptName, [String] $folderName) {
    $scriptFullName = "$($folderName)\$($scriptName)"

    Write-Host "download from    : $($scriptUrl)"
    Write-Host "script name      : $($scriptName)"
    Write-Host "folder name      : $($folderName)"
    Write-Host "script full name : $($scriptFullName)"

    mkdir $folderName -ea Ignore
    cd $folderName
    Write-Host "changed to folder : $($folderName)"

    Write-Host "start downloading from '$($scriptUrl)'"
    (Invoke-WebRequest -UseBasicParsing -Uri "$($scriptUrl)").Content | Out-File -FilePath "$($scriptFullName)"
    Write-Host "successfully saved to '$($scriptFullName)'"

    Write-Host "start powershell with command: 'powershell.exe -ExecutionPolicy Unrestricted -windowstyle hidden -noninteractive -nologo -file $($scriptFullName)'"
    powershell.exe -ExecutionPolicy Unrestricted -windowstyle hidden -noninteractive -nologo -file "$($scriptFullName)"
    Write-Host "executed"
}

DownloadAndSaveScript "https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/prepare_vm_disks.ps1" `
    "prepare_vm_disks.ps1" `
    "d:\customScripts"

