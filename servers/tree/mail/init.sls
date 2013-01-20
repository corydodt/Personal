
postfix:
    pkg:
        - installed
    service:
        - running

/etc/mailname:
    file.managed:
        - source: salt://mail/mailname
        - template: jinja
        - mode: 0644

/etc/postfix/main.cf:
    file.managed:
        - source: salt://mail/main.cf
        - template: jinja
        - mode: 0644
        - require:
            - pkg: postfix

mutt:
    pkg:
        - installed

