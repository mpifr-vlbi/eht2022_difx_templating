#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd $SCRIPT_DIR   2>&1 > /dev/null

expts=""
VEXDIR=../observed_vex/
for vexfile in `ls -1 $VEXDIR/*.vex`; do
    EXPT=${vexfile%.vex}
    expts="$expts ${EXPT##*/}"
done

for expt in $expts; do
	for band in 1 2 3 4; do
		notesfile=../templates/230G/band$band/notes_$expt.v2d
		if [[ ! -f $notesfile ]]; then
			echo "Making initial $notesfile"
			echo "# Track $expt band $band" > $notesfile
			echo "# Notes: ..." >> $notesfile
		else
			echo "Keeping existing $notesfile"
		fi
	done
done

popd   2>&1 > /dev/null

