# Quinn Parent BASH Lab4
# 11/27/23
#!/bin/bash

echo -n "Welcome to the IP checking assignment - 4 (in bash)."

MainMenu() { # Ask user to enter IP address or for a list of addresses from a location.
    SINGLEIP=0
    echo -n "Would you like to:
    (1) Enter an IP address
    (2) Enter the location of a list of IP addresses
    (0) Quit
    "; read FIRST_MENU_CHOICE # reads the choice the user selected

    case $FIRST_MENU_CHOICE in
        1) # Enter single IP
            SINGLEIP=1          # this is used to check if the user is inputting a single IP
            echo -n "You have selected a single IP.
Please enter your IP now (ex. 192.168.1.10): "
            IPSLEFT=0           # sets this so the ping checker knows to quit after 1.
            IPValidator
            ;;
        2) # Enter a file for multiple IPs
            echo -n "You have selected a file location that contains IPs.
Please enter the file location (ex. ~/home/ips.txt)"
            FileFinder  # calls file validation function
            ;;
        0) # Exit script
            echo "Exiting..."
            exit
            ;;
        *) # Error catch, anything else
            echo "Sorry, that was an invalid result. Try again."
            MainMenu
            ;;
    esac
}

# Checks to see if the file exists, then splits it by line
FileFinder() {
    read INPUT_FILE
    if test -r "$INPUT_FILE"; then
        echo -n "$INPUT_FILE is a valid file."
        while IFS= read -r LINE; do
            # While there is a line to be read, it adds it to an array for IP validation and pinging.
            IP_LIST+=($LINE)    # adds to the array IP_LIST
        done < "$INPUT_FILE"
    IPSLEFT=${#IP_LIST[@]}      # sets the number of IPs in the array for ending ping at correct time
        for INPUT_IP in ${IP_LIST[@]}; do       # loops through the IP_LIST array
            ((IPSLEFT--))       # removes an IP for ending ping at correct time
            IPValidator
        done
    else
        echo -n "Sorry, the path you entered ($INPUT_FILE) does not exist.
        Going to main menu...
        "
        MainMenu
    fi
}

# Check if address is valid
IPValidator() {
    if [ $SINGLEIP -eq 1 ]; then        # checks to see if the user 
        read INPUT_IP
    else
        echo -n
    fi

    IFS="." read -ra SPLITADDRESS <<< $INPUT_IP # splits the address into 4 octets

    if [ ${#SPLITADDRESS[@]} -eq 4 ]; then      # checks to see if there is exactly 4 octets
        echo -n
    else
        echo "Your IP doesn't have 4 octets! Yikes! (Octet length: ${#SPLITADDRESS[@]})
Going to main menu...
"
        MainMenu
    fi

    VALPLACEMENT=0
    for OCTETVAL in ${SPLITADDRESS[@]}; do      # loops through each octet for value
        ((VALPLACEMENT++))                      # increments the variable by one each time for accurate error results
        if [[ $OCTETVAL =~ [^[:digit:]] ]]; then        # checks to see if there is anything other than a digit in the octet
            echo "Octet $VALPLACEMENT contains something other than a number ($OCTETVAL).
Going to main menu...
"
            MainMenu
        else
            echo -n
        fi
    done

    NUMPLACEMENT=0
    for OCTETNUM in ${SPLITADDRESS[@]}; do      # loops through each octet for number
        ((NUMPLACEMENT++))                      # increments the variable by one each time for accurate error results
        if [ $OCTETNUM -ge 0 ] && [ $OCTETNUM -le 255 ]; then   # checks to see if the octet value is between 0 and 255
            echo -n
        else
            echo "Octet $NUMPLACEMENT ($OCTETNUM) is not between 0-255.
Going to main menu...
"
            MainMenu
        fi
    done

    PingLogger  # calls ping function
}

# Pings provided IPs. If can't ping, export -> log file (failed ping, host IP, hostname, time)
PingLogger() {
    CURRENTTIME=$(date +"%Y%m%d_%H%M%S")        # sets the current date for filename
    CURRENTDAY=$(date)                          # sets the current date for error log
    echo "Testing ping ($INPUT_IP) ..."

    if [ ! -d "./log" ]; then                   # checks to see if there is a directory already created
        mkdir ./log                             # if directory is not there it creates one
    fi

    if ! ping -c 2 -4 -D "$INPUT_IP" > "./log/$CURRENTTIME.txt"; then   # this pings the INPUT_IP, then puts it in the log file
        HOSTIP=$(hostname -i)   # identifies address it is pinging from
        {
            echo -e "Source IP: $HOSTIP \nDestination IP: $INPUT_IP \nTime: $CURRENTDAY \nHostname: $(getent hosts $INPUT_IP | awk '{ print $2 }') \n" # displays information at top of file
            cat -
        } < ./log/$CURRENTTIME.txt > temp && mv temp ./log/$CURRENTTIME.txt     # appends information to be at the top of the log file

        dig "$INPUT_IP" >> "./log/$CURRENTTIME.txt"     # displays DNS information
        echo "Ping failed, check ./log/$CURRENTTIME.txt"        # tells user where to find the log file
    else
        echo "Ping worked!"
        rm ./log/$CURRENTTIME.txt       # deletes the log if no errors were found
    fi
    if [ $IPSLEFT -eq 0 ];      # checks to see if that was the last IP it needed to ping
    then echo -e "\n Returning to menu...\n"
    MainMenu
    fi
}

MainMenu        # calls main menu function
