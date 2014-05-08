#!/bin/bash
test="lubm"
install-app.sh PelletOnAndroid.apk
for query in {1..14}; do
    DATADIR="$test/pellet-partial/query$query"
    mkdir -p $DATADIR 2>&1 > /dev/null
    echo "Running query $query trials..."
    echo -n "  "
    for trial in {1..30}; do
	echo -n "$trial "
	run-test.sh com.evanpatton.pellet/.PelletTest $test $query >> tests.log 2>&1
	sleep 3
	if [ ! -f output.pt4 ]; then
	    cat .powermonitor.lastrun
	    exit 1
	fi
	mv output.pt4 $DATADIR/output-$trial.pt4
	mv output.csv $DATADIR/output-$trial.csv
	mv .adb.lastrun $DATADIR/adb-full-$trial.log
	mv adb.log $DATADIR/adb-results-$trial.log
	mv .powermonitor.lastrun $DATADIR/powermonitor-$trial.log
    done
    echo ""
done
