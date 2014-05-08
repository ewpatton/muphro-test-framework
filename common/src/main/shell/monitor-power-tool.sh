#!/bin/bash

usage() {
    echo "`basename $0` pid logfile component"
    echo "  where:"
    echo "    pid"
    echo "    logfile"
    echo "    component"
}

running() {
#    RUNNING=`ps aux | grep $1`
    EXITED=`grep 'Exit Code' $2`
    [[ "$EXITED" == "" ]]
    return $?
}

if [ $# -ne 3 ]; then
    usage
    exit 1
fi

PID="$1"
LOG="$2"
COMPONENT="$3"
ADB_LASTRUN=".adb.lastrun"

echo "Monitoring PowerToolCmd with PID $PID"
sleep 15
HAS_TRIGGER=`grep -i trigger $LOG`
if [ "$HAS_TRIGGER" = "" ]; then
    echo "Trigger not observed. Assuming application did not start."
    kill $PID
    adb logcat -d > $ADB_LASTRUN
    PID=`grep "$COMPONENT" $ADB_LASTRUN | grep "pid=" | perl -ne 'if ( $_ =~ /pid=([^ ]*)/ ) { print $1 }'`
    echo "App failed due to exception or error"
    echo "    `grep "$PID):" .adb.lastrun | grep -E 'Exception|Error'`"
    exit 3
fi

# trigger observed. monitor for quit
while running $PID $LOG; do
    sleep 1
done

connect-device.sh
adb logcat -d > $ADB_LASTRUN

exit 0
