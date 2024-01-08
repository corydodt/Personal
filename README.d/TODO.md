# TODO

- [ ] run sabnzbd and deluge locally through a vpn like mullvad
- [ ] update acme-reload.sh for portainer apps
- [ ] clean out nginx and traefik, document caddy as replacement
- [ ] finish runbooks

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
