# fixed ip setup

## create digitalocean account

- create digitalocean account (github login, need cc#)


## create a warpspeed droplet

- (sidebar) droplets > [create droplet]
- region = san francisco
- choose an image > marketplace > warpspeed
- sizing: basic/regular/$6 tier
- add ssh pubkey
- [create droplet]

- (sidebar) droplets > [warpspeedvpnxxxx..]
- networking > reserved ip > [enable now] > [assign reserved ip]
- networking ... firewalls > [edit]
	- [create firewall]
	- along with default ssh, add http + https + custom 51820/udp
	- assign to warpspeed droplet
	- [create firewall]


## run the warpspeed installer

- ssh to the droplet's ip as root@ip

- [y] to run installer (or `/usr/local/bin/warpspeed-installer.sh`)

- click the link printed at the end of the installer and log in with the email you chose
and the password that was printed.

- > Management, set a new password, [Save]

- > Users, create a new user and send invite

- Follow the invite link from your email, create a new password

- [Add Device], name = acme-renewer, type = Linux

....
