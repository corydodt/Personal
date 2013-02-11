
nginx:
    pkg: 
        - installed
    service:
        - running
        - require:
            - pkg: nginx
        - watch:
            - file: /etc/nginx/

/var/www/index.html:
    file.managed:
        - source: salt://nginx/index.html
        - mode: 0644
        - template: jinja
        - user: {{ pillar.apache.owner }}
        - group: {{ pillar.apache.owner }}
        - require:
            - pkg: nginx

/etc/nginx/:
    file.recurse:
        - file_mode: 0644
        - require:
            - pkg: nginx 
        - template: jinja
        - source: salt://nginx/config/

