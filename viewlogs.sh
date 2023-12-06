#Quinn Parent - PRGM2000 - Project 2 log viewer
#! /bin/bash

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

SelectPath
ViewLogs