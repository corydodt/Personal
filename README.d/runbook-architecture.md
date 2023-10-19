# Self-Hosting Architecture

- pve.carrotwithchickenlegs.com
    - bare metal installation
        - 32 GB RAM
        - 1TB disk + 4TB external SSD
        - 16 i7 CPU cores
    - Proxmox VE (non-subscription)
    - VMs:
        - hass.carrotwithchickenlegs.com
            - Home Assistant 11.0
        - mediacenter.carrotwithchickenlegs.com
            - ???
    - Certs:
        - *.carrotwithchickenlegs.com ?
            - ACME, dns-01 challenge
            - Dynu DNS API
