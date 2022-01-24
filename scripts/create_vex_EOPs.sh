#!/bin/bash
#
# e22j25.vex:     exper_nominal_start=2022y025d04h10m00s;
# e22j26.vex:     exper_nominal_start=2022y026d04h06m00s;

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTDIR=../templates/common_sections/

pushd $SCRIPT_DIR

./geteop.pl 2022-23  5 $OUTDIR/eop_e22j25.vex
./geteop.pl 2022-24  5 $OUTDIR/eop_e22j26.vex

popd

