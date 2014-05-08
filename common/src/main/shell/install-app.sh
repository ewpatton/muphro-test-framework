#!/bin/bash

connect-device.sh

install() {
    echo "Installing application $1"
    RESPONSE=`adb install -r "$1" 2> /dev/null | sed 's/\r//g' | tail -n 1`
    echo "   $RESPONSE"
    [ "$RESPONSE" = "Success" ]
    return $?
}

startservice() {
    adb shell am startservice --user 0 -n "$1" > /dev/null
    BASELINE=`adb shell ps | grep muphro.baseline`
    echo "Baseline = $BASELINE"
    [ "$BASELINE" = "" ]
    return $?
}

enable_wakelock() {
    echo "Turning on phone screen for app transfer..."
    adb shell am broadcast -a com.evanpatton.muphro.baseline.MuphroBaselineService.ACTION_MANAGE_WAKELOCK --ez lock true > /dev/null
}

disable_wakelock() {
    echo "Turning off phone screen..."
    adb shell am broadcast -a com.evanpatton.muphro.baseline.MuphroBaselineService.ACTION_MANAGE_WAKELOCK --ez lock false > /dev/null
}

if [ ! -f "$1" ]; then
    echo "$1 is not a file."
    exit 4
fi

ADB=`which adb`
if [ "$ADB" = "" ]; then
    "No adb found."
    exit 1
fi

BASELINE_PKG=`adb shell pm list packages | grep muphro.baseline`
if [ "$BASELINE_PKG" = "" ]; then
    echo "MuphroBaseline package not installed. Attempting to install..."
    install MuphroBaseline.apk
    if [ $? -ne 0 ]; then
	echo "Unable to install MuphroBaseline service package."
	exit 2
    fi
fi

BASELINE=`adb shell ps | grep muphro.baseline`
if [ "$BASELINE" = "" ]; then
    echo "MuphroBaseline service not running. Attempting to start..."
    startservice "com.evanpatton.muphro.baseline/.MuphroBaselineService"
    if [ $? -eq 0 ]; then
	echo "Unable to start MuphroBaselineService."
	exit 3
    fi
fi

enable_wakelock
sleep 1
install $1
sleep 1
disable_wakelock

