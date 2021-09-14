Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-pwsh-install-modules.ps1"
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
    Install-Module AzTable -Force
    Write-Output "Install AzTable"
    Install-Module Az.Storage -Force
    Write-Output "Install Az.Storage"
    Install-Module AZureAD -Force
    Write-Output "Install AZureAD"
    Install-Module Az.Websites -MinimumVersion '2.8' -Force
    Write-Output "Install Az.Websites"
    Install-Module -Name Mdbc -Force
    Write-Output "Install Mdbc"

    pwsh.exe -Command "Install-Module AzTable -Force"
    Write-Output "pwsh: Install AzTable"
    pwsh.exe -Command "Install-Module Az.Storage -Force"
    Write-Output "pwsh: Install Az.Storage"
    pwsh.exe -Command "Install-Module AZureAD -Force"
    Write-Output "pwsh: Install AZureAD"
    pwsh.exe -Command "Install-Module Az.Websites -MinimumVersion '2.8' -Force"
    Write-Output "pwsh: Install Az.Websites"
    pwsh.exe -Command "Install-Module -Name Mdbc -Force"
    Write-Output "pwsh: Install Mdbc"

}


Write-Output "------------------------------------------"
Write-Output "plugin-pwsh-install-modules.ps1"
Write-Output "------------------------------------------"
$True
 
