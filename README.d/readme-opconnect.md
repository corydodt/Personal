# opconnect (1password connect) Runbook


## CLONE THE VM

- Datacenter > Virtual Machine > 103 (rocky-template-202401a)
- More (top right menu) > Clone. Mode = Linked Clone, choose an id and a name, [Clone]


## ADD A SECRETS DRIVE

- Virtual Machine > 1xx (opconnect) > Hardware > Add > Hard Disk.
- Disk Size = 4GB, storage = secrets-qnap, [Add]


## START THE VM

From 1xx (opconnect), click [> Start]


## MOUNT THE SECRETS DRIVE

1. sudo mkdir -p /secrets/opconnect/data
2. Add to `/etc/fstab`:
	```
	/dev/sdb  /secrets  ext4  defaults  0  0
	```
3. Mount the disk:
	```
	sudo systemctl daemon-reload
	sudo mount -a
	```


## INSTALL 1password CLI

```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password-cli && sudo dnf install 1password-cli
```


## CONFIGURE 1password CLI

```
cd pve.carrotwithchickenlegs.com/opconnect
make init
```
