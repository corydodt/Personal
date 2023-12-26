# Self-Hosting Architecture

## Third-party services list
  - giga-rapid gigadrive seedbox $18.26/mo ($219.12/yr)
    - deluge
    - resilio sync
    - (?) wireguard
    - sabnzbd
  - newsgroup.ninja (news-nl.newsgroup.ninja) $5.83/mo ($69.99/yr)
  - abnzb usenet indexer $2.08/mo ($25/yr)
  - opensubtitles.com $1.67/mo ($20/yr)
  - ~~torrentgalaxy.to~~
  - 1337x.to torrents

## pve.carrotwithchickenlegs.com
    - bare metal installation
        - 32 GB RAM
        - 1TB disk + 4TB external SSD
        - 16 i7 CPU cores
    - network: 2 NICs in use
      - enp2s0 bridged using vmbr0 = 10.0.0.97 LAN
      - enp3s0 bridged using vmbr1 = 10.0.69.2 connected to 2.5Gbe on QNAP NAS
    - Proxmox VE (non-subscription)
        - configured storage:
          - local-lvm LVM-THIN storage on 1TB disk
          - CIFS storage `opt-qnap` from \\10.0.69.1\opt
        - VMs:
            - hass.carrotwithchickenlegs.com (vmbr0 only)
                - Home Assistant 11.0
            - mediacenter.carrotwithchickenlegs.com (vmbr0 + vmbr1)
                - Rocky 9 / podman
                - (?) gluetun
                - Portainer
                    - nginx
                    - syncthing
                    - duplicati
                    - sonarr, radarr, bazarr, jellyseerr, jellyfin, flaresolverr, prowlarr
                - cifs mount /media as filesystem
                - cifs mount /backups as filesystem
                - /opt from pve storage `opt-qnap`
    - Certs:
        - *.carrotwithchickenlegs.com
            - ACME, dns-01 challenge
              - namecheap api
            - delivery to various cert termination endpoints by shell script
              - pve
              - hass
              - mediacenter: nginx

## pve3.carrotwithchickenlegs.com
  - Proxmox VE (non-subscription)
    - VMs:
      - aero-dev.carrotwithchickenlegs.com
        - Rocky 9


## QNAP NAS
  - 2 NICs in use
    - NIC 1 = 10.0.69.1 + DHCP server, connected to 2.5Gbe port on pve NUC
    - NIC 2 = 10.0.0.55 on LAN
  - 4TB disk 1:
    - (overhead ~5%)
    - 2.66TB thin: media
      - used as a filesystem
    - 39GB thin: opt
      - used as disk image storage by pve
  - 4TB disk 2:
    - (overhead ~25%)
    - 200GB thin: backups
      - used as a filesystem

## SECRETS IN THE NETWORK

- *.carrotwithchickenlegs.com.key, x4 places (/root/.acme.sh + /etc/pve/nodes/pve + hass vm + mediacenter vm)
- namecheap dns api key /root/.acme.sh/account.conf
- cory-aws-personal.pem
- wireguard preshared key, private key, server public key
- opensubtitles.com u/p
- abnzb.com API key
- sabnzbd u/p + API key
- newsgroup.ninja u/p 
- deluge (giga-rapid) password
- resilio sync share keys (backups, media) 
- qnap nas u/p
