# Config settings for servarrs

## SONARR

- Settings > Download Clients. Remote Path Mappings:
	- deluge-xantxant.thor.mygiga.cloud: /home5/xantxant/storage/media/downloads/deluge -> /downloads/deluge
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

- Settings > General (Backups)
	- Folder `/config/backup`
	- Retention `31` days

- Settings > Languages (Languages Profiles) > `cory`
	- (all defaults?)

- Settings > Languages
	- Languages Profiles: `cory` (EN)
	- Default Settings: Series Profile `cory`, Movies Profile `cory`

- Settings > Providers
	- OpenSubtitles.com
		- Username `boldluck`
		- Password `xxxx`
		- Use hash [true]

- Settings > Radarr
	- Address `radarr.carrotwithchickenlegs.com`
	- Port `443`
	- API Key `xxxx`
	- SSL [true]

- Settings > Sonarr
	- Address `sonarr.carrotwithchickenlegs.com`
	- Port `443`
	- API Key `xxxx`
	- SSL [true]

- Settings > Subtitles
	- Subtitle Folder [Alongside Media File]


## JELLYSEERR

- Settings > Jellyfin
	- You MUST use `http://jellyfin:8096` (match with the actual jellyfin port)
	  	- XXX The https URL does not work (DNS??)
	- Libraries: Shows, Movies, Specials

- Settings > Services > Radarr
	- Server name `radarr`
	- Hostname or IP address [https://] `radarr.carrotwithchickenlegs.com`
	- Port `443`
	- Use SSL [true]
	- API key `xxxx` 
		- found by visiting https://radarr.carrotwithchickenlegs.com/
		- Settings > General > API Key, copy
	- Click [Test] before continuing
	- Quality: HD 720p/1080p
	- root folder: /media/Movies
	- Minimum avail: in cinemas
	- Enable scan [true]
	- Enable automatic search [true]

- Settings > Services > Sonarr
	- Server name `sonarr`
	- Hostname or IP address [https://] `sonarr.carrotwithchickenlegs.com`
	- Port `443`
	- Use SSL [true]
	- API key `xxxx`
		- found by visiting https://sonarr.carrotwithchickenlegs.com/
		- Settings > General > API Key, copy
	- Click [Test] before continuing
	- Quality: HD 720p/1080p
	- root folder: /media/TV Shows
	- Season Folders [true]
	- Enable scan [true]
	- Enable automatic search [true]

- Settings > Users
	- Enable Local Sign-in [true]
	- Enable new Jellyfin sign-in [true]


## JELLYFIN

- Settings (Administration) > Dashboard, Libraries
	- Movies  `/media/Movies`
	- Shows `/media/TV Shows`
	- Specials `/media/Specials`
	- XD `/media/XD`

- Settings (User) > Settings > Subtitles
	- Preferred subtitle language [English]
	- Subtitle mode [Default]
	- Text size [Normal]
	- Vertical Position [-1]


## FLARESOLVERR

- no configuration as long as you use the jellyfin compose file
