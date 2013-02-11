{% set duty = pillar.duty %}
{% set id = grains.id %}

# Paranoia mode. Before salt will do anything to your server, it must 
#   a) be in the "everything" list, and
#   b) not be in the "careful" list.
# This way, we can explicitly exclude servers, and we can't get burned by a
# bad duty.sls.

{% if id not in duty.careful and id in duty.everything %}

base:
  '*':
    - os
    - ssh
    - mail
    - nginx

{% else %}

# do NOTHING on servers in the "careful" list.
base:
  '*': []

{% endif %}
