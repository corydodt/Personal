# Self-Hosting Architecture

## Third-party services list
  - giga-rapid gigadrive seedbox $18.26/mo ($219.12/yr)
    - deluge
    - syncthing
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
    - Proxmox VE (non-subscription)
        - VMs:
            - hass.carrotwithchickenlegs.com
                - Home Assistant 11.0
            - mediacenter.carrotwithchickenlegs.com
                - Rocky 9 / podman
                - (?) gluetun
                - Portainer
                    - nginx
                    - syncthing
                    - duplicati
                    - sonarr, radarr, bazarr, jellyseerr, jellyfin, flaresolverr, prowlarr
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
