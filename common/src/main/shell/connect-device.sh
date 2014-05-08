#!/bin/bash

usage() {
    echo "`basename $0` device[:port]..."
    echo "  where:"
    echo "    device    IP address or DNS-resolvable phone running ADB in TCP/IP mode"
    echo "    port      ADB port [default: 5555]"
}

is_connected() {
    adb shell exit 2>&1 > /dev/null
    CONNECTED=`adb devices | grep $1`
    if [ "$CONNECTED" != "" ]; then
	return 0
    else
	return 1
    fi
}

reconnect() {
    PORT=${2:-5555}
    echo "Sending ping to wake up WiFi connection..."
    ping -w 500 $1 > /dev/null
    echo "Reconnecting adb daemon..."
    CONNECTED=`adb connect $1:$PORT | grep connected`
    if [ "$CONNECTED" = "" ]; then
	echo "Unable to connect to device $1 on port $PORT. Aborting..."
	exit 2
    fi
    return 0
}

if [ $# -eq 0 -a "$ADB_DEVICE" = "" ]; then
    usage
    exit 1
fi

if [[ $# -eq 0 ]]; then
    if is_connected $ADB_DEVICE; then
	echo "Device already connected..."
    else
	reconnect $ADB_DEVICE
	echo "Success"
    fi
    exit 0
fi

while [ "$1" != "" ]; do
    echo $1
    IP=`echo $1 | cut -d':' -f 1`
    PORT=`echo $1 | cut -d':' -f 2`
    if [ "$PORT" = "" ]; then
	PORT=5555
    fi
    CONNECTED=`adb devices | grep $IP 2> /dev/null`
    if is_connected $IP; then
	echo "Device $IP is already connected..."
    else
	reconnect $1
    fi
    shift
done

echo "Success"
sleep 3
exit 0
