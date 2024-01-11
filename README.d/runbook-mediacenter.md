# Media Center Runbook


## CLONE THE VM

- Datacenter > Virtual Machine > 101 (rocky-template-202401a)
- More (top right menu) > Clone. Mode = Linked Clone, choose an id and a name, [Clone]


## START THE VM

From 1xx (mediacenter), click [> Start]


## IP SETUP AT THE ROUTER

The easiest way to get the LAN IP of the new Rocky VM is from the router, find the latest IP address assigned by DHCP. Make this assignment permanent.

**IP is currently 10.0.0.54**


## NAMECHEAP DNS A RECORD

- Add a Namecheap RR to the carrotwithchickenlegs.com zone, A 10.0.0.54 -> mediacenter


## ACCESS THE INSTANCE VIA SSH

SSH with `rocky@mediacenter.carrotwithchickenlegs.com` and the pubkey provided to cloud-init above.


### USER SETUP for rocky

- set up ~/.ssh/config and ~/.ssh/cory-aws-personal.pem

- clone repos
  ```
  mkdir src
  cd src
  git clone git@github.com:corydodt/pve.carrotwithchickenlegs.com.git
  git clone git@github.com:corydodt/Personal.git
  ```


## PORTAINER

1. Install the systemd service:

```
cd ~/src/pve.carrotwithchickenlegs.com/portainer
sudo install portainer.service /etc/systemd/system/portainer.service
sudo systemctl enable --now portainer
```

2. Set up admin at https://localhost:9443 (do this quickly, it times out).

3. Install the portainer cli:

```
make install

# if you don't have a keyring plugin for a secret manager installed, also do this:
make install-keyringrc
keyring set portainer admin
# (type the password for portainer admin from 1password)
```


## PODMAN NETWORK

Create a network for the containers to communicate
```
sudo podman network create --subnet 10.89.33.0/24 web-backends
```


## MOUNT CIFS STORAGE FROM PROXMOX

1. Datacenter > pve > 1xx (mediacenter) > Hardware

- [Add] > Hard Disk. Storage `opt-qnap`. Disk size 29GB. [Add].

2. `lsblk` and confirm the new attached disk is `/dev/sdb`

3. **Caution: This will erase the NAS-mounted storage.** `mkfs.ext4 /dev/sdb`

4. Edit /etc/fstab and add:
```
/dev/sdb /opt ext4 defaults 0 0
```

5. Mount up
```
sudo systemctl daemon-reload
sudo mount -a
```


## CIFS MOUNTS

1. Edit /etc/fstab and add the following
```
# note: we cannot use a hostname like qnap.fast.carrotwithchickenlegs.com here without existing WINS name resolution
//10.0.69.1/media   /media   cifs defaults,credentials=/root/creds.txt 0 0
//10.0.69.1/backups /backups cifs defaults,credentials=/root/creds.txt 0 0
```

2. Create `/root/creds.txt` with contents:
```
username=cdodt
password=xxxxxx from 1password qnap
```

3. mount them
```
systemctl daemon-reload
mkdir -p /backups /media
mount -a
```


## NGINX (FIXME -- CADDY)

1. Prep:

    Edit ~/src/pve.carrotwithchickenlegs.com/nginx/conf.d/https_proxy 

    ```
    cd ~/src/pve.carrotwithchickenlegs.com/nginx
    make install
    ```

2. Install in portainer:

    ```
    make template
    make stack
    ```


## JELLYFIN

1. Prep:

    ```
    sudo chown -R rocky.rocky /opt /media
    ```

2. Install service in portainer:

    ```
    cd ~/src/pve.carrotwithchickenlegs.com/jellyfin
    make template
    make stack
    ```

3. Visit: http://mediacenter.carrotwithchickenlegs.com:8096


## RESILIO SYNC

```
cd ~/src/carrotwithchickenlegs.com/resilio
make template
make stack
```


## VPN DOWNLOAD CLIENTS (GLUETUN/WIREGUARD)

1. Install secrets into podman that can be used by the container

    ```
    # get these from protonvpn console or 1password
    printf xxxxxxxxxxxxx | podman secret create WIREGUARD_PUBLIC_KEY.env -
    printf xxxxxxxxxxxxx | podman secret create WIREGUARD_PRIVATE_KEY.env -
    ```

2. Install the stack:

    ```
    cd ~/src/carrotwithchickenlegs.com/vpn-dl-clients
    make template
    FIXME -- no nginx yet
    make stack
    ```

3. Test
    ```
    # best way to check:
    sudo podman exec -it gluetun ping 10.2.0.1
    ```
