

$connectTestResult = Test-NetConnection -ComputerName ***REMOVED*** -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"***REMOVED***`" /user:`"Azure\***REMOVED***`" /pass:`"***REMOVED***`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\***REMOVED***\documents" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
 
