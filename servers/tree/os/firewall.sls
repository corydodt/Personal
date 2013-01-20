
/root/firewall-setup.sh:
    file:
        - managed
        - source: salt://os/firewall-setup.sh
        - mode: 700
        - require:
            - file: /etc/firewall.d/00base.conf

    cmd:
        - run
        - onlyif: /root/firewall-setup.sh timestamp
        - require:
            - file: /root/firewall-setup.sh

/etc/firewall.d:
    file.directory:
        - mode: 700
        - user: root
        - group: root
        - recurse:
            - user
            - group

/etc/firewall.d/00base.conf:
    file.managed:
        - source: salt://os/00base.conf
        - mode: 600
        - require:
            - file: /etc/firewall.d

