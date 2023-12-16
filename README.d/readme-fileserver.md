# Fileserver Runbook


## Outline

- Create a new VM as `fileserver` using Rocky 9 GenericCloud. 4GB 4CPU
    - Make sure it autostarts at boot
    - Enable QEMU guest agent
    - Create a cloudinit for `fileserver` using `rocky` user and `cory-aws-personal.pem` contents
    - Check boot options and enable scsi0, all others unchecked
    - Attach additional 200GB filesystem for the fileserver (backups)
- When the VM boots, install git, vim, lsof, make, podman, python3-pip
- Update namecheap DNS


## Create the backups filesystem

```
sudo su
```

```
fdisk /dev/sdb
# confirm this is the right disk, then add /dev/sdb1 partition
mkfs.ext4 /dev/sdb1
lsblk -o NAME,UUID /dev/sdb    # grab the UUID

vim /etc/fstab
# add an entry for /dev/sdb1 by UUID

mkdir -p /fileserver/backups

systemctl daemon-reload
mount -a
```


## Podman

```
sudo systemctl enable podman-restart
pip3 install podman-compose
```


## Samba

```
cd ~/src/pve.carrotwithchickenlegs.com/fileserver
export SAMBA_USER_NAME=cdodt
export SAMBA_USER_PASSWORD=????
make install
```
