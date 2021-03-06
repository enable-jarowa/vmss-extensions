Write-Output "------------------------------------------"
Write-Output "Custom script: map-file-share.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features=$args[5]

$connectTestResult = Test-NetConnection -ComputerName "$($f_url)" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    Write-Output "Test connection OK: $($f_url)"
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    Write-Output "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    Write-Output "Test connection FAILED: $($f_url)"
}

# Save the password so the drive will persist on reboot
cmd.exe /C "cmdkey /add:`"$($f_url)`" /user:`"Azure\$($f_account)`" /pass:`"$($f_key)`""
# Mount the drive
New-PSDrive -Name "$($f_drive)" -PSProvider FileSystem -Root "\\$($f_url)\$($f_folder)" -Persist -ErrorAction Ignore

Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
