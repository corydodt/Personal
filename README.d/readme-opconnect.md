# opconnect (1password connect) Runbook


## CLONE THE VM

- Datacenter > Virtual Machine > 103 (rocky-template-202401a)
- More (top right menu) > Clone. Mode = Linked Clone, choose an id and a name, [Clone]


## START THE VM

From 1xx (opconnect), click [> Start]


## FIX THE HOSTNAME


## INSTALL 1password CLI

```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password-cli && sudo dnf install 1password-cli
```

## CONFIGURE 1password CLI

