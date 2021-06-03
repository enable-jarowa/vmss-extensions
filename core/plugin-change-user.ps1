Write-Output "------------------------------------------"
Write-Output "Custom script: plugin-change-user.ps1"
Write-Output "------------------------------------------"

Write-Output "Change master user - password never expirer"
Get-LocalUser -Name master | Set-LocalUser -PasswordNeverExpires $True

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
