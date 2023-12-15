# Projects Runbook


## Outline

- Install proxmox as `pve2` (it will be its own cluster separate from `pve`).
- Create a new VM as `projects` using Rocky 9 GenericCloud. Use all the resources, as this will be the only VM.
    - Make sure it autostarts at boot
    - Enable QEMU guest agent
    - Create a cloudinit for `projects` using `rocky` user and `cory-aws-personal.pem` contents
    - Check boot options and enable scsi0, all others unchecked
- When the VM boots, install git, vim, lsof, make
- Update namecheap DNS
