# rackspace cloud backups
#

{% set id = grains.id %}
{% set duty = pillar.duty %}

{% if id in duty.rsc_us_ng %}
{% set username = pillar.backup.us.username %}
{% set apikey = pillar.backup.us.apikey %}

{% else %}
{% set username = '' %}
{% set apikey = '' %}

{% endif %}


{% if username %}
rsc-drive-client:
    file:
        - managed
        - name: /root/rsc-drive-client.sh
        - source: salt://os/rsc-drive-client.sh
        - mode: 700
        - template: jinja

    cmd:
        - run
        - name: '/root/rsc-drive-client.sh'
        - unless: 'test -f /etc/apt/sources.list.d/driveclient.list'
        - require:
            - file: rsc-drive-client

driveclient.list:
    file.exists:
        - name: /etc/apt/sources.list.d/driveclient.list
        - require:
            - cmd: 'rsc-drive-client'
        
driveclient configure:
    cmd.run:
        - name: "if driveclient --configure -u {{ username }} -k '{{ apikey }}' 2>&1 | grep ERROR; then false; fi"
        - unless: "grep {{ username }} /etc/driveclient/bootstrap.json"
        - require:
            - pkg: driveclient

driveclient:
    pkg:
        - installed
        - require:
            - file: 'driveclient.list'

    service:
        - running
        - enable: true
        - require:
            - cmd: "driveclient configure"

{% endif %}
