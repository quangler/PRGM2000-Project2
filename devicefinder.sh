#Quinn Parent - PRGM2000 - Project 2 Device finder
#! bin/bash

CURRENTTIME=$(date +"%Y%m%d.%H%M%S")
OUTPUTFILE="/mnt/share/logs/${CURRENTTIME}.output"   # sets the output file path and name
USERCREDENTIALS="quinnp_admin"  # sets the variable for user credentials, shown for testing - change to service account

NetworkScanner(){
# finds the alive hosts in the given subnets
    SUBNETS=("10.5.0.0/16" "10.105.0.0/16") # these are the subnets in our environment - change these if yours are different
    NETWORKTEMP=$(mktemp)   # creates a temporary file for storing the hosts on network
    
    #finding hosts -------------------------------------------------------------------------
    for NETWORK in "${SUBNETS[@]}"; do # loop that goes through each network in a given subnet
        echo "Currently scanning $NETWORK..."
        nmap -sn -T5 --min-rate=10000 "$NETWORK" >> "$NETWORKTEMP" # quickly identifies the hosts on a network
    done   
}

InfoGrabber(){
#function for the infograbber - PRGM2000 Proj 2
    
    #array of IPs creation ------------------------------------------------------------------------
    IPLIST=$(grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' "$NETWORKTEMP") # pulls IPs out of temporary network file
    IFS=$'\n' read -r -d '' -a IPARRAY <<< "$IPLIST"    # puts IPs into an array called IPARRAY
    
    #password section ----------------------------------------------------------------------
    echo "SSH Password for $ADDRESS:"   
    read -s SSHPASS     # used for keeping a password through multiple SSH usages - for testing, in real environment would prompt user for credentials
    export SSHPASS

    TEMPFILE=$(mktemp)  # makes a temporary file called TEMPFILE
    # echo ${IPARRAY[@]} # displays whats in the IPARRAY for testing

    for ADDRESS in "${IPARRAY[@]}"; do # loop for each IP address in IPARRAY
        echo "Checking operating system... ($ADDRESS)" # lets user know which IP is being checked
        nmap -O --min-rate=1000 -T5 $ADDRESS > "$TEMPFILE" # this places result of OS finding operation in a temporary file
        
        #windows detection --------------------------------------------------------------------
        if grep -q "Microsoft Windows" "$TEMPFILE"; # windows OS detection
            then echo "Windows machine detected."

            echo "" | tee -a "$OUTPUTFILE" # adds a new line to the file for visibility
            sshpass -e ssh $USERCREDENTIALS@$ADDRESS -o ConnectTimeout=3 'powershell -Command "Write-Host \"Hostname: \" -NoNewline; Write-Host (hostname); Write-Host \"IP Address: \" -NoNewline; Write-Host ((Get-NetIPAddress -AddressFamily IPv4).IPAddress); Write-Host \"Default Gateway: \" -NoNewline; Write-Host ((Get-NetRoute -DestinationPrefix 0.0.0.0/0).NextHop); Write-Host \"DNS: \" -NoNewline; Write-Host ((Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses)" && exit' | tee -a "$OUTPUTFILE" # ssh command for windows config display
            
            EXITSTATUS=${PIPESTATUS[0]} # sets the error code that it checks to the SSH command
            if [ $EXITSTATUS -gt 0 ];   # checks for error code >1 (error has occured)
                then echo "Connection failed, does the remote host have SSH enabled?" # response for if error code is found
            fi

        #cisco detection -----------------------------------------------------------------------
        elif grep -q "Cisco" "$TEMPFILE" # cisco OS detection
            then echo "Cisco device detected."

            CISCOCOMMAND1="show version | include uptime" # multiple commands setup for cisco devices
            CISCOCOMMAND2="show ip interface brief | exclude unassigned" 

            echo "" | tee -a "$OUTPUTFILE" # adds a new line to the file for visibility
            sshpass -e ssh $USERCREDENTIALS@$ADDRESS -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa "$CISCOCOMMAND1" | tee -a "$OUTPUTFILE" &&    # inputting the SSH commands, using sshpass for credentials
            sshpass -e ssh $USERCREDENTIALS@$ADDRESS -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa "$CISCOCOMMAND2" | tee -a "$OUTPUTFILE"       # ssh algorithms selected for general cisco SSH
            
            EXITSTATUS=${PIPESTATUS[0]} # sets the error code that it checks to the SSH command
            if [ $EXITSTATUS -gt 0 ];   # checks for error code >1 (error has occured)
                then echo "Trying with stronger encryption..." # this is to tell the user the error that was previously displayed is being resolved

                echo "" | tee -a "$OUTPUTFILE" # adds a new line to the file for visibility
                sshpass -e ssh $USERCREDENTIALS@$ADDRESS -o StrictHostKeyChecking=no -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa -c aes128-cbc "$CISCOCOMMAND1" | tee -a "$OUTPUTFILE" &&  # SSH commands with better encryption, ignores RSA prompt
                sshpass -e ssh $USERCREDENTIALS@$ADDRESS -o StrictHostKeyChecking=no -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa -c aes128-cbc "$CISCOCOMMAND2" | tee -a "$OUTPUTFILE" 
                
                EXITSTATUS=${PIPESTATUS[0]} # sets the error code that it checks to the SSH command
                if [ $EXITSTATUS -gt 0 ];   # checks for error code >1 (error has occured)
                    then echo "Something went wrong, let an administrator know."
                fi
        fi

        #linux detection -----------------------------------------------------------------------
        elif grep -q "linux" "$TEMPFILE" # linux OS detection
            then echo "Linux device detected."

            echo "" | tee -a "$OUTPUTFILE" # adds a new line to the file for visibility
            sshpass -e ssh $USERCREDENTIALS@$ADDRESS 'echo "Hostname: $(hostname)"; echo "IP Address: $(hostname -I | awk '\''{print $1}'\'')"; echo "Default Gateway: $(ip route | awk '\''/default/ {print $3}'\'')"; echo "DNS Server: $(awk '\''/^nameserver / {print $2}'\'' /etc/resolv.conf)"' | tee -a "$OUTPUTFILE" # ssh command for linux config display
            EXITSTATUS=${PIPESTATUS[0]} # sets the error code that it checks to the SSH command
            if [ $EXITSTATUS -gt 0 ]; # checks for error code >1 (error has occured)
                then echo "Connection failed, does the remote host have SSH enabled?"
            fi

            else # if no OS is detected
            echo "Unknown device detected." # currently this error occurs when the fortigate is detected
        fi
    done
    unset SSHPASS   # clears SSHPASS for next use
}

NetworkScanner  # calls the functions
InfoGrabber