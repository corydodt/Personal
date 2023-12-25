# Media Center Runbook


## DOWNLOAD AND UNCOMPRESS

From the pve shell, via ssh,

```
wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
```


## CREATE A PLACEHOLDER VM

In the Proxmox VE management gui:

1. click [Create VM].

    - Note the VM ID on the next screen, e.g. `101`

2. Name it 'mediacenter'

3. OS > [Do not use any media]

4. Disks > Storage. Delete the default SCSI disk with the 🗑️ icon.

5. CPU > use 1 socket, 4 cores

6. Memory > 8192 MB

7. Confirm > Finish. Don't check "start after created", we will start it later


## MAKE IT AUTOSTART

Datacenter > pve > 101 (mediacenter) > Options > Start at Boot > [Start at Boot] > [OK]


## ENABLE QEMU GUEST AGENT

- Datacenter > pve > 101 (mediacenter) > Options > QEMU Guest Agent > [Use QEMU Guest Agent] 
- (Optional: Run guest-trim)
- [OK]


## CREATE DISK FROM PVE COMMAND LINE AND RESIZE

To attach the Rocky image as a disk of the VM,

1. ssh to root@pve.ip.address and then, in the pve shell:

    ```
    # - 101 is the VM ID from the previous section
    # - local-lvm is the name of a storage container
    # - the .qcow2 file is the disk image, and it must be uncompressed
    qm disk import 101 Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 local-lvm
    ```

2. Proxmox Datacenter > pve > 101 (mediacenter) > Hardware

3. Choose the new disk image in proxmox web, which will be labeled Unused Disk 0.

4. [Edit], check the settings, it should by default have SCSI 0 selected.  Just
click [Add]. This becomes **scsi0**.


## BOOT FROM SCSI

1. Datacenter > pve > 101 (mediacenter)

2. Options > Boot Order > [Edit]. Check [scsi0] and uncheck the others. [OK]


## PREPARE CLOUD-INIT TO MAKE LOGIN POSSIBLE

You must use the cloud-init system to provide a way to access the system.

- Datacenter > pve > 101 (mediacenter) > Hardware

- [Add] > CloudInit drive. Storage `local-lvm`. [Add]

- Switch to the Cloud-Init section. SSH public key > paste your public key.


## ATTACH FAST 2.5GBE NETWORK

- Datacenter > pve > 101 (mediacenter) > Hardware

- [Add] > Network Device. Bridge `vmbr1`, [Add]


## START THE VM

From 101 (mediacenter), click [> Start]


## IP SETUP AT THE ROUTER

The easiest way to get the LAN IP of the new Rocky VM is from the router, find the latest IP address assigned by DHCP. Make this assignment permanent.

**IP is currently 10.0.0.54**


## NAMECHEAP DNS A RECORD

- Add a Namecheap RR to the carrotwithchickenlegs.com zone, A 10.0.0.54 -> mediacenter


## ACCESS THE INSTANCE VIA SSH

SSH with `rocky@mediacenter.carrotwithchickenlegs.com` and the pubkey provided to cloud-init above.

### Podman setup
```
# install podman with other critical tools
sudo dnf install -y vim podman systemd-container git make lsof tree python3-pip podman-docker cifs-utils

# expose the socket interface to allow portainer to listen to container events
sudo systemctl enable --now podman.socket

# restartable containers can restart:
sudo systemctl enable podman-restart
```

- ```
  git config --global user.name cory
  git config --global user.email ...
  git config --global push.rebase true
  ```
  
- set up ~/.ssh/config and ~/.ssh/cory-aws-personal.pem

- clone repos
  ```
  mkdir src
  cd src
  git clone git@github.com:corydodt/pve.carrotwithchickenlegs.com.git
  git clone git@github.com:corydodt/Personal.git
  ```


## PORTAINER

1. Install the systemd service:

```
cd ~/src/pve.carrotwithchickenlegs.com/portainer
sudo install portainer.service /etc/systemd/system/portainer.service
sudo systemctl enable --now portainer
```

2. Set up admin at https://localhost:9443 (do this quickly, it times out).

3. Install the portainer cli:

```
make install

# if you don't have a keyring plugin for a secret manager installed, also do this:
make install-keyringrc
keyring set portainer admin
# (type the password for portainer admin from 1password)
```


## PODMAN NETWORK

Create a network for the containers to communicate
```
sudo podman network create --subnet 10.89.33.0/24 web-backends
```


## MOUNT CIFS STORAGE FROM PROXMOX

1. Datacenter > pve > 101 (mediacenter) > Hardware

- [Add] > Hard Disk. Storage `opt-qnap`. Disk size 29GB. [Add].

2. `lsblk` and confirm the new attached disk is `/dev/sdb`

3. **Caution: This will erase the NAS-mounted storage.** `mkfs.ext4 /dev/sdb`

4. Edit /etc/fstab and add:
```
/dev/sdb /opt ext4 defaults 0 0
```

5. Mount up
```
sudo systemctl daemon-reload
sudo mount -a
```


## CIFS MOUNTS

1. Edit /etc/fstab and add the following
```
# note: we cannot use a hostname like qnap.fast.carrotwithchickenlegs.com here without existing WINS name resolution
//10.0.69.1/media   /media   cifs defaults,credentials=/root/creds.txt 0 0
//10.0.69.1/backups /backups cifs defaults,credentials=/root/creds.txt 0 0
```

2. Create `/root/creds.txt` with contents:
```
username=cdodt
password=xxxxxx from 1password qnap
```

3. mount them
```
systemctl daemon-reload
mkdir -p /backups /media
mount -a
```


## NGINX

1. Prep:

    Edit ~/src/pve.carrotwithchickenlegs.com/nginx/conf.d/https_proxy 

    ```
    cd ~/src/pve.carrotwithchickenlegs.com/nginx
    make install
    ```

2. Install in portainer:

    ```
    make template
    make stack
    ```


## JELLYFIN

1. Prep:

    ```
    sudo chown -R rocky.rocky /opt
    ```

2. Install service in portainer:

    ```
    cd ~/src/pve.carrotwithchickenlegs.com/jellyfin
    make template
    make stack
    ```

3. Visit: http://mediacenter.carrotwithchickenlegs.com:8096


## SYNCTHING

```
cd ~/src/carrotwithchickenlegs.com/syncthing
make template
make stack
```


## GLUETUN (WIREGUARD)

Ensure these apps are installed and started on gigadrive:
- wireguard 
- ubuntu-ssh

From gigadrive ssh, obtain /storage/app/wireguard/peer1/peer1.conf.

Install secrets into podman that can be used by the container
```
# get these from peer1.conf
printf xxxxxxxxxxxxx | podman secret create wireguard-preshared-key -
printf xxxxxxxxxxxxx | podman secret create wireguard-private-key -
printf xxxxxxxxxxxxx | podman secret create wireguard-public-key -
```


Set up a container to autostart at boot:
```
# (tweak the .container file as necessary from peer1.conf, for endpoint ip & port, local addresses )
sudo install -o root -m 644 \
    ~/src/pve.carrotwithchickenlegs.com/gluetun-gigadrive.container \
    /usr/share/containers/systemd/
sudo systemctl daemon-reload; sudo systemctl start gluetun-gigadrive

# did it start?
systemctl status gluetun-gigadrive
# (should see healthy! in the log)

# best way to check:
sudo podman exec -it systemd-gluetun-gigadrive ping 10.13.13.1
```
