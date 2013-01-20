## platform.sls:
## categorize servers into the two main families we're interested in, Ubuntu and Redhat

{% if grains.os_family == 'Debian' %}
ubuntu: True
redhat: False

{% elif grains.os_family == 'Redhat' %}
ubuntu: False
redhat: True

{% else %}
------- unknown os_family: {{ grains.os_family }} ------------

{% endif %}
 
