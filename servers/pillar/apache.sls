## platform.sls:
## categorize servers into the two main families we're interested in, Ubuntu and Redhat

apache:
    {% if grains.os_family == 'Debian' %}
    configPath: /etc/apache2
    serviceName: apache2
    owner: www-data

    {% elif grains.os_family == 'Redhat' %}
    configPath: /etc/httpd
    serviceName: httpd
    owner: apache

    {% else %}
    configPath: UNKNOWN
    serviceName: UNKNOWN
    owner: UNKNOWN

    {% endif %}
     
