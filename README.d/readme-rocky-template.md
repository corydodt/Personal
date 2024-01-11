# rocky template instance


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


## SSH Certs

### Install CA public key carrotwithchickenlegs.com_CA.pub

Create `/etc/ssh/carrotwithchickenlegs.com_CA.key.pub`:

```
sudo tee /etc/ssh/carrotwithchickenlegs.com_CA.key.pub <<< "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDwwF90L10rxhihjwF4OYroF0K01eu71H+syBaeYpsDM3MpdZ3ZMYS4EabFwSWCLX3r8cLlDeCAT0vBPbOCoJsrF5Bg+0ym4Z1UVRVN/vNav10VXsV3Peoj95DC38vq8c9rHCBZO8bjYr4dxAonupYFTaoJ0oxzHlVTcB0JGCYF0S0AIEhfvInLPpzVQrc2B52qsaOfFgr2sp4F3kHBJ0RS1KnutizEDsoyn5ckBZzAjDHhPPDBhskqrqEgm268OnR7DR3KSGiI+MwBG9Lh7tn3Q4d3T3JDtc3K0Cs9u92YCbbzfSYhhz2J/U2xRDLGi6GGf0J4psImjIg9lCk81pGCysY4zuMFHR2YAgyRClX/RtOz/XmD9Msfzez0FQqHVYzrsLOn4agK1B3f1rwgSvhhzdO/JwRRosq0n27fV/d4nZqx+aBOJs7xOE1/W3Be6qNVWAqUN2O6oTTa1a2ViPhP04X7v7YWSSBsgoQ36/8YDnvY44SFsQXMNHgaWhzbpnDFXQSVj9UP9Kx7wJD20nf0cy72YQzwVqOG1eaNYTEIWD6NgGDMivNM5+jhyIrWfyd6u9j/yjaue2cdER8/GzsjmCc9xxm0xKlDphk867FiGLl5s5uNCyYjm4vQdMIElMfnP8niZPUIh6B6Z5OgrCsHyyebwNvVLl6A2oK7gnAePQ== rocky@mediacenter"
```

### SSHD config for CA public key

```
cat << EOF | sudo tee /etc/ssh/sshd_config.d/20-trusted-ca.conf
TrustedUserCAKeys /etc/ssh/carrotwithchickenlegs.com_CA.key.pub
EOF
```

```
sudo systemctl restart sshd
```

That's all you have to do on the servers's side. Everything else (user managing) you doing locally on your administrative computer (that shouldn't be exposed to the wild internet never).

To allow someone to access your servers:

```
U='cdodt'
UKEY="${U}@${ORG}"

# create keys for an user:
ssh-keygen -t rsa -b 4096 -C "$UKEY" -f ${UKEY}.key

# Sign user's public key with your CA (certificate authority) key:
ssh-keygen -s "./CA/${ORG}_CA.key" \
  -I "user_${U}" \
  -n cdodt,cory,rocky \
  -V "-1w:forever" \
  -z $RANDOM \
  "${UKEY}.key.pub"
```

That's all, from now on, user01 can access all servers that has:

```
/etc/ssh/carrotwithchickenlegs.com_CA.key.pub
```

with private key `${UKEY}.key` as usually:

```
ssh -i /path/to/${UKEY}.key ${U}@someHost.carrotwithchickenlegs.com
```

(signed public key also must be in the same directory: `/path/to/${UKEY}.key-cert.pub` )


## PODMAN AND UTILITY SETUP

### Podman setup
```
# install podman with other critical tools
sudo dnf install -y vim podman systemd-container git make lsof tree python3-pip podman-docker cifs-utils bind-utils

# expose the socket interface to allow portainer to listen to container events
sudo systemctl enable --now podman.socket

# restartable containers can restart:
sudo systemctl enable podman-restart
```


## GIT SETUP for rocky user

- ```
  git config --global user.name cory
  git config --global user.email 121705+corydodt@users.noreply.github.com
  git config --global push.rebase true
  ```
