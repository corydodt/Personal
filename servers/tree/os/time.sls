
/etc/timezone:
    file.managed:
        - source: salt://os/timezone
        - mode: 0644

localtime:
    cmd.wait:
        - name: cat /etc/timezone | xargs -I{} cp /usr/share/zoneinfo/{} /etc/localtime
        - watch: 
            - file: /etc/timezone

