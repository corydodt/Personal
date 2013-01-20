# userstandards.sls:
#
# Security settings that apply globally to all users

/etc/login.defs:
    file.managed:
        - mode: 0644
        - source: salt://os/login.defs

/etc/default/useradd:
    file.managed:
        - mode: 0644
        - source: salt://os/default-useradd

/etc/sudoers.d/00sudogroup:
    file.managed:
        - source: salt://os/00sudogroup
        - mode: 440
        - user: root
        - group: root

libpam-cracklib: pkg.installed
/etc/pam.d/common-password:
    file.managed:
        - mode: 0644
        - source: salt://os/common-password
        - require:
            - pkg: libpam-cracklib

