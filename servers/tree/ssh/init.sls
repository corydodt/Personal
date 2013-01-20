
ssh:
    service.running:
        - watch:
            - file: /etc/ssh/sshd_config

/etc/ssh/sshd_config:
    file.managed:
        - mode: 0644
        - source: salt://ssh/sshd_config

/etc/ssh/ssh_config:
    file.managed:
        - mode: 0644
        - source: salt://ssh/ssh_config
