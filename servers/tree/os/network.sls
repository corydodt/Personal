/etc/hosts:
    file.managed:
        - source: salt://os/hosts
        - template: jinja
        - mode: 0644
