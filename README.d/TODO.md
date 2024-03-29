# TODO

- [ ] pve vm startup: build in a delay to wait for qnap to start
- [ ] fix ISP ip address whitelist for namecheap api access - keeps changing IP
  - auto-update? this also affects /root/.acme.sh/account.conf NAMECHEAP_SOURCEIP
- [ ] ssh certificates
- [ ] run sabnzbd and deluge locally through protonvpn
- [ ] update acme-reload.sh for portainer apps
- [ ] clean out nginx and traefik, document caddy as replacement

- [ ] pve https/revproxy
- [ ] pass through igpu to mediacenter? https://pve.carrotwithchickenlegs.com:8006/pve-docs/chapter-qm.html#qm_pci_passthrough_vm_config

---

- [x] test restart syncthing
- [x] portainer https
- [x] radarr, sonarr, prowlarr
- [x] test a reboot of mediacenter
  - [x] set portainer to autostart
  - [x] set containers managed by portainer to autostart

- [x] backup configs regularly
  - [x] make a first backup of /opt
  - [x] duplicati
    - [x] backup portainer, jellyfin, syncthing, flaresolverr, jellyseerr, sonarr
    - [x] radarr
    - [x] prowlarr
    - [x] bazarr
  - [x] automate snapshot of hass into backups folder

- [x] fix sync of media, backups, downloads

- [x] add acme.sh notify
