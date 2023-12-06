#Quinn Parent - PRGM2000 - Project 2 Device finder
#! bin/bash

CURRENTTIME=$(date +"%Y%m%d.%H%M%S")
LOGFILE="/mnt/share/logs/${CURRENTTIME}log.txt"
OUTPUTFILE="/mnt/share/${CURRENTTIME}.output"

NetworkScanner(){
# finds the alive hosts in the given subnets
SUBNETS=("10.5.0.0/16" "10.105.0.0/16") # these are the subnets in our environment - change these if yours are different

for NETWORK in "${SUBNETS[@]}"; do # loop that goes through each network in a given subnet
echo "Currently scanning $NETWORK..."
nmap -sn -T5 --min-rate=10000 "$NETWORK" >> "$LOGFILE" # this is going to save the output to a log.txt file. ideally this will be modified to find hosts that are alive
done   
}

InfoGrabber(){
#function for the infograbber - PRGM2000 Proj 2

IPLIST=$(grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOGFILE") # pulls IPs out
IFS=$'\n' read -r -d '' -a IPARRAY <<< "$IPLIST"    # puts IPs into an array called IPARRAY
echo "SSH Password for $ADDRESS:"   
read -s SSHPASS     # used for keeping a password through multiple SSH usages - for cisco devices w/ multiple commands
export SSHPASS


TEMPFILE=$(mktemp)  # makes a temporary file called TEMPFILE

echo ${IPARRAY[@]} # displays whats in the IPARRAY for testing

for ADDRESS in "${IPARRAY[@]}" # loop for each IP address in IPARRAY
do
echo "Checking operating system... ($ADDRESS)" # lets user know which IP is being checked
nmap -O --min-rate=1000 -T5 $ADDRESS > "$TEMPFILE"
if grep -q "Microsoft Windows" "$TEMPFILE"; # windows OS detection
then echo "Windows machine detected."
echo "" | tee -a $CURRENTTIME.output # adds a space to the file for visibility
sshpass -e ssh quinnp_admin@$ADDRESS -o ConnectTimeout=3 'powershell -Command "Write-Host \"Hostname: \" -NoNewline; Write-Host (hostname); Write-Host \"IP Address: \" -NoNewline; Write-Host ((Get-NetIPAddress -AddressFamily IPv4).IPAddress); Write-Host \"Default Gateway: \" -NoNewline; Write-Host ((Get-NetRoute -DestinationPrefix 0.0.0.0/0).NextHop); Write-Host \"DNS: \" -NoNewline; Write-Host ((Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses)" && exit' | tee -a "$OUTPUTFILE" # ssh command for windows config display



if [ $? -gt 0 ]; # displays error message
then echo "Connection failed, does the remote host have SSH enabled?"
fi

elif grep -q "Cisco" "$TEMPFILE" # cisco OS detection
then echo "Cisco device detected."
CISCOCOMMAND1="show version | include uptime" # multiple commands setup for cisco devices
CISCOCOMMAND2="show ip interface brief | exclude unassigned" 

echo "" | tee -a $CURRENTTIME.output # adds a space to the file for visibility
sshpass -e ssh quinnp_admin@$ADDRESS -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa "$CISCOCOMMAND1" | tee -a "$OUTPUTFILE" &&
sshpass -e ssh quinnp_admin@$ADDRESS -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa "$CISCOCOMMAND2" | tee -a "$OUTPUTFILE"
EXITSTATUS=${PIPESTATUS[0]}

if [ $EXITSTATUS -gt 0 ]; # checks for error
then echo "Trying with stronger encryption..."
echo "" | tee -a $CURRENTTIME.output # adds a space to the file for visibility
sshpass -e ssh quinnp_admin@$ADDRESS -o StrictHostKeyChecking=no -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa -c aes128-cbc "$CISCOCOMMAND1" | tee -a "$OUTPUTFILE" &&   # ssh command for cisco config display
sshpass -e ssh quinnp_admin@$ADDRESS -o StrictHostKeyChecking=no -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa -c aes128-cbc "$CISCOCOMMAND2" | tee -a "$OUTPUTFILE"
EXITSTATUS=${PIPESTATUS[0]}

if [ $EXITSTATUS -gt 0 ];
then echo "Something went wrong, let an administrator know."
fi
fi

elif grep -q "linux" "$TEMPFILE" # linux OS detection
then echo "Linux device detected."
echo "" | tee -a $CURRENTTIME.output # adds a space to the file for visibility
sshpass -e ssh quinnp_admin@$ADDRESS 'echo "Hostname: $(hostname)"; echo "IP Address: $(hostname -I | awk '\''{print $1}'\'')"; echo "Default Gateway: $(ip route | awk '\''/default/ {print $3}'\'')"; echo "DNS Server: $(awk '\''/^nameserver / {print $2}'\'' /etc/resolv.conf)"' | tee -a "$OUTPUTFILE" # ssh command for linux config display

if [ $? -gt 0 ]; # displays error message
then echo "Connection failed, does the remote host have SSH enabled?"
fi

else # if no OS is detected
echo "Unknown device detected."
fi
done
unset SSHPASS
}

NetworkScanner  # calls the functions
InfoGrabber