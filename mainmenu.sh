#!/bin/bash
#PRGM2000 - Project 2 Main Menu
#Quinn Parent 
#Matt Telford

BACK_PATH="~/backMenu.sh"
BACK_PATH=$(eval echo "$BACK_PATH")
MONITOR_PATH="~/monitoring.sh"
MONITOR_PATH=$(eval echo "$MONITOR_PATH")

CURRENTTIME=$(date +"%Y%m%d.%H%M%S")    # shows current time, used for file names
OUTPUTFILE="/mnt/share/logs/${CURRENTTIME}.output"   # sets the output file path and name
USERCREDENTIALS="quinnp_admin"  # sets the variable for user credentials, shown for testing - change to service account


echo -n "Welcome to Team5 project 2" # first time running intro

MainMenu(){ # menu function
        echo -n "
[1] Backup / Archive
[2] System Monitor
[3] View Logs
[4] View Network Devices
[0] Quit
Please enter your choice: "
        read MENUCHOICE # asks for user's choice

        case $MENUCHOICE in
                1)
                # function for archival/backups
                /bin/bash "$BACK_PATH"
                MainMenu
                ;;
                2)
                # function for monitoring system
                sudo /bin/bash "$MONITOR_PATH" # need sudo here cause its a powerful command you know?
                MainMenu
                ;;
                3)
                # functions for viewing logs
                SelectPath
                ViewLogs
                ;;
                4)
                # functions for viewing network devices
                NetworkScanner
                InfoGrabber
                ;;
                0)
                echo "Exiting program..."
                exit
                ;;
                *)
                echo "Sorry, you entered an invalid input. Please try again."
                MainMenu
                ;;
        esac

}

SelectPath(){
# selecting path function
    SELECTEDLOGPATH="/mnt/share/logs/" # default log path
    echo -n "Where are the logs you want to view? (Default - /mnt/share/logs/): "
    read LOGPATH    # user log path input
    if [ -z "$LOGPATH" ]    # checks to see if user just hit enter (goes to default path)
        then echo "Default path selected."
        elif [ -d "$LOGPATH" ] && [[ "$LOGPATH" == */ ]] # checks if path user entered exists and ends with /
            then echo "Path is functional. ($LOGPATH)"
            SELECTEDLOGPATH="$LOGPATH"  # sets the selected path to user path
        else echo "Log path doesn't exist. Defaulting to /mnt/share/logs/"
    fi
}

ViewLogs(){
# viewing logs function
    while IFS= read -r LOGFILE; # reads the files in the directory
    do LOGFILEARRAY+=("$LOGFILE")       # creates an array that adds all the files from the directory
    done < <(ls "$SELECTEDLOGPATH")     # pulls from an ls of the selected path
    # echo ${LOGFILEARRAY[@]} # showing the output of the array for testing
    FILEPOS=0   # sets counter to 0
    echo "There are ${#LOGFILEARRAY[@]} files to read." # lets the user know how many paths there are
    for FILE in ${LOGFILEARRAY[@]}      # a loop of each file in the directory
        do ((FILEPOS++))                # adds one to the counter
        echo "$FILEPOS. $FILE"          # puts a number next to the name of the file for easy selecting
    done
    echo -n "Please enter the file you would like to interact with. (q to quit): "
    read -r USERLOGSELECTION
    if [ $USERLOGSELECTION = "q" ]      # if user enters q
        then echo "Quitting back to menu"
        MainMenu        # goes back to the main menu
        elif [ "$USERLOGSELECTION" -gt ${#LOGFILEARRAY[@]} ] || [ "$USERLOGSELECTION" -le 0 ]   # makes sure the user enters a number thats in the range
            then echo -e "Sorry, your selection ($USERLOGSELECTION) is not valid. (Choice must be between 1-${#LOGFILEARRAY[@]}.) \n Try again."
            LOGFILEARRAY=() # empties array
            ViewLogs    # goes back to the start of this function
        elif ! [[ "$USERLOGSELECTION" =~ ^[0-9]+$ ]]
            then echo -e "Sorry, you should have entered only a number or 'q'. \n Try again."
            LOGFILEARRAY=() # empties array
            ViewLogs    # goes back to the start of this function
        else echo -e "You have selected ${LOGFILEARRAY[$USERLOGSELECTION-1]}. \nWhat would you like to do with this file? \n[1] View this log \n[2] Delete this log \n[q] Go back"
        read -r LOGOPTIONS      # sets $LOGOPTIONS to user input
        fi
        if [ "$LOGOPTIONS" = "1" ]      # checks if user typed 1
            then cat "$SELECTEDLOGPATH${LOGFILEARRAY[$USERLOGSELECTION-1]}"     # displays the file
            MainMenu    # goes to main menu
        elif [ "$LOGOPTIONS" = "2" ]    # checks if user typed 2
            then echo -n "Are you sure you want to delete ${LOGFILEARRAY[$USERLOGSELECTION-1]}? [y/N]: "
            read -r DELETELOG   # user input for removing file
            if [ -z $DELETELOG ]        # if user enters nothing
                then echo "Default no selected, quitting back to menu"
                MainMenu
            elif [ $DELETELOG = "n" ] || [ $DELETELOG = "N" ]   # if user typed n or N
                then echo " No selected, quitting back to menu"
                MainMenu
            elif [ $DELETELOG = "y" ] || [ $DELETELOG = "Y" ]   # if user typed y or Y
            then echo "Yes selected, deleting file and quitting to menu..." 
            rm "$SELECTEDLOGPATH${LOGFILEARRAY[$USERLOGSELECTION-1]}"      # deletes the file
            MainMenu
            else echo "Sorry, your input was invalid. Quitting back to menu"    # if user entered anything else goes back to main menu
            MainMenu
            fi
        elif [ "$LOGOPTIONS" = "q" ]    # if user typed q, quit to menu
            then echo "Quitting back to menu"
            MainMenu
        else echo -e "Sorry, that input is not recognized. Please press 1, 2, or q. \nQuitting back to menu"
        MainMenu
        fi
}

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

MainMenu    # runs main menu function