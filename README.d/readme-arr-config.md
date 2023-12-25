# Config settings for servarrs

## SONARR

- Settings > Download Clients. Remote Path Mappings:
	- deluge-xantxant.thor.mygiga.cloud: /home5/xantxant/storage/media/downloads/deluge -> /downloads/deluge
	- sabnzbd-xantxant.thor.mygiga.cloud: /home5/xantxant/storage/media/downloads/sabnzbd -> /downloads/sabnzbd
	- sabnzbd-xantxant.thor.mygiga.cloud: /storage/downloads/sabnzbd -> /downloads/sabnzbd

- Settings > Download Clients > Deluge
	- Host `deluge-xantxant.thor.mygiga.cloud`
	- Port 443
	- Use SSL [true]
	- Password `xxx`
	- Category `tv-sonarr`
	- Remove completed [true]

- Settings > Download Clients > Sabnzbd
	- Host `sabnzbd-xantxant.thor.mygiga.cloud`
	- Port 443
	- Use SSL [true]
	- API Key `xxxxxx`
	- Username `xantxant`
	- Password `xxxxxx`
	- Category `tv`

- Settings > Media management
	- Root Folders: `/media/TV Shows`


## RADARR

- Settings > Download Clients. Remote Path Mappings:
	- deluge-xantxant.thor.mygiga.cloud: /home5/xantxant/storage/media/downloads/deluge -> /downloads/deluge
	- sabnzbd-xantxant.thor.mygiga.cloud: /home5/xantxant/storage/media/downloads/sabnzbd -> /downloads/sabnzbd
	- sabnzbd-xantxant.thor.mygiga.cloud: /storage/downloads/sabnzbd -> /downloads/sabnzbd

- Settings > Download Clients > Deluge
	- Host `deluge-xantxant.thor.mygiga.cloud`
	- Port 443
	- Use SSL [true]
	- Password `xxx`
	- Category `radarr`

- Settings > Download Clients > Sabnzbd
	- Host `sabnzbd-xantxant.thor.mygiga.cloud`
	- Port 443
	- Use SSL [true]
	- API Key `xxxxxx`
	- Username `xantxant`
	- Category `movies`

- Settings > General
	- Application URL `https://radarr.carrotwithchickenlegs.com/`
	- Enable SSL [false]
	- Backups > Folder `Backups`
	- Interval `7` days
	- Retention `28` days

- Settings > Media management
	- Root Folders: `/media/Movies`


## PROWLARR

- Indexers (top level)
	- Cardigann (1337x)
		- Base Url `https://1337x.to`
		- Download link [iTorrents.org]
		- Download link (fallback) [magnet]
		- Tags `cloudflare`
	- Newznab
		- Sync Profile [Standard]
		- URL `https://abnzb.com`
		- API key `xxxx`
		- VIP expiration `2024-12-03`
		- Tags `usenet`

- Settings > Indexers: Added 1337x, abNZB

- Settings > Apps
	- Enabled Radar, Sonarr
	- Sync Profiles: Standard 

- Settings > Apps > Radarr
	- Sync Level [Full Sync]
	- Tags [`cloudflare`, `usenet`]
	- Prowlarr server `http://prowlarr:9696/`
	- Radarr server `http://radarr:7878/`
	- API key `xxxx`

- Settings > Apps > Sonarr
	- Sync Level [Full Sync]
	- Tags [`cloudflare`, `usenet`]
	- Prowlarr server `http://prowlarr:9696/`
	- Radarr server `http://sonarr:8989/`
	- API key `xxxx`

- Settings > Applications (Sync Profiles) > Standard
	- Enable RSS [true]
	- Enable Interactive Search [true]
	- Enable Automatic Search [true]

- Settings > Indexers > FlareSolverr
	- Tags `cloudflare`
	- Host `https://flaresolverr.carrotwithchickenlegs.com/`


## BAZARR


## JELLYSEERR


## JELLYFIN


## FLARESOLVERR

- no configuration as long as you use the jellyfin compose file
