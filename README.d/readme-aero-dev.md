# Aero Dev Runbook


## Outline

- Install proxmox as `pve2` (it will be its own cluster separate from `pve`).
- Create a new VM as `aero-dev` using Rocky 9 GenericCloud. Use all the resources, as this will be the only VM.
    - Make sure it autostarts at boot
    - Enable QEMU guest agent
    - Create a cloudinit for `aero-dev` using `rocky` user and `cory-work.pem` contents
    - Check boot options and enable scsi0, all others unchecked
- When the VM boots, install git, vim, lsof, make
- Install tailscale with shell script and get authorized by IT
- Update namecheap DNS
