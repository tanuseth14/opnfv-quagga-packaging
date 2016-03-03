#!/bin/sh
# This script will take 2 inputs.first the QBgp sdp and second will be the upgrade campaign sdp.
#
 
sdp=$1
campaign=$2

echo "Entered Upgrade sdp is:" $sdp 
echo "Entered Upgrade camapign fileis : " $campaign
var="."
#the logic (using bash string replacement)
front=${campaign%${var}*}
rear=${campaign#*${var}}

echo "BLOCKING PORTS USING IP TABLES"
iptables -A INPUT -p tcp --dport 12001 -j DROP
iptables -A OUTPUT -p tcp --dport 12001 -j DROP

echo "IMPORTING SDPs"
cmw-sdp-import $sdp $campaign

echo "STARTING CAMPAIGN"
cmw-campaign-start $front
cmw-campaign-status $front
status=$(cmw-campaign-status $front)
#cmw-campaign-status $front
var1="="

while [[ "${status#*${var1}}" != "COMPLETED" ]];
do
rear2=${status#*${var1}}
echo "waiting for COMPLETE;" current status is: ${rear2}
status=$(cmw-campaign-status $front)
echo "status is : $status"
sleep 10
done

echo "COMMIT SDPs "
cmw-campaign-commit $front

echo "UNBLOCKING PORTS FOR IP TABLES"

iptables -D INPUT -p tcp --dport 12001 -j DROP
iptables -D OUTPUT -p tcp --dport 12001 -j DROP

