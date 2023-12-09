# TODO

- [x] test restart syncthing
- [x] portainer https
- [x] radarr, sonarr, prowlarr
- [x] test a reboot of mediacenter
  - [x] set portainer to autostart
  - [x] set containers managed by portainer to autostart
- [ ] update acme-reload.sh for portainer apps
- [ ] pve https/revproxy
- [ ] parameterize templates with env vars(?)
- [ ] nginx - auto(?) soft reload on adding new app (or get traefik working)
- [ ] backup configs regularly 
  - [x] make a first backup of /opt
  - [ ] automate snapshot of hass into backups folder
  - [ ] configure arrs to self-backup to /storage/backups
  - [ ] duplicati
    - [ ] backup portainer, jellyfin, syncthing
- [ ] finish runbooks
- [ ] pass through igpu to mediacenter? https://pve.carrotwithchickenlegs.com:8006/pve-docs/chapter-qm.html#qm_pci_passthrough_vm_config
