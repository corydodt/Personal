#!/bin/bash

set -e

createRules() {
    for f in /etc/firewall.d/*.conf; do
        . $f
    done

    touch /etc/firewall.d/timestamp
}

missingTimestamp() {
    test ! -e /etc/firewall.d/timestamp
}

modifiedFirewallFiles() {
    [ `find /etc/firewall.d -newer /etc/firewall.d/timestamp | wc -l` != '0' ]
}

outOfDate() {
    # 0 (success) if any files are newer than the timestamp, meaning a
    # firewall update is required. Also returns 0 if no timestamp exists.
    missingTimestamp || modifiedFirewallFiles
}

if [ "$1" = "timestamp" ]; then
    outOfDate 
else
    createRules
fi

