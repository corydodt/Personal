SHELL = /usr/bin/bash

VERSION 		 = 22
USER_UID		 = 1000
USER_GID		 = $(USER_UID)

WIFI_IP 		 = 192.168.0.36
FAST_IP 		 = 10.69.69.2
AERO_PORT 		 = 2222
DECIBELDUCK_PORT = 2269


all:
	podman build \
		--build-arg LABEL=vscode-env:$(VERSION) \
		--build-arg USERNAME=$(USER) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		--tag vscode-env:$(VERSION) \
		--tag vscode-env:latest \
		.

aero-up:
	podman run \
		-dit --name=aero-dev --hostname=aero-dev \
		--mount type=volume,src=cdodt,dst=/home/cdodt \
		--device /dev/net/tun --cap-add=NET_ADMIN \
		-p $(WIFI_IP):$(AERO_PORT):22 -p $(FAST_IP):$(AERO_PORT):22 \
		--restart=always \
		vscode-env:latest \
		bash
	sleep 3; podman ps -a

decibelduck-up:
	podman run \
		-dit --name=decibelduck-dev --hostname=decibelduck-dev \
		--mount type=volume,src=cdodt,dst=/home/cdodt \
		--device /dev/net/tun --cap-add=NET_ADMIN \
		-p $(WIFI_IP):$(DECIBELDUCK_PORT):22 -p $(FAST_IP):$(DECIBELDUCK_PORT):22 \
		--restart=always \
		vscode-env:latest \
		bash
	sleep 3; podman ps -a
