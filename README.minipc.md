## installation

- install from usb media - server is fine, be sure to include container runtimes
- choices during install:
    - ethernet: set up 10.69.69.2 with no gateway and check "never default route", and select 'enable' toggle button
    - wifi: setup umbonia with WPA2 password, and select 'enable' toggle button
        - n.b.: the installer DOES NOT INSTALL NetworkManager-wifi so we need to take special steps to enable wifi
        - it does remember the settings you used here, though

## networking
- manually download from http://dl.rockylinux.org/pub/rocky/8.6/BaseOS/x86_64/os/Packages/
    - c/crda-3.18_2020.04.29-1.el8.noarch.rpm
    - i/iw-4.14-5.el8.x86_64.rpm
    - n/NetworkManager-1.36.0-7.el8_6.x86_64.rpm
    - n/NetworkManager-libnm-1.36.0-7.el8_6.x86_64.rpm
    - n/NetworkManager-team-1.36.0-7.el8_6.x86_64.rpm
    - n/NetworkManager-tui-1.36.0-7.el8_6.x86_64.rpm
    - n/NetworkManager-wifi-1.36.0-7.el8_6.x86_64.rpm
    - w/wpa_supplicant-2.10-1.el8.x86_64.rpm
- copy over with scp, install these with `rpm -iU *.rpm`
    - reboot, so NetworkManager picks up the wifi
    - `nmcli c` should show both connections bound to a device (not blank) 
    - if necessary edit the wifi connection with `nmcli c edit umbonia`:
        - `print connection` to show settings
        - set connection.interface-name to the <wifi-device> 
        - set connection.autoconnect yes
        - `sudo systemctl restart NetworkManager`
        - reboot again if still not connected

## ssh
- manually scp .ssh directory from a workstation that has one. make sure
    permissions are correct and authorized_keys exists

## firewall
- disable firewalld, which blocks connections via podman into our containers:
    `sudo systemctl disable firewalld && sudo systemctl stop firewalld`

## containers

### ON THE SERVER
```
systemctl --user enable --now podman.socket
pip3 install --user podman-compose
```

- `git clone Personal.git`
- `cd Personal; make -C vscode-env`
    - after building, copy the startup command line (beginning `podman run...`)

- scp cdodt.tar.gz onto the server
```
podman volume create cdodt
gzip -dc cdodt.tar.gz | podman volume import cdodt -
```

- run the container according to the printed CL
```
# example, edit this
podman run \
    -dit --name=aero-dev-202208051634 --hostname=aero-dev-202208051634 \
    --mount type=volume,src=cdodt,dst=/home/cdodt \
    --device /dev/net/tun --cap-add=NET_ADMIN \
    -p 192.168.0.36:2222:22 -p 10.69.69.2:2222:22 \
    --restart=always \
    -t vscode-env:20 \
    bash
```

### IN THE CONTAINER
```
podman system connection add --identity ~/.ssh/blah..pem minipc 10.69.69.2
podman -r info
podman -r ps
...
```

## other packages
- install:
    - lsof
    - python39{,-devel}

- `systemctl enable-linger cdodt`

## openvpn support

- selinux prevents guest containers from accessing /dev/net/tun. disable selinux:
    - edit /etc/selinux/config
    - set `SELINUX=disabled` 
    - reboot
