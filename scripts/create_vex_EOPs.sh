#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTDIR=../templates/common_sections/

pushd $SCRIPT_DIR  2>&1 > /dev/null

./geteop.pl 2022-23  5 $OUTDIR/eop_e22j25.vex
./geteop.pl 2022-24  5 $OUTDIR/eop_e22j26.vex

./geteop.pl 2022-74  5 $OUTDIR/eop_e22g18.vex
./geteop.pl 2022-76  5 $OUTDIR/eop_e22b19.vex
./geteop.pl 2022-77  5 $OUTDIR/eop_e22c20.vex

popd  2>&1 > /dev/null

