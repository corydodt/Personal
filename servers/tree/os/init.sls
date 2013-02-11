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


# todo:
# - install dropbox from their deb
# - upgrade it if necessary (website deb sometimes out-of-date from repo)
# - dropbox start -i
# - set dropbox fs.inotify.max_user_watches = 100000

utility server maintenance packages:
    pkg:
        - installed
        - names:
            - unzip
            - zip
            - p7zip-full
            - rsync
            - vim
            - exuberant-ctags
            - iotop
            - screen
            - snort
            - zsh
            - rkhunter
            - elinks
            - openntpd
            - libxml2-utils
            - python-pip

general development packages:
    pkg:
        - installed
        - names:
            - make
            - python-dev
            - subversion
            - diffstat
            - mercurial


wiki packages:
    pkg:
        - installed
        - names:
            - python-moinmoin

# pngcrush: pkg.installed ### i forget why i needed this....

goon-site packages:
    pkg:
        - installed
        - names:
            - nginx
            - python-nevow
            - python-docutils

Fabric:
    pip:
        - installed
        - require:
            - pkg: python-pip

