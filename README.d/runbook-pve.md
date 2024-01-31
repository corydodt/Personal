# Runbook

### Installing minisforum server from proxmox + bookworm

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

    **Currently 10.0.0.97 for the proxmox bridge over ethernet**

- Plug in an ethernet cable

- Run `ifup vmbr0`

#### XXX currently wifi does not start at boot ???


## CLEAN UP REPOSITORIES

- in proxmox gui: 
    - Server View > Datacenter > (server hostname) > Updates > Repositories
    - [Add], choose No-Subscription
    - disable ceph repo and enterprise repo


## GENERAL USAGE

### Install Software

```
apt install git \
    dig \
    whois
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

    **Using /dev/sda for the external drive**

- Run:
    ```
    apt install parted

    # Be sure you know what you're doing! This will wipe the drive.
    parted /dev/sda mklabel gpt
    parted -a opt /dev/sda mkpart zfs 0% 100%
    ```

- in Proxmox VE gui, go to:
    - Server View > Datacenter > (server name) > Disks > ZFS
    - [Create: ZFS], enter a name e.g. **vm-disks** and choose /dev/sda1, then [Create]


## CREATE HOME ASSISTANT VM

- Follow steps in runbook-hass.md


## CREATE MEDIA CENTER VM

- Follow steps in runbook-mediacenter.md



## CREATE IMMICH VM

- ??? TODO


## TLS CERTIFICATE AND DNS

### (1-time, already complete) At namecheap...

- Domain List > carrotwithchickenlegs.com > [Manage] > Nameservers > select [Namecheap Basic DNS]

- carrotwithchickenlegs.com > Advanced DNS
    - (nothing to do here right now, but you will visit this panel again for each VM)


### Set PVE to retrieve a certificate for *.carrotwithchickenlegs.com

Because we are using a wildcard certificate this will not use the builtin GUI.

- Using root@10.0.0.97 (via ssh), install acme.sh
    - `curl https://get.acme.sh | sh -s email=yellow.tree5340@fastmail.com`
    - Note: this updates .bashrc and also installs an entry in root's crontab,
    check with `crontab -l`

- Create a Namecheap API key
    - https://namecheap.com
    - Profile > Tools > Business & Dev Tools > Namecheap API access
    - You will need to turn on (already done)
    - [Manage]
    - API Key > Create or [Reset] API key
    - Whitelisted IPs > [Edit], add your home IP

- Issue a staging cert as a test, and to store namecheap keys in `~/.acme.sh/account.conf`
    ```
    # Documentation at https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_namecheap
    export NAMECHEAP_API_KEY='(fetch from namecheap > Profile > Tools .... API Key)'
    export NAMECHEAP_USERNAME='corydodt'
    export NAMECHEAP_SOURCEIP='https://ifconfig.co/ip'
    export PUSHBULLET_TOKEN='xxxx from 1password "pushbullet api"'

    # `--force` might also be used to test
    acme.sh --staging --issue -d '*'.carrotwithchickenlegs.com --dns dns_namecheap --set-notify --notify-hook pushbullet
    ```

- Install https://github.com/corydodt/pve.carrotwithchickenlegs.com/blob/main/acme-reloadcmd.sh to
  /root/acme-reloadcmd.sh

- When staging is confirmed, issue a production cert
    ```
    acme.sh --issue -d '*'.carrotwithchickenlegs.com --dns dns_namecheap --reloadcmd /root/acme-reloadcmd.sh --set-notify --notify-hook pushbullet
    ```
