#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd $SCRIPT_DIR 2>&1 > /dev/null

expts=""
VEXDIR=../observed_vex/
for vexfile in `ls -1 $VEXDIR/*.vex`; do
    EXPT=${vexfile%.vex}
    expts="$expts ${EXPT##*/}"
done

# 230G
for expt in $expts; do
	for band in band1 band2 band3 band4; do
		clockfile=../templates/230G/$band/clocks_$expt.dat
		if [[ ! -f $clockfile ]]; then
			echo "Making empty $clockfile"
			echo "CLOCK" > $clockfile
			echo "# Station ID    Delay (usec)    Rate (sec/sec)" >> $clockfile
		else
			echo "Keeping existing $clockfile"
		fi
	done
done

popd 2>&1 > /dev/null
