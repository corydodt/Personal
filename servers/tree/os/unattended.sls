# vim:set ft=yaml si:
unattended-upgrades: pkg.installed

/etc/apt/apt.conf.d/10periodic:
    file.managed:
        - source: salt://os/10periodic
        - mode: 644

/etc/apt/apt.conf.d/20auto-upgrades:
    file.managed:
        - source: salt://os/20auto-upgrades
        - mode: 644

debconf-unattended-upgrades:
    cmd.run:
        - name: echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | sudo debconf-set-selections
        - unless: 'debconf-show unattended-upgrades | grep "enable_auto_updates: true"'
        - require:
            - pkg: unattended-upgrades
            - file: /etc/apt/apt.conf.d/10periodic
            - file: /etc/apt/apt.conf.d/20auto-upgrades

