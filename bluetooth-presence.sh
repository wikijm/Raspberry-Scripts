#!/bin/bash
#Goal: Detect presence thanks to à Bluetooth device (cellphone, smartwatch, beacon, headset,...).
#Source: http://clement.storck.me/blog/2016/02/detection-de-presence-en-bluetooth/

COUNTPRESENT=0
COUNTABSENT=0

while true
do
    DEVICE=`hcitool name $1`
    
    if [[ $DEVICE = $2 ]]
    then
        COUNTPRESENT=$((COUNTPRESENT+1))
    else
        COUNTABSENT=$((COUNTABSENT+1))
    fi
        if [[ "$COUNTPRESENT" = 1 ]] # 1 confirmation is OK to be sure device is here
        then
                # Do something here
                COUNTABSENT=0
                echo "$(date) - "$2" est présent"
        fi

        if [[ "$COUNTABSENT" = 3 ]] # We need 3 confirmations to be sure device is really away
        then
                # Do something here
                COUNTPRESENT=0
                echo "$(date) - "$2" est absent"
        fi

    echo "$(date) - confirmation presence: $COUNTPRESENT"
    echo "$(date) - confirmation absence: $COUNTABSENT"
    sleep $3
done
