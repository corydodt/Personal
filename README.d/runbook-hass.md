# Home Assistant Runbook


## DOWNLOAD AND UNCOMPRESS

From the pve shell, via ssh,

```
wget https://github.com/home-assistant/operating-system/releases/download/11.0/haos_ova-11.0.qcow2.xz
xz -d haos_ova-11.0.qcow2.xz
```


## CREATE A ZFS STORAGE CONTAINER

In the Proxmox VE management gui:

1. Datacenter > Storage > [Add] > ZFS

2. Here, ID is the name, name it **home-assistant**

3. ZFS Pool: "vm-disks"

4. [Add]


## CREATE A PLACEHOLDER VM

In the Proxmox VE management gui:

1. click [Create VM].

    - Note the VM ID on the next screen, e.g. `100`

2. Name it 'hass'

3. OS > [Do not use any media]

4. Disks > Storage > `home-assistant`. 32GB default is fine.

5. CPU > use 1 socket, 2 cores

6. Memory > 2048 MB

7. Confirm > Finish. Don't check "start after created", we will start it later


## CREATE DISK FROM PVE COMMAND LINE

To attach the HAOS image as a disk of the VM,

- ssh to root@pve.ip.address and then, in the pve shell:

    ```
    # - 100 is the VM ID from the previous section
    # - home-assistant is the name of a storage container
    # - the .qcow2 file is the disk image, and it must be uncompressed
    qm disk import 100 haos_ova-11.0.qcow2 home-assistant
    ```

To swap the VM's placeholder storage for the new disk image:

- In Proxmox VE mgmt gui,

    1. Datacenter > pve > 100 (hass)
    
    2. If the VM is running, Shutdown > [Stop]

    3. Go to Hardware panel. You should see two Hard Disks (scsi0 and Unused Disk 0).

    4. Choose the empty placeholder disk, which will be `scsi0`. Click [Detach] > [Yes]. This becomes **Unused Disk 1**.

    5. Choose the new disk image, which will be labeled Unused Disk 0.

    6. [Edit], check the settings, it should by default have SCSI 0 selected.
    Just click [Add]. This becomes **scsi0**.

    7. Choose the empty placeholder disk which is now Unused Disk 1. [Remove] > [Yes].

### (Optional) resize storage

We do not need to resize storage for home assistant, the default of 32GB is the
recommended disk size.


## ENABLE EFI

The Home Assistant image requires EFI to boot.

- In Proxmox VE mgmt gui,

    1. Datacenter > pve > 100 (hass)
    
    2. Hardware > [Add] > EFI Disk

    3. EFI storage > `home-assistant`, and uncheck Pre-enroll keys. Note the "Warning" about UEFI BIOS, we will fix that next. Click [OK].

    4. Hardware > BIOS > [Edit]. Select OVMF (UEFI). [OK]

### (Optional: boot order)

You can speed up boot a bit:

- Options > Boot Order. Uncheck everything except `scsi0` and [OK].


## PASS THROUGH ZOOZ CONTROLLER STICK

1. Plug in the Zooz 800 z-wave controller stick to the physical server.

2. Datacenter > pve > 100 (hass) > Hardware.

3. [Add] > USB Device > Use USB Vendor/Device ID > Choose `Zooz` Device from the dropdown. [Add].

**Note: mapping this device from the datacenter and choosing a mapped device DOES NOT work, HASS will see the stick but not be able to initialize the z-wave addon.** Make sure you follow the above procedure, mapping it by Device ID from the VM itself.


## START THE VM

From 100 (hass), click [> Start].


## IP SETUP AT THE ROUTER

You can get the LAN IP of the new HASS VM one of two ways:

1. From proxmox VE gui, in 100 (hass), click [Console] and get the IP from the console screen

2. From the router, find the latest IP address assigned.

**IP is currently 10.0.0.28**

In the router, Advanced settings, DHCP Reservations, reserve an IP for HASS
permanently.


## ACCESS THE WEB INTERFACE

Once HASS is running, go to http://10.0.0.28:8123/

From the welcome page, just follow the prompts to

- Create My Smart Home
- New user, password, home address, etc.
- [Finish], accepting whatever devices HASS found


## DYNAMIC DNS + LETSENCRYPT

- add the dynu addon
    - settings > add-ons > [+ add-on store] > ... menu > repositories > https://github.com/koying/ha-addons
    - search for dynu
- sign up for free account **corydodt** at dynu.com
- add ddns management records:
    - carrotwithchickenlegs.ddnsfree.com
    - carrotwithchickenlegs.com

    - use advanced dynu config options
