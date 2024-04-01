# Rocky template instance


## DOWNLOAD AND UNCOMPRESS

From the pve shell, via ssh,

```
wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
```


## CREATE A PLACEHOLDER VM

In the Proxmox VE management gui:

1. click [Create VM].

    - Note the VM ID on the next screen, e.g. `101`

2. Name it 'rocky-template-YYYYMM' and add `a` through `z` for sequence within
   the month, e.g. `rocky-template-202401b` is the second ("b") rocky-template in Jan
   2024

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


## ADD 1password CONNECT TOKEN TO SMBIOS

From the shell of the `pve` node of proxmox:

1. From 1password, grab the token credential from "1password connect server/api token cwcl1"
2. Edit /etc/pve/qemu-server/101.conf
3. Add the line:
  ```
  args: -smbios type=11,value=io.systemd.credential:cwcl1-token=(paste in the token here)
  ```
4. Save.


## PREPARE ZCRIPTS-INIT

This creates a systemd automount to connect the `zcripts-init` share to
`/zcriptsinit`, and mounts it immediately.  This will make sure /zcriptsinit is
available when a VM based on the template starts.

```
cd pve.carrotwithchickenlegs.com/base-vm
make install
sudo systemctl daemon-reload
sudo systemctl start zcriptsinit.mount
```

Reboot.


## SSH Certs

### Install CA public key carrotwithchickenlegs.com_CA.pub

This requires 1password cli installed; also `eval $(op signin)`

```
cd pve.carrotwithchickenlegs.com/CA
make install
sudo systemctl restart sshd
```

That's all you have to do on the servers's side. Everything else (user
managing), you do on your local administrative computer.

To allow someone to access your servers:

```
cd pve.carrotwithchickenlegs.com/CA
make sign
# this requires 1password cli; also `eval $(op signin)`; the CA private key is
# fetched from 1password and remains on disk when done.
```

That's all, from now on, `cdodt` can access all servers that have the ssh cert
installed, as usually:

```
ssh -i ~/.ssh/some-private-key.pem rocky@something.carrotwithchickenlegs.com
```

(signed public key also must be in the same directory: `~/.ssh/some-private-key.pem-cert.pub`)


## PODMAN AND UTILITY SETUP

### Podman setup
```
# install podman with other critical tools
sudo dnf install -y vim podman systemd-container git make lsof tree python3-pip podman-docker cifs-utils bind-utils

# install 1password CLI
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password-cli && sudo dnf install 1password-cli

# install croc
curl https://getcroc.schollz.com | bash

# expose the socket interface to allow portainer to listen to container events
sudo systemctl enable --now podman.socket

# restartable containers can restart:
sudo systemctl enable podman-restart

# podman-compose
sudo pip3 install podman-compose
sudo ln -s /usr/local/bin/podman-compose /usr/bin/podman-compose 
```


## GIT SETUP for rocky user

- ```
  git config --global user.name cory
  git config --global user.email 121705+corydodt@users.noreply.github.com
  git config --global push.rebase true
  ```


## TO REFRESH THE TEMPLATE

1. Clone the template (use "Linked Clone"). Name according to the original naming scheme, e.g. `rocky-template-202401b`

2. Start the template.

3. Connect via SSH. Make any changes you want.

4. [Shutdown] the VM.

5. More > Convert to Template, [Yes]

6. (Optional) remove the previous template


## PERFORMANCE TESTS WITH FIO

```
fio --name=job-w  --numjobs=2 --rw=write --size=2G --ioengine=libaio \
  --iodepth=4 --bs=128k --direct=1 --filename=bench.file --output-format=normal,terse
echo "-------------------------------------------------------------------------------------"; sleep 5
fio --name=job-r  --numjobs=2 --rw=read --size=2G --ioengine=libaio \
  --iodepth=4 --bs=128K --direct=1 --filename=bench.file --output-format=normal,terse
```

Note: fio is testing the performance of whatever filesystem contains the
argument passed to `--filename`. We're using a file in the current working
directory, so use `chdir` to start in a directory owned by the volume we want to
test, or modify the --filename argument with an absolute path to elsewhere.


### local - 2 processes

Local disk is the fastest by far:

```
job-w: (groupid=0, jobs=2): err= 0: pid=22033: Sat Feb 24 18:40:22 2024  
  write: IOPS=30.1k, BW=3765MiB/s (3948MB/s)(4096MiB/1088msec); 0 zone resets  
job-r: (groupid=0, jobs=2): err= 0: pid=22075: Sat Feb 24 18:40:28 2024  
  read: IOPS=29.3k, BW=3664MiB/s (3842MB/s)(4096MiB/1118msec)  
```

### cifs 2.5GBe - 2 processes

Achieving a respectable 296MB/s over 2.5Gbe networking to the NAS. At 
2368 megabits per second, we're essentially saturating the network.

```
job-w: (groupid=0, jobs=2): err= 0: pid=21791: Sat Feb 24 18:37:41 2024  
  write: IOPS=2260, BW=283MiB/s (296MB/s)(4096MiB/14496msec); 0 zone resets  
job-r: (groupid=0, jobs=2): err= 0: pid=21921: Sat Feb 24 18:38:01 2024  
  read: IOPS=2260, BW=283MiB/s (296MB/s)(4096MiB/14499msec)  
```

### cifs 1.0GBe - 2 processes

Still usable, but clearly slower 119MB/s over 1.0Gbe to the NAS. 952 megabits
per second, so once again, we're sitting at the theoretical peak of the network.
It seems evident that it's worth it to run a 2.5Gbe connection directly to the
NAS.

```
job-w: (groupid=0, jobs=2): err= 0: pid=22277: Sat Feb 24 18:42:46 2024  
  write: IOPS=904, BW=113MiB/s (119MB/s)(4096MiB/36236msec); 0 zone resets  
job-r: (groupid=0, jobs=2): err= 0: pid=22516: Sat Feb 24 18:43:27 2024  
  read: IOPS=904, BW=113MiB/s (119MB/s)(4096MiB/36241msec)  
```
