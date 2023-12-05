#Quinn Parent - PRGM2000 - Project 2 Device finder
#! bin/bash

CURRENTTIME=$(date +"%Y%m%d.%H%M%S")
LOGFILE="${CURRENTTIME}log.txt"
echo "$LOGFILE"
#subnets: ideally find this by pinging 10.5.X.254 for all 255, then use those results
SUBNETS=("10.5.10.0/24" "10.5.20.0/24" "10.5.22.0/24" "10.5.23.0/24" "10.5.30.0/24" "10.5.40.0/24" "10.5.105.0/24") # temp manually inputted

#loop that uses NMAP for all subnets to identify hosts on them
for NETWORK in "${SUBNETS[@]}"
do
echo "Currently scanning $NETWORK"
nmap -sn --min-rate=500 "$NETWORK" >> "$LOGFILE" # this is going to save the output to a log.txt file. ideally this will be modified to find hosts that are alive
done

# checks for the correct line in log file, then replaces it with air (supposed to just make a list of IPs)


#CHECKLINE="Nmap scan report for"
#REPLACEAIR=""
#while IFS= read -r LINE; do
#if grep -q "$CHECKLNE" <<< "$LINE";
#then sed -i "s/^.*${CHECKLINE}\(.*\)$/${REPLACEAIR}\1/" "$LOGFILE"
#else sed -i "s/.*/${REPLACEAIR}/" "$LOGFILE"
#fi
#done < $LOGFILE

IPLIST=grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOGFILE"