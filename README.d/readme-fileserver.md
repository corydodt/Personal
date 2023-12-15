# Fileserver Runbook


## Outline

- Create a new VM as `fileserver` using Rocky 9 GenericCloud. 4GB 4CPU
    - Make sure it autostarts at boot
    - Enable QEMU guest agent
    - Create a cloudinit for `fileserver` using `rocky` user and `cory-aws-personal.pem` contents
    - Check boot options and enable scsi0, all others unchecked
    - Attach additional filesystem for the fileserver
- When the VM boots, install git, vim, lsof, make
- Update namecheap DNS



## Samba

```
---
version: "3.9"

services:
  samba:
    image: docker.io/servercontainers/samba:latest
    container_name: samba
    restart: unless-stopped
    environment:
      ACCOUNT_cdodt: password
      UID_cdodt: 1000
      SAMBA_VOLUME_CONFIG_sharename: "[sharename]; path=/fileserver; available = yes; browsable = yes; writable = no; read only = yes; force user>
    volumes:
      - /your/data:/shares/location
    ports:
      - 445:445
```
