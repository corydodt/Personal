# Media Center Runbook


## DOWNLOAD AND UNCOMPRESS

From the pve shell, via ssh,

```
wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
```


## CREATE A ZFS STORAGE CONTAINER

In the Proxmox VE management gui:

1. Datacenter > Storage > [Add] > ZFS

2. Here, ID is the name, name it **media-center**

3. ZFS Pool: "vm-disks"

4. [Add]


## CREATE A PLACEHOLDER VM

In the Proxmox VE management gui:

1. click [Create VM].

    - Note the VM ID on the next screen, e.g. `101`

2. Name it 'mediacenter'

3. OS > [Do not use any media]

4. Disks > Storage > `media-center`. 32GB default is fine.

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

- ssh to root@pve.ip.address and then, in the pve shell:

    ```
    # - 101 is the VM ID from the previous section
    # - media-center is the name of a storage container
    # - the .qcow2 file is the disk image, and it must be uncompressed
    qm disk import 101 Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 media-center
    ```

To swap the VM's placeholder storage for the new disk image:

- In Proxmox VE mgmt gui,

    1. Datacenter > pve > 101 (mediacenter)
    
    2. If the VM is running, Shutdown > [Stop]

    3. Go to Hardware panel. You should see two Hard Disks (scsi0 and Unused Disk 0).

    4. Choose the empty placeholder disk, which will be `scsi0`. Click [Detach] > [Yes]. This becomes **Unused Disk 1**.

    5. Choose the empty placeholder disk which is now Unused Disk 1. [Remove] > [Yes].

    6. Choose the new disk image, which will be labeled Unused Disk 0.

    7. [Edit], check the settings, it should by default have SCSI 0 selected.
    Just click [Add]. This becomes **scsi0**.

    8. [Disk Action] > Resize. Enter `3000` GiB, [Resize disk]


## BOOT FROM SCSI

1. Datacenter > pve > 101 (mediacenter)

2. Options > Boot Order > [Edit]. Check [scsi0] and uncheck the others. [OK]


## PREPARE CLOUD-INIT TO MAKE LOGIN POSSIBLE

You must use the cloud-init system to provide a way to access the system.

- Datacenter > pve > 101 (mediacenter) > Hardware

- [Add] > CloudInit drive. Storage `media-center`, [Add]

- Switch to the Cloud-Init section. SSH public key > paste your public key.


## START THE VM

From 101 (mediacenter), click [> Start]


## IP SETUP AT THE ROUTER

The easiest way to get the LAN IP of the new Rocky VM is from the router, find the latest IP address assigned by DHCP. Make this assignment permanent.

**IP is currently 10.0.0.69**


## NAMECHEAP DNS A RECORD

- Add a Namecheap RR to the carrotwithchickenlegs.com zone, A 10.0.0.69 -> mediacenter


## ACCESS THE INSTANCE VIA SSH

SSH with `rocky@mediacenter.carrotwithchickenlegs.com` and the pubkey provided to cloud-init above.

- ```
  sudo dnf install -y vim podman systemd-container git make cifs-utils
  mkdir src
  cd src
  # fixme - set up ~/.ssh/cory-aws-personal.pem
  git clone git@github.com:corydodt/pve.carrotwithchickenlegs.com.git
  git clone git@github.com:corydodt/Personal.git
  ```


## PORTAINER

```
systemctl enable --now podman.socket
cd ~/src/pve.carrotwithchickenlegs.com/portainer
```

Install the systemd service:

```
sudo install portainer.service /etc/systemd/system/portainer.service
sudo systemctl enable --now portainer
```

Set up restartable containers to always restart:

```
sudo systemctl enable podman-restart
```

Install the portainer cli:

```
make install

# if you don't have a keyring plugin for a secret manager installed, also do this:
    make install-keyringrc

keyring set portainer admin
# (type the password for portainer admin from 1password)
```

Set up admin at https://localhost:9443 (do this quickly, it times out).

XXX TODO: CREATE web-backends NETWORK


## NGINX

1. Prep:

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
    sudo mkdir -P /opt/jellyfin/{cache,config}
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


## GLUETUN (WIREGUARD) (FIXME - PORTAINER)

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
