#!/bin/bash
wget -q "http://agentrepo.drivesrvr.com/debian/agentrepo.key" -O- | apt-key add -
echo "deb [arch=amd64] http://agentrepo.drivesrvr.com/debian/ serveragent main" > /etc/apt/sources.list.d/driveclient.list
