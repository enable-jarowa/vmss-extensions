set D=%~dp0
echo %D%

echo "===================================================" *>> %D%set-netsh-log.txt
echo "dynamic ports before" *>> %D%set-netsh-log.txt
netsh int ipv4 show dynamicport tcp *>> %D%set-netsh-log.txt
netsh int ipv4 set dynamicport tcp start=1025 num=64511 store=persistent
netsh int ipv6 set dynamicport tcp start=1025 num=64511 store=persistent

echo "add tcp delay 15s to registry" *>> %D%set-netsh-log.txt

regedit /s %D%tcp-timed-wait-delay.reg

date /T *>> %D%set-netsh-log.txt
time /T *>> %D%set-netsh-log.txt
echo "netsh set to 64511" *>> %D%set-netsh-log.txt
netsh int ipv4 show dynamicport tcp *>> %D%set-netsh-log.txt
echo "===================================================" *>> %D%set-netsh-log.txt

GOTO ende

:endparse
echo "call script with directory as parameter"
:ende
