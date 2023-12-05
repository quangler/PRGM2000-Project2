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

    # backup home data and send any error code to tar_error
    tar_error1=$(tar -czvf "${backup_dir}"/home_backup_$(date "+%Y-%m-%dT%H-%M-%S").tar.gz "${home_dir}" 2>&1)

    if [[ $? -ne 0 ]]; then
        # problems
        echo "Backing up Home Directory failed, See log for details"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Home Data backup failed with the following error: $tar_error1" >> LOG_FILE
    else
        # success
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Home Data backup successful" >> LOG_FILE
        # find files over 8 days old and deletes them (this would be to stop backup drive from filling up with old copies)
        find "${backup_dir}" -name 'home_backup*' -mtime +7 -delete
    fi

    # backup home data and send any error code to tar_error
    tar_error2=$(tar -czvf "${backup_dir}"/share_backup_$(date "+%Y-%m-%dT%H-%M-%S").tar.gz "${shared_dir}" 2>&1)

    if [[ $? -ne 0 ]]; then
        # problems
        echo "Backing up Share Directory failed, See log for details"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Share Data backup failed with the following error: $tar_error2" >> LOG_FILE
    else
        # success
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Share Data backup successful" >> LOG_FILE
        # find files over 8 days old and deletes them (this would be to stop backup drive from filling up with old copies)
        find "${backup_dir}" -name 'share_backup*' -mtime +7 -delete
    fi
}

function sch_Menu(){

echo "When to run the backup:"
    echo "1. Now"
    echo "2. Minutes"
    echo "3. Later Date"
    echo "4. Cancel"
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
        4)
            exit 1

        ;;
        *)
            echo "Invalid choice. Try again."
            sch_Menu
        ;;
    esac
}

sch_Menu