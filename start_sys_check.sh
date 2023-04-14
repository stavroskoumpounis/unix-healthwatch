#!/bin/bash

cpu_sum=0
memory_sum=0
count=0

record_and_report() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    memory_usage=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2}')
    disk_usage=$(df -h | awk '$NF=="/"{printf "%.0f", $5}')

    #Log the stats
    log=$(printf "%s | CPU Usage: %s%% | Memory Usage: %s%% | Disk Usage: %s%%" "$timestamp" "$cpu_usage" "$memory_usage" "$disk_usage")
    printf "%s\n" "$log" >>usage.log
    echo "usage logged C: $cpu_usage M: $memory_usage D: $disk_usage"

    #add sums
    cpu_sum=$(echo "$cpu_sum + $cpu_usage" | bc)
    memory_sum=$((memory_sum + memory_usage))
    count=$((count + 1))
}

# Run loop for 1 min
end=$((SECONDS + 60))
while [ $SECONDS -lt $end ]; do
    record_and_report
    #wait 6s between each check
    sleep 6
done

# Calculate the average usage values
cpu_avg=$(echo "scale=2; $cpu_sum / $count" | bc)
memory_avg=$((memory_sum / count))
disk_avg=$((disk_sum / count))
#echo "CPU Average is: $cpu_avg"

check_thresholds() {
    cpu_threshold=60
    memory_threshold=65
    disk_threshold=85

    alert=false
    # Check if any thresholds are crossed
    if [[ ${cpu_avg%.*} -gt $cpu_threshold ]]; then
        alert=true
        message+="• CPU usage: ${cpu_avg}% (threshold: ${cpu_threshold}%)\n"
    fi

    if [[ $memory_avg -gt $memory_threshold ]]; then
        alert=true
        message+="• Memory usage: ${memory_avg}% (threshold: ${memory_threshold}%)\n"
    fi

    if [[ $disk_usage -gt $disk_threshold ]]; then
        alert=true
        message+="• Disk usage: ${disk_usage}% (threshold: ${disk_threshold}%)\n"
    fi

    if [ "$alert" = true ]; then
        public_ip=$(curl -s icanhazip.com)
        # Set subject line for email
        subject="ALERT: System performance thresholds crossed on $(hostname)@$public_ip"
        #subject="ALERT: System performance thresholds crossed on $(hostname)"


        #email body with usage stats
        body="Hello,\n\nThis is an automated message to inform you that system thresholds have been crossed on $(hostname).\n\nPlease take appropriate actions to avoid any potential issues.\n\nBelow are the average usage stats for the latest system check:\n\n• CPU usage: $cpu_avg%\n• Memory usage: $memory_avg%\n• Disk usage: $disk_usage\n\n"

        if [ ! -z "$message" ]; then
            body+="The following threshold(s) have been crossed:\n\n$message\n"
        fi

        body+="Server monitoring system"
        echo -e "$body" | mutt -a usage.log -s "$subject" -- amadubu89@gmail.com
    fi

    printf "Latest system check: CPU avg: %s%% | Memory avg: %s%% | Disk usage: %s%%\n" "$cpu_avg" "$memory_avg" "$disk_usage"
    echo
}

check_thresholds
