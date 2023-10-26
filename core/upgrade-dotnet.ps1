# Standalone script that get's executed thru az runcommand to update .net 6 & 7
#
# Invoke-AzVmssVMRunCommand -VMScaleSetName 'vmssmil' -ResourceGroupName 'rg-sf-milano-pool' -InstanceId '0' -CommandId 'RunPowerShellScript' -ScriptPath '.\upgrade-dotnet.ps1'
#
wget -o install-dotnet-sdk.ps1 https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/install-dotnet-sdk.ps1
wget -o dotnet-install.ps1 https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/core/dotnet-install.ps1
./install-dotnet-sdk.ps1