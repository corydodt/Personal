# vim:set ft=yaml si:
#
# ===
# os/
# ===
#
# Resources and configuration related to the integrity and security of the
# entire system, regardless of duty, and not specific to any application
# service.

include:
    - os.time
    - os.userstandards
    - os.unattended
    - os.network
    - os.user
    - os.firewall
    - os.fabric
    - os.salt
    - os.backup

/etc/security/limits.conf:
    file.managed:
        - source: salt://os/limits.conf
        - mode: 0644
        - template: jinja

# clean up this legacy file
/etc/security/limits.d/hermes-limits.conf: file.absent

aptitude: pkg.installed
apt-file: pkg.installed
apt-file-update:
    cmd.run:
        - name: apt-file update
        - unless: test `ls -1 /var/cache/apt/apt-file/*.gz | wc -l` -gt 1
        - require:
            - pkg: apt-file

partner.list:
    file.managed:
        - name: /etc/apt/sources.list.d/partner.list
        - source: salt://os/partner.list
        - mode: 644
        - template: jinja

/etc/rc.local append:
    file.append:
        - name: /etc/rc.local
        - text: 'for f in `find /etc -name "rc.local.*"`; do . $f; done'

locate: pkg.installed
updatedb:
    cmd.run:
        - unless: test -e /var/cache/locate/locatedb || test -e /var/lib/mlocate/mlocate.db
        - require:
            - pkg: locate

unzip: pkg.installed
zip: pkg.installed
p7zip-full: pkg.installed
rsync: pkg.installed
mercurial: pkg.installed
zsh: pkg.installed
python-dev: pkg.installed
make: pkg.installed
python-pip: pkg.installed
rkhunter: pkg.installed
snort: pkg.installed
elinks: pkg.installed
openntpd: pkg.installed
vim: pkg.installed
screen: pkg.installed
subversion: pkg.installed
pngcrush: pkg.installed
libxml2-utils: pkg.installed
diffstat: pkg.installed
exuberant-ctags: pkg.installed
