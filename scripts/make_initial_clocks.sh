#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd $SCRIPT_DIR

# 230G
for expt in e22j25 e22j26; do
	for band in band1 band2 band3 band4; do
		clockfile=../templates/230G/$band/clocks_$expt.dat
		if [[ ! -f $clockfile ]]; then
			echo "Making empty $clockfile"
			echo "CLOCK" > $clockfile
			echo "# Station ID    Delay (usec)    Rate (usec)" >> $clockfile
		fi
	done
done

# 345G
#for expt in e21f19; do
#	for band in band1 band2 band3 band4; do
#		clockfile=../templates/345G/$band/clocks_$expt.dat
#		if [[ ! -f $clockfile ]]; then
#			echo "Making empty $clockfile"
#			echo "CLOCK" > $clockfile
#			echo "# Station ID    Delay (usec)    Rate (usec)" >> $clockfile
#		fi
#	done
#done

popd

