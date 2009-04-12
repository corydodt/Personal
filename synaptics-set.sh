#!/bin/bash

# get the right synaptics device id
SYNID=`xinput list | perl -nle 'print $1 if m/.*synaptics.*\bid=(\d+).*/i'`
if [ -z "$SYNID" ]; then
    echo "** Could not find synaptics device" 1>&2; exit 1
fi

# enable tapping only on the top two corners.  LT for left click, RT for
# middle click.
#                                                 radix RT RB LT LB 1f 2f 3f
xinput set-int-prop $SYNID "Synaptics Tap Action" 8     2  3  1  0  0  2  3
echo "Done:"
echo "====="


xinput list-props $SYNID

