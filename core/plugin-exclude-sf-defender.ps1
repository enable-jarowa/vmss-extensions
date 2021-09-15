Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-exclude-sf-defender.ps1"
Write-Output "------------------------------------------"

try {
    $allExclPaths = (Get-MpPreference).ExclusionPath

    $exclPaths = @(
        "c:\agent", 
        "c:\a", #build folder
        "S:\", 
        "D:\", 
        "C:\Program Files\Microsoft Service Fabric"
    )

    for ($defenderI=0; $defenderI -lt $exclPaths.Count; $defenderI++) {
        $exclPath = $exclPaths[$defenderI]
        if (($null -eq $allExclPaths) -or (!$allExclPaths.Contains($exclPath))) {
            Add-MpPreference -ExclusionPath $exclPath
            Write-Host "$($exclPath) - exclusion added"
        } else {
            Write-Host "$($ruleName) - exclusion already done"
        }
    }
}
catch {
    Write-Output "strange defender message but - not critial. ignore"
    Write-Output "error message $($_.Exception.Message)"
}


Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
