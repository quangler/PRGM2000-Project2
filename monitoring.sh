#!/bin/bash

#-------------------------------------
#| Author: Matt Telford               |
#| Class: PRGM2000                    |
#| Assignment: Project 2 Part 3       |
#| Title: Monitoring Host Resources   |
#-------------------------------------

: '
a. Write a function that will monitor local and remote system resources for a host PC. These
resources include but are not limited to CPU usage, Available memory, Available Disc Storage,
etc. (you have the option to include more if you feel the urge). Note: Users should have the
option to specify which host they want to monitor.

b. Create a log file called “SysMonitor” which will store the captured data for future use. Ensure
the time and date are included for each log, and it is formatted in a professional manner and not
a data dump.

Install sshpass:
    Ubuntu/Debian: apt-get install sshpass
    Fedora/CentOS: yum install sshpass
    Arch: pacman -S sshpass

'
LOG_FILE="/mnt/share/logs/SysMonitor.txt"
# Expand the tilde (~) to the user's home directory

# fuction to get CPU usage

function Remote_Mon_Cpu () {
    # Redirect file descriptor 3 to the log file
    exec 3>&1 1>>"${LOG_FILE}" #2>&1

    local remote_Host=$1
    # Return CPU monitoring command
    commands_to_run='iostat -c 1 1 | awk '\''/avg-cpu/ {getline; printf "CPU (%):\n| User   | System | Idle  |\n|--------|--------|-------|\n| %-6s | %-6s | %-4s |\n", $1, $3, $NF}'\'''
    # If localhost is selected
    if [ "$1" == "localhost" ] ; then
        # run command
        cpu_stats=$(eval "$commands_to_run")
        # write to console and log
        echo -ne "\n$cpu_stats\n" | tee /dev/fd/3

    # if a remote host is selected and passed SSH test
    elif [ "$1" != "localhost" ] ; then
        # SSH and run command
        cpu_stats=$(sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no mattt_admin@$remote_Host "$commands_to_run")
        # write to console and log
        echo -ne "$cpu_stats\n" | tee /dev/fd/3

   else
      # problems
        echo "Invalid remote host or unable to establish SSH connection."
        return 1
   fi
    # Restore the original stdout
    exec >&3 3>&-
}

# function to get memory usage

function Remote_Mon_RAM () {
    # Redirect file descriptor 3 to the log file
    exec 3>&1 1>>"${LOG_FILE}" #2>&1

    local remote_Host=$1
    # RAM Command
    commands_to_run='free -m'
    # If localhost is selected
    if [ "$1" == "localhost" ] ; then
        # run command
        ram_stats=$(eval "$commands_to_run")
        # write to console and log
        echo -e "\nRAM (MB):" | tee /dev/fd/3
        echo -ne "$ram_stats\n" | tee /dev/fd/3

     # if a remote host is selected and passed SSH test
    elif [ "$1" != "localhost" ] ; then
        # SSH and run command
        ram_stats=$(sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no mattt_admin@$remote_Host "$commands_to_run")

        # write to console and log
        echo -e "\nRAM:" | tee /dev/fd/3
        echo -ne "$ram_stats\n" | tee /dev/fd/3

   else
      # problems
        echo "Invalid remote host or unable to establish SSH connection."
        return 1
   fi
    # Restore the original stdout
    exec >&3 3>&-   

}

# function to get disk usage
function Remote_Mon_disks () {

    # Redirect file descriptor 3 to the log file
    exec 3>&1 1>>"${LOG_FILE}" # 2>&1

    local remote_Host=$1
    # Storage Command
    commands_to_run='df -h'
    # If localhost is selected
    if [ "$1" == "localhost" ] ; then

        disk_stats=$(eval "$commands_to_run")
        # write to console and log
        echo -e "\nStorage:" | tee /dev/fd/3
        echo -ne "$disk_stats\n" | tee /dev/fd/3

     # if a remote host is selected and passed SSH test
    elif [ "$1" != "localhost" ] ; then
        # SSH and run command
        disk_stats=$(sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no mattt_admin@$remote_Host "$commands_to_run")
        # write to console and log
        echo -e "\nStorage:" | tee /dev/fd/3
        echo -ne "$disk_stats\n" | tee /dev/fd/3

   else
      # problems
        echo "Invalid remote host or unable to establish SSH connection."
        return 1
   fi

    # Restore the original stdout
    exec >&3 3>&-
}

# function to give networking bandwidth
# install vnstat

function Remote_Mon_Net () {

    # Redirect file descriptor 3 to the log file
    exec 3>&1 1>>"${LOG_FILE}" #2>&1

    local remote_Host=$1
    # Network Command
    commands_to_run='vnstat --days 1'
    # If localhost is selected
    if [ "$1" == "localhost" ] ; then

        net_stats=$(eval "$commands_to_run")
        # write to console and log
        echo -e "\nNetwork:" | tee /dev/fd/3
        echo -ne "$net_stats\n" | tee /dev/fd/3

    # if a remote host is selected and passed SSH test
    elif [ "$1" != "localhost" ] ; then
        # SSH and run command
        net_stats=$(sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no mattt_admin@$remote_Host "$commands_to_run")

        # write to console and log
        echo -e "\nNetwork:" | tee /dev/fd/3
        echo -ne "$net_stats\n" | tee /dev/fd/3

   else
      # problems
        echo "Invalid remote host or unable to establish SSH connection."
        return 1
   fi
    # Restore the original stdout
    exec >&3 3>&-
}

# Function to set the target host based on user input
function setTargetHost() {
    echo "Select monitoring type:"
    echo "1. Local"
    echo "2. Remote"
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            targetHost="localhost"
            CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
            # Start Logging
            echo -e "\nMonitoring Log for [$targetHost] on [$CURRENT_TIME]\n" >> "$LOG_FILE"
            ;;
        2)
            read -p "Enter the hostname for remote monitoring: " remoteHost
            targetHost="$remoteHost"
            echo "Password to use:"
            read -s SSHPASS # Get SSH PASSWORD
            export SSHPASS
            
            # Check SSH connection for remote host
            if sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no mattt_admin@"$targetHost" exit ; then
                CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
               #echo $CURRENT_TIME
                echo -e "\nMonitoring Log for [$targetHost] on [$CURRENT_TIME]\n" >> "$LOG_FILE"

            else

                echo "Invalid remote host or unable to establish SSH connection. Please try again."
                setTargetHost
            fi
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# menu function - select which parameters
function show_mon_menu() {
    echo -e "\nSelect options to run (comma-separated):"
    echo "1. Monitor CPU"
    echo "2. Monitor RAM"
    echo "3. Monitor Disks"
    echo "4. Monitor Network"
    echo "5. Back"
    echo "6. Exit"
}
# get target
setTargetHost
# menu Loop
while true; do

    show_mon_menu

    read -p "Enter your choices (1-6): " choices 

    IFS=',' read -ra selected_options <<< "$choices"

    for option in "${selected_options[@]}"; do
        case $option in
            1) Remote_Mon_Cpu "$targetHost";;
            2) Remote_Mon_RAM "$targetHost";;
            3) Remote_Mon_disks "$targetHost";;
            4) Remote_Mon_Net "$targetHost";;
            5)  
                widest_line_length=$(awk '{ if (length > max) max = length } END { print max }' "$LOG_FILE") # underline each LOG
                printf "%${widest_line_length}s" | tr ' ' '-' >> "$LOG_FILE"
                setTargetHost # Restart
                ;;
            6)  # under line and exit
                widest_line_length=$(awk '{ if (length > max) max = length } END { print max }' "$LOG_FILE")
                printf "%${widest_line_length}s" | tr ' ' '-' >> "$LOG_FILE"
                exit
                ;;
            *) echo "Invalid selection: $option" ;;
        esac
    done
done
# clear Password
unset SSHPASS