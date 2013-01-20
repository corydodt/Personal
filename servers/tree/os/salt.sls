/etc/salt/minion:
    file.managed:
        - mode: 664
        - source: salt://os/minion
        - template: jinja

salt-minion:
    service.running:
        - watch:
            - file: /etc/salt/minion

# erase the logrotate file salt ships
/etc/logrotate.d/salt-common: file.absent

/etc/logrotate.d/salt:
    file.managed:
        - source: salt://os/logrotate.d-salt
        - mode: 644

