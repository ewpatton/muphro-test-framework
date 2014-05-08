#!/bin/bash

export PATH="/cygdrive/c/Program Files/Monsoon Solutions Inc/Power Monitor:$PATH"
ADB=`which adb`

if [ "$ADB" = "" ]; then
    echo "Unable to find adb. Ensure the Android platform-tools are on PATH."
    exit 2
fi

connect-device.sh

PWM_LASTRUN=.powermonitor.lastrun
ADB_LASTRUN=.adb.lastrun

usage() {
    echo "`basename $0` component test query"
    echo "  where:"
    echo "    component  An Android component identifier"
    echo "    test       Test name to run"
    echo "    query      Identifier of the query to execute"
}

echo "Clearing adb log"
adb logcat -c
echo "Starting component"
adb shell am start -n "$1" --es test "$2" --ei queryId "$3"

echo "Sleeping to let WiFi cool down..."
sleep 8

> $PWM_LASTRUN
echo "Starting power data collection..."
PowerToolCmd.exe /NoExitWait /KeepPower /Trigger=CBA900B500TYEBB20A500 /SaveFile=output.pt4 2>&1 | tee -a $PWM_LASTRUN &
monitor-power-tool.sh $! $PWM_LASTRUN $1

if [ $? -eq 0 ]; then
    echo "Dumping adb logcat output..."
    grep 'Experiment' $ADB_LASTRUN > adb.log
    if [ ! -s adb.log ]; then
	echo "No data found in adb log. Possible exception or error below:"
	echo "    `grep -E 'Exception|Error' $ADB_LASTRUN`"
	rm output.pt4 output.csv
    fi
    exit 0
fi
