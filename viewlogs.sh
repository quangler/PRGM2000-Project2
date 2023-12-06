#Quinn Parent - PRGM2000 - Project 2 log viewer
#! /bin/bash

SelectPath(){
# selecting path function
    SELECTEDLOGPATH="/mnt/share/logs/" # default log path
    echo -n "Where are the logs you want to view? (Default - /mnt/share/logs/): "
    read LOGPATH    # user log path input
    if [ -z "$LOGPATH" ]    # checks to see if user just hit enter
        then echo "Default path selected."
        elif [ -d "$LOGPATH" ] || [[ "$LOGPATH" == */ ]] # checks if path user entered exists
            then echo "Path is functional. ($LOGPATH)"
            SELECTEDLOGPATH="$LOGPATH"  # sets the selected pth to user path
        else echo "Log path doesn't exist. Defaulting to /mnt/share/logs/"
    fi
}

ViewLogs(){
# viewing logs function
    while IFS= read -r LOGFILE; # reads the files in the directory
    do LOGFILEARRAY+=("$LOGFILE")
    done < <(ls "$SELECTEDLOGPATH")
    # echo ${LOGFILEARRAY[@]} # showing the output of the array for testing
    FILEPOS=0   # sets counter to 0
    echo "There are ${#LOGFILEARRAY[@]} files to read."
    for FILE in ${LOGFILEARRAY[@]}
        do ((FILEPOS++))
        echo "$FILEPOS. $FILE"
    done
    echo "Please enter the file you would like to interact with. (q to quit): "
    read -r USERLOGSELECTION
    if [ $USERLOGSELECTION = "q" ]
        then echo "Quitting back to menu"
        # ADD MENU GO BACK PART HERE --------------------------------------------------129837198273981729381729837918273981723
        elif [ "$USERLOGSELECTION" -gt ${#LOGFILEARRAY[@]} ] || [ "$USERLOGSELECTION" -le 0 ]
            then echo -e "Sorry, your selection ($USERLOGSELECTION) is not valid. (Choice must be between 1-${#LOGFILEARRAY[@]}.) \n Try again."
            ViewLogs
        elif ! [[ "$USERLOGSELECTION" =~ ^[0-9]+$ ]]
            then echo -e "Sorry, you should have entered only a number or 'q'. \n Try again."
            ViewLogs
        else echo "You have selected ${#LOGFILEARRAY[$USERLOGSELECTION]}. \nWhat would you like to do with this file? \n[1] View this log \n[2] Delete this log \n[q] Go back"
        read -r LOGOPTIONS
        if "$LOGOPTIONS" -eq 1
            then $(cat $SELECTEDLOGPATH${LOGFILEARRAY[$USERLOGSELECTION]})
            #GO BACK TO MENU HERE
        elif "$LOGOPTIONS" -eq 2
            then $(rm $SELECTEDLOGPATH${LOGFILEARRAY[$USERLOGSELECTION]})
            #GO BACK TO MENU HERE
        elif [ "LOGOPTIONS" = 'q' ]
            then echo "Quitting back to menu"
            #GO BACK TO MENU HERE
}

SelectPath
ViewLogs