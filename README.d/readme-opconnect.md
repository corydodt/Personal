# opconnect (1password connect) Runbook


## CLONE THE VM

- Datacenter > Virtual Machine > 105 (rocky-template-202401a)
- More (top right menu) > Clone. Mode = Linked Clone, choose an id and a name, [Clone]


## START THE VM

From 1xx (opconnect), click [> Start]


## INSTALL 1password CLI

```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password-cli && sudo dnf install 1password-cli
```


## CONFIGURE 1password CONNECT SERVICE

```
cd pve.carrotwithchickenlegs.com/opconnect
make init
```


## ON THE PROXMOX HOST, ADD CREDENTIALS TO SMBIOS

Perform these steps on the Proxmox VE host machine:

1. Retrieve (using croc or similar) the 1password-credentials.env file from the booted opconnect machine
2. Edit /etc/pve/qemu-server/xxx.conf (xxx corresponding to the VM id of the opconnect machine)
3. Add:
	```
	args: -smbios type=11,value=io.systemd.credential.binary:1password-credentials=$(base64 -w0 1password-credentials.env)
	```

4. Reboot the opconnect VM.
