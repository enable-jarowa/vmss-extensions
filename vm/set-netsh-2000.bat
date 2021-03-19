set D=%~dp0
echo %D%

echo "Download scripts from https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/vm/" >>%D%set-netsh-log.txt
bitsadmin /transfer updatescript /download "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/vm/fix-vm-start-params.bat" "%D%fix-vm-start-params.bat"
bitsadmin /transfer updatescript /download "https://raw.githubusercontent.com/enable-jarowa/vmss-extensions/main/vm/tcp-timed-wait-delay.reg" "%D%tcp-timed-wait-delay.reg"

echo "run script %D%fix-vm-start-params.bat" >>%D%set-netsh-log.txt
call %D%fix-vm-start-params.bat