# Projects Runbook


## Outline

- Create a new VM as `projects` using Rocky 9 GenericCloud. 4GB 4CPU
    - Make sure it autostarts at boot
    - Enable QEMU guest agent
    - Create a cloudinit for `projects` using `rocky` user and `cory-aws-personal.pem` contents
    - Check boot options and enable scsi0, all others unchecked
- When the VM boots, install git, vim, lsof, make
- Update namecheap DNS
