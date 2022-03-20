clammit=`ps -ef | grep clammit | grep -v "grep" | awk '{print $2}'`
clamav=`ps -ef | grep clamd | grep -v "grep" | awk '{print $2}'`
freshclam=`ps -ef | grep fresh | grep -v "grep" | awk '{print $2}'`
ps -p ${clammit},${clamav},${freshclam} -o pid,%cpu,%mem,cmd | grep -v "CMD" | logger
