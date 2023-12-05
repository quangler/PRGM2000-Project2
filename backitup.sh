#!/bin/bash

#-------------------------------------
#| Author: Matt Telford               |
#| Class: PRGM2000                    |
#| Assignment: Project 2 Part 2       |
#| Title: Archive Function            |
#-------------------------------------

: '
a. Write a function that will be able to backup users’ local data and remote network share.
b. Specify the time a backup should occur via user input.
c. Log the date and time the backup process was completed to a log file called “Archive-Log”
'

LOG_FILE="/mnt/shared/logs/Archive-Log.txt"

# function to backup home dir and /mnt/shared share
backup_valuables() {

home_dir=$(eval echo "~")
shared_dir="/mnt/shared"
backup_dir="/mnt/backups"

tar -czvf "${backup_dir}"/$(date "+%Y-%m-%dT%H-%M-%S").tar.gz "${home_dir}"

if [[ $? -eq 0 ]]; then
    status="success"

    find "${service_backup_directory}" -mtime +8 -delete
else
    status="fail"
fi

}

function sch_Menu(){

echo "When to run the backup:"
    echo "1. Now"
    echo "2. Minutes"
    echo "3. Later Date"
    read -p "Enter your choice (1 - 3): " choice
    
    case $choice in
        1)
            echo "Creating backup..."
            backup_valuables
        ;;
        2)
            read -p "Enter the number of minutes from now to schedule the backup: " minutes
            at now + $minutes minutes <<EOF
                backup_valuables
EOF
            echo "Backup scheduled. You can check the status using the 'atq' command."
        ;;
        3)
            read -p "Enter the date to schedule the backup (YYYY-MM-DD): " backup_date
            read -p "Enter the time to schedule the backup (HH:MM): " backup_time
            at $backup_time $backup_date <<EOF
                backup_valuables
EOF
            echo "Backup scheduled. You can check the status using the 'atq' command."
        ;;
        *)

            exit 1
        ;;
    esac



}