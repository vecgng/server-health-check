#!/bin/bash

#LOG_FILE="$HOME/server-health-check/health.log"
#exec > >(tee -a "$LOG_FILE") 2>&1
echo "=============================="
echo "Check Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="

status=0

set_warning() {
    if [ "$status" -eq 0 ]; then
        status=1
    fi
}

echo "====Server Health Check===="

echo "====Uptime===="
uptime

echo "====Memory===="
free -h

echo "====Disk===="
df -h

echo "====Disk Health===="

if disk_info=$(df -P /); then
	disk_usage=$(echo "$disk_info" | awk 'NR==2 {print $5}')
	disk_usage=${disk_usage%\%}


	if [[ ! "$disk_usage" =~ ^[0-9]+$ ]]; then
		echo "ERROR: Disk usage is empty!"
		status=2
	else
		echo "====Disk Usage: ${disk_usage}%===="

	if [ "$disk_usage" -ge 80 ]; then
		echo "WARNING: Disk usage is too high!"
		set_warning
	else
		echo "OK: Disk usage is normal!"
	fi
	fi
else
	echo "ERROR: Failed to get disk usage!"
	status=2
fi


echo "====Memory Health===="

if mem_info=$(free); then
    mem_total=$(echo "$mem_info" | awk '/^Mem:/ {print $2}')
    mem_used=$(echo "$mem_info" | awk '/^Mem:/ {print $3}')

    if [[ "$mem_total" =~ ^[0-9]+$ && "$mem_used" =~ ^[0-9]+$ ]]; then

        if [ "$mem_total" -gt 0 ] &&
           [ "$mem_used" -le "$mem_total" ]; then

            mem_usage=$(awk -v total="$mem_total" -v used="$mem_used" \
                'BEGIN {printf "%.0f\n", used / total * 100}')

            echo "====Memory Usage: ${mem_usage}%===="

            if [ "$mem_usage" -ge 80 ]; then
                echo "WARNING: Memory usage is too high!"
		set_warning
            else
                echo "OK: Memory usage is normal."
            fi

        else
            echo "ERROR: Invalid memory values!"
            status=2
        fi

    else
        echo "ERROR: Memory data is not numeric!"
        status=2
    fi

else
    echo "ERROR: Failed to get memory information!"
    status=2
fi


echo "====CPU Health===="

if cpu_info=$(LC_ALL=C top -bn2 -d 1); then

    cpu_idle=$(echo "$cpu_info" | awk '

    /%Cpu/ {
            for (i=1; i<=NF; i++) {
                if ($i == "id,") idle=$(i-1)
            }
        }
        END {
            if (idle != "") print idle
        }')


    if [[ "$cpu_idle" =~ ^[0-9]+([.][0-9]+)?$ ]]; then

        if awk -v idle="$cpu_idle" \
            'BEGIN {exit !(idle >= 0 && idle <= 100)}'; then

            cpu_usage=$(awk -v idle="$cpu_idle" \
                'BEGIN {printf "%.1f\n", 100-idle}')

            echo "====CPU Usage: ${cpu_usage}%===="

            if awk -v cpu="$cpu_usage" \
                'BEGIN {exit !(cpu >= 80)}'; then
                echo "WARNING: CPU usage is too high!"

                set_warning
            else
                echo "OK: CPU usage is normal."
            fi

        else
            echo "ERROR: Invalid CPU idle percentage!"
            status=2
        fi

    else
        echo "ERROR: Invalid CPU data!"
        status=2
    fi

else
    echo "ERROR: Failed to get CPU information!"
    status=2
fi
exit "$status"
