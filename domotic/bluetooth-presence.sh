#!/bin/bash
#Goal: Detect presence thanks to à Bluetooth device (cellphone, smartwatch, beacon, headset,...).
#Source: http://clement.storck.me/blog/2016/02/detection-de-presence-en-bluetooth/

COUNTPRESENT='0'
COUNTABSENT='0'
DATESPECIFIC=$(date "+%d/%m/%Y,%H:%M:%S")
LOGFILE='/home/pi/domotic/bluetooth-presence.sh.log'
OWNER='06xxxxxxxx' #Cellphone number
CAMIP='xxx.xxx.xxx.xxx'
CAMAUTHCODE=''

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
                #echo "$(date) - "$2" is present"
                echo $DATESPECIFIC","$2",present" >> $LOGFILE
                #/home/pi/jarvis/jarvis.sh -s "Welcome $2" #Ask Jarvis (domotic assistant) to welcome the user vocally
                curl "http://$CAMIP/setSystemMotion" -H "Host: $CAMIP" -H "Referer: http://$CAMIP/setSystemMotion" -H "Authorization: Basic $CAMAUTHCODE" -H "Connection: keep-alive" -H "Upgrade-Insecure-Requests: 1" --data "ReplySuccessPage=motion.htm&ReplyErrorPage=motion.htm&MotionDetectionEnable=0&MotionDetectionScheduleDay=127&ConfigSystemMotion=Save" >/dev/null 2>&1
                echo $DATESPECIFIC","$2",SwitchOFF" >> $LOGFILE
                echo $2" arrived at home since $(date)" | gammu sendsms TEXT $OWNER #Send an SMS to the house owner, thanks to a 3G dongle and gammu program
        fi

        if [[ "$COUNTABSENT" = 3 ]] # We need 3 confirmations to be sure device is really away
        then
                # Do something here
                COUNTPRESENT=0
                #echo "$(date) - "$2" is away"
                echo $DATESPECIFIC","$2",away" >> $LOGFILE
                curl "http://$CAMIP/setSystemMotion" -H "Host: $CAMIP" -H "Referer: http://$CAMIP/setSystemMotion" -H "Authorization: Basic $CAMAUTHCODE" -H "Connection: keep-alive" -H "Upgrade-Insecure-Requests: 1" --data "ReplySuccessPage=motion.htm&ReplyErrorPage=motion.htm&MotionDetectionEnable=1&MotionDetectionScheduleDay=127&MotionDetectionScheduleMode=0&MotionDetectionSensitivity=70&ConfigSystemMotion=Save" >/dev/null 2>&1
                echo $DATESPECIFIC","$2",SwitchOFF" >> $LOGFILE
                echo $2" is gone since $(date)" | gammu sendsms TEXT $OWNER #Send an SMS to the house owner, thanks to a 3G dongle and gammu program
        fi

    #echo "$(date) - confirmation presence: $COUNTPRESENT"
    #echo "$(date) - confirmation absence: $COUNTABSENT"
    sleep $3
done
