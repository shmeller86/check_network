#/bin/bash

SERVER_IP=127.0.0.1
FILE=/etc/network/interfaces
BACKUP_FILE=$HOME/interfaces.backup
LAST_GOOD_UPDATE=0
OLDTIME=10

CURTIME=$(date +%s)
FILETIME=$(stat $FILE -c %Y)
TIMEDIFF=$(expr $CURTIME - $FILETIME)

if [ $FILETIME -gt $LAST_GOOD_UPDATE ]; then
    if [ $TIMEDIFF -gt $OLDTIME ]; then
        ping $SERVER_IP -c 5 2>&1 > /dev/null && RESULT=1 || RESULT=0
        if [ $RESULT -eq 1 ]; then
            echo -e '\033[1;32m'
            echo "The interface has been changed and after a while it works. We backup it"
            echo -e '\033[0m'
            sed -i "6s/LAST_GOOD_UPDATE=.*/LAST_GOOD_UPDATE=${FILETIME}/" ./check_network.sh
            cp $FILE $BACKUP_FILE
        else
            echo -e '\033[1;31m'
            echo "The interface has been changed and after a while it NOT works. We restore it"
            echo -e '\033[0m'
            cp $BACKUP_FILE $FILE
            FILETIME=$(stat $FILE -c %Y)
            sed -i "6s/LAST_GOOD_UPDATE=.*/LAST_GOOD_UPDATE=${FILETIME}/" ./check_network.sh
            systemctl restart networking.service
        fi
    fi
fi