#!/bin/bash
#Quinn Parent - PRGM2000 - Project 2 Main Menu

BACK_PATH="~/backMenu.sh"
BACK_PATH=$(eval echo "$BACK_PATH")
MONITOR_PATH="~/monitoring.sh"
MONITOR_PATH=$(eval echo "$MONITOR_PATH")

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
                # function name for archival/backups
                /bin/bash "$BACK_PATH"
                MainMenu
                ;;
                2)
                # function name for monitoring system
                sudo /bin/bash "$MONITOR_PATH" # need sudo here cause its a powerful command you know?
                MainMenu
                ;;
                3)
                # function name for viewing logs
                ;;
                4)
                # function name for viewing network devices
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

MainMenu    # runs main menu function