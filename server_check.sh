#!/bin/bash

#LOG_FILE="$HOME/server-health-check/health.log"
#exec > >(tee -a "$LOG_FILE") 2>&1
echo "=============================="
echo "Check Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="

status=0

echo "====Server Health Check===="

echo "====Uptime===="
uptime

echo "====Memory===="
free -h

echo "====Disk===="
df -h

echo "====Disk Health===="

disk_usage=$(df -P / | awk 'NR==2 {print $5}')
disk_usage=${disk_usage%\%}

echo "====Disk Usage: ${disk_usage}%===="

if [ "$disk_usage" -ge 80 ]; then
	
echo "WARNING: Disk usage is too high!"
status=1
else
	echo "OK: Disk usage is normal!"
fi

echo "====Memory Health===="

mem_usage=$(free | awk '/^Mem:/ {printf "%.0f\n",$3/$2*100}')

echo "====Memory Usage: ${mem_usage}%===="

if [ "$mem_usage" -ge 80 ]; then
	echo "WARNING: Memory usage is too high!"
status=1
else
	echo "OK: Memory usage is normal!"
fi

echo "====CPU Health===="

cpu_usage=$(top -bn2 -d 1 | grep '%Cpu' | tail -1 | awk '{printf "%.1f\n", 100-$8}')

echo "==== CPU Usage: ${cpu_usage}%===="

if awk -v cpu="$cpu_usage" 'BEGIN {exit !(cpu >= 80)}'; then
	echo "WARNING: CPU usage is too high!"
status=1
else
	echo "OK: CPU usage is normal!"
fi
exit "$status"
