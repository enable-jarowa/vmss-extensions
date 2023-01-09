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
    try {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    
        ## Windows PowerShell 5.1 comes with version 1.0.0.1 of PowerShellGet preinstalled. This version of PowerShellGet has a limited features and must update to the latest version (preinstalled is missing -AcceptLicense)
        Install-Module PowerShellGet -AllowClobber -Force
        Write-Output "Update preinstalled PowerShellGet"
        powershell.exe -ExecutionPolicy Unrestricted -nologo -Command Install-Module AzTable -AcceptLicense -AllowClobber -Force
        Write-Output "Install AzTable"
        powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -Command Install-Module Az.Storage -AcceptLicense -AllowClobber -Force
        Write-Output "Install Az.Storage"
        powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -Command Install-Module AZureAD -AcceptLicense -AllowClobber -Force
        Write-Output "Install AZureAD"
        powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -Command Install-Module Az.Websites -MinimumVersion '2.8' -AcceptLicense -AllowClobber -Force
        Write-Output "Install Az.Websites"
        powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -Command Install-Module -Name Mdbc -AcceptLicense -AllowClobber -Force
        Write-Output "Install Mdbc"
        powershell.exe -ExecutionPolicy Unrestricted -noninteractive -nologo -Command Install-Module -Name Logging -AcceptLicense -AllowClobber -Force
        Write-Output "Install Logging"
        
        ## still needs fix parameter - because powershell does not have $env path updated
        $location="C:\Program Files\PowerShell\7"
        Start-Process -NoNewWindow -Wait "$($location)\pwsh.exe" -ArgumentList "-Command", "Install-Module AzTable -Force"
        Write-Output "pwsh: Install AzTable"
        Start-Process -NoNewWindow -Wait "$($location)\pwsh.exe" -ArgumentList "-Command", "Install-Module Az.Storage -Force"
        Write-Output "pwsh: Install Az.Storage"
        Start-Process -NoNewWindow -Wait "$($location)\pwsh.exe" -ArgumentList "-Command", "Install-Module AZureAD -Force"
        Write-Output "pwsh: Install AZureAD"
        Start-Process -NoNewWindow -Wait "$($location)\pwsh.exe" -ArgumentList "-Command", "Install-Module Az.Websites -MinimumVersion '2.8' -Force"
        Write-Output "pwsh: Install Az.Websites"
        Start-Process -NoNewWindow -Wait "$($location)\pwsh.exe" -ArgumentList "-Command", "Install-Module -Name Mdbc -Force"
        Write-Output "pwsh: Install Mdbc"
        Start-Process -NoNewWindow -Wait "$($location)\pwsh.exe" -ArgumentList "-Command", "Install-Module -Name Logging -Force"
        Write-Output "pwsh: Install Logging"
    
    }
    catch {
        Write-Output "An error occurred: keep going"
        Write-Output $_
    }

}


Write-Output "------------------------------------------"
Write-Output "plugin-pwsh-install-modules.ps1"
Write-Output "------------------------------------------"
$True
 
