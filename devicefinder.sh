#Quinn Parent - PRGM2000 - Project 2 Device finder
#! bin/bash

#subnets: ideally find this by pinging 10.5.X.254 for all 255, then use those results
SUBNETS=("10.5.10.0/24" "10.5.20.0/24" "10.5.22.0/24" "10.5.23.0/24" "10.5.30.0/24" "10.5.40.0/24" "10.5.105.0/24") # temp manually inputted

#loop that uses NMAP for all subnets to identify hosts on them
for NETWORK in "${SUBNETS[@]}"
do
echo "Currently scanning $NETWORK"
nmap -sn --min-rate=500 "$NETWORK" >> log.txt # this is going to save the output to a log.txt file. ideally this will be modified to find hosts that are alive
done
