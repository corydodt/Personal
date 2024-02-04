# qnap nas

## NETWORK

- control panel > (network & file services) network & virtual switch
    - (network) interfaces
    - verify adapter 2 has been assigned dhcp address 10.0.0.55
    - for adapter 1 (this will be the one without an assigned ip): kebab menu > configure
    - use static ip address = 10.0.69.1. [apply]

- control panel > (network & file services) win/mac/nfs/webdav
    - (microsoft networking) ensure [x] enable file service for microsoft networking
    - (optional) disable apple networking, nfs, webdav
    - [apply]

### Network-based connection restrictions

- control panel > (system) security > allow/deny list
- allow connections from the list only
    - [Add] 10.0.0.0 / 255.255.255.0, [create]
    - [Add] 10.0.69.0 / 255.255.255.0, [create]


## SHARES

### Volumes

- app "storage and snapshots"
- (storage) storage/snapshots

#### storage pool 1
- create > new volume
    - on-demand space
    - volume alias = qnap-system
    - capacity = 10GB
    - NOTES: this will automatically be marked as the system volume

- media volume, 3TB
    - during creation, (configure) advanced settings > [x] create a shared folder = `media`
- opt volume, 40GB
    - during creation, (configure) advanced settings > [x] create a shared folder = `opt`
- secrets volume, 20GB
    - during creation, (configure) advanced settings > [x] create a shared folder = `secrets`

#### storage pool 2
- create > new volume
    - on-demand, "backups", 200GB
    - during creation, (configure) advanced settings > [x] create a shared folder = `backups`
