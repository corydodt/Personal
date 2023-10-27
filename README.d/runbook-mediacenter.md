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


## Enable QEMU Guest Agent

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


## PREPARE CLOUD-INIT TO MAKE LOGIN POSSIBLE

You must use the cloud-init system to provide a way to access the system.

- Datacenter > pve > 101 (mediacenter) > Hardware

- [Add] > CloudInit drive. Storage `media-center`, [Add]

- Switch to the Cloud-Init section. SSH public key > paste your public key.


## START THE VM

From 101 (mediacenter), click [> Start]


## IP SETUP AT THE ROUTER

The easiest way to get the LAN IP of the new Rocky VM is from the router, find the latest IP address assigned by DHCP. Make this assignment permanent.

**IP is currently 10.0.0.24**


## ACCESS THE INSTANCE VIA SSH

SSH with `rocky@10.0.0.24` and the pubkey provided to cloud-init above.
