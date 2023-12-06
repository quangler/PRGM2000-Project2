#!/bin/bash

#-------------------------------------
#| Author: Matt Telford               |
#| Class: PRGM2000                    |
#| Assignment: Project 2 Part 2       |
#| Title: Archive Menu                |
#-------------------------------------


BACK_PATH="./backitup.sh"
LOG_FILE="/mnt/share/logs/Archive-Log.txt"

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
            source "$BACK_PATH"
            if [[ $? -eq 0 ]]; then
            echo "Complete"
            else
            echo "Backup failed"
            fi
        ;;
        2)
            read -p "Enter the number of minutes from now to schedule the backup: " minutes
            at now + $minutes minutes <<EOF >> "$LOG_FILE" 2>&1
                source "$BACK_PATH"
EOF
            echo "Backup scheduled. You can check the status using the 'atq' command."
        ;;
        3)
            read -p "Enter the date to schedule the backup (YYYY-MM-DD): " backup_date
            read -p "Enter the time to schedule the backup (HH:MM): " backup_time
            at $backup_time $backup_date <<EOF >> "$LOG_FILE" 2>&1
                source "$BACK_PATH"
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