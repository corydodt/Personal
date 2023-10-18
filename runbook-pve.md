# Runbook

Installing minisforum server from proxmox + bookworm

- Install proxmox ve 8 (amd64) from usb drive
    - mashing the delete key will get you into bios
    - set the usb drive above bios and hard drive temporarily
    - choose graphical install and let it complete
    - at reboot, mash delete to get into bios, swap drive order again and remove usb

### post-boot textmode font fix (optional)
- dpk-reconfigure -plow console-setup
    - choose UTF-8, latin 1-5, TerminusBold, 32x16

## NETWORKING

- During installation, you will have accessed the network via the wan router. Make a permanent DHCP reservation for the computer, and remember the IP.

    **Currently using IP 10.0.0.25 for wifi**

- Copy these packages from debian bookworm:
    - libiw30_*
    - wireless-tools_*
    - wpasupplicant_*
    - libnl-genl-3-200_*
    - libpcsclite1_*
    - iw_*
    - vim_*
    - vim-runtime_*
    - libsodium23_*
    - libgpm2_*
    - parted_*

- Install the above packages with dpkg -i

- Temporarily set up /etc/network/interfaces like this:

    ```
    auto lo
    iface lo inet loopback

    auto wlp4s0
    iface wlp4s0 inet static
        address 10.0.0.25/24
        gateway 10.0.0.1
        pre-up wpa_supplicant -i wlp4s0 -c /etc/wpa_supplicant/wpa_supplicant.conf -B -f /var/log/wpa_supplicant.log

    ## TEMPORARILY COMMENTED OUT
    ## auto vmbr0
    ## iface vmbr0 inet static
    ## 	address 10.0.0.25/24
    ## 	gateway 10.0.0.1
    ## 	bridge-ports enp2s0
    ## 	bridge-stp off
    ## 	bridge-fd 0

    iface enp2s0 inet manual

    iface enp3s0 inet manual
    ```

    Then run:
    ```
    # from a root prompt
    ip link set dev wlp4s0 up
    iwlist wlp4s0 scan | grep ESSID
    wpa_passphrase "Cicindela chinensis" "your-wifi-passphrase" | tee -a /etc/wpa_supplicant/wpa_supplicant.conf
    wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp4s0

    # iwconfig at this point should show the device talking to the AP

    ifup wlp4s0

    # `ip a` here should show the interface using the ip you assigned
    ```

- Reboot to confirm it keeps these network settings

- _Now_ uncomment vmbr0 in /etc/network/interfaces
- Reserve the next IP in DHCP

    **Currently 10.0.0.26 for the proxmox bridge over ethernet**

- Plug in an ethernet cable

- Run `ifup vmbr0`


## CLEAN UP REPOSITORIES

- in proxmox gui: 
    - Server View > Datacenter > (server hostname) > Updates > Repositories
    - [Add], choose non-subscription
    - disable ceph repo and enterprise repo


## GENERAL USAGE

### Install Software

```
apt install git \
    dig \
    =====
```

### Secure SSH access

- log in as root with your specified password
- create `.ssh/authorized_keys` with your key
- Add the following to `.ssh/config`

    ```
    Host github.com
        User git
        IdentityFile ~/.ssh/cory-aws-personal.pem
    ```

- Grab `cory-aws-personal.pem` from 1password

### Git

```
git config --global user.name "Cory Dodt"
git config --global user.email "corydodt@fastmail.com"
```

## STORAGE

- Attach external sdd via usb-c cable
- Run `lsblk` and make sure you know which device is the sd drive

    #### Using /dev/sda for the external drive

- Run:
    ```
    apt install parted

    # Be sure you know what you're doing! This will wipe the drive.
    parted /dev/sda mklabel gpt
    parted -a opt /dev/sda mkpart zfs 0% 100%
    ```

- in proxmox gui, go to:
    - Server View > Datacenter > (server name) > Disks > ZFS
    - [Create: ZFS], enter a name and choose /dev/sda1, then Create

## CREATE A VM

- Download some VM disk images, e.g.
    - https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
    - https://github.com/home-assistant/operating-system/releases/download/11.0haos_ova-11.0.qcow2.xz

    - Make sure to uncompress if the image is compressed.

    - Follow steps in runbook-hass.md
