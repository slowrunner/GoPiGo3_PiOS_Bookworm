#!/bin/bash

# FILE:  ip_feedback.sh
# This script is run once at boot by ip_feedback.service

echo "starting"
sleep 60
COUNT=0
IPs=$(hostname --all-ip-addresses)
while [ -z "$IPs" ]
do
    echo "loop"
    sleep 1;
    IPs=$(hostname --all-ip-addresses)
    COUNT=$((COUNT+1))
    echo "count: "$COUNT > /home/pi/ipcount
done

echo "done looping "

echo "count: "$COUNT > /home/pi/ipcount

ifconfig wlan0 | grep 'inet ' | awk '{print $2}'  > /home/pi/ip.number
read -r IP_NUMBER < /home/pi/ip.number
echo $IP_NUMBER

# remove previous IP info
sudo rm /boot/*.assigned_ip &>/dev/null
# sudo rm /home/pi/Desktop/*.assigned_ip &>/dev/null

# remove previous Failed IP
FAILED=/home/pi/failedIP
if test -f "$FAILED"; then
    sudo rm $FAILED &>/dev/null
fi
# sudo rm /home/pi/Desktop/failedIP &>/dev/null

if [ ! -z "$IP_NUMBER" ]
then
        echo "saving IP info"
        sudo bash -c "echo $IP_NUMBER > /boot/firmware/$IP_NUMBER.assigned_ip"
        echo "IP info saved"

        su -c "espeak-ng -a 20 'WiFi IP'" pi
        su -c "espeak-ng -a 20 $IP_NUMBER" pi
        su -c "espeak-ng -a 20 repeating "  pi
        su -c "espeak-ng -a 20 $IP_NUMBER" pi
else
        su -c "espeak-ng -a 20 'no IP number'" pi
        echo "no IP number"
        echo "no IP" > /home/pi/failedIP

fi
echo "done with IP feedback"
