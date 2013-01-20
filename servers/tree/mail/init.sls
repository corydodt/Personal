
postfix:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/postfix/main.cf
            - file: /etc/postfix/forward_to_gmail

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

/etc/postfix/forward_to_gmail:
    file.managed:
        - source: salt://mail/forward_to_gmail
        - template: jinja
        - mode: 0644
        - require:
            - pkg: postfix

mutt: pkg.installed
postgrey: pkg.installed
