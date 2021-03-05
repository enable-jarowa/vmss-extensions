

$connectTestResult = Test-NetConnection -ComputerName stdocuhawaii3pool.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"stdocuhawaii3pool.file.core.windows.net`" /user:`"Azure\stdocuhawaii3pool`" /pass:`"j9f1jsJLODJ0+u7ShrcV9iKzOlq8gR9ulet8O/lC/GmQLJ1uJ12pW5vbPbeNiCRSjx1F3t7E6Cp+lS9bBz4MTw==`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\stdocuhawaii3pool.file.core.windows.net\documents" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
 
