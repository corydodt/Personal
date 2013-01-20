"""
Prepare a brand-new server. Does exactly two things: set root password, and
fix hostname.
"""

from fabric import api
from fabric.api import (local as l, run as r, sudo)

@api.task(default=True)
def brandNew():
    """
    Set hostname and root password
    """
    api.execute(_brandNew, host='root@' + api.env['host'])

def _brandNew():
    """
    Set hostname and root password (runs as root)
    """
    from fabfile import dutyData

    sudo("passwd")
    current = r("hostname")
    new1 = api.prompt("New hostname:", default=current)
    sudo("echo {0} > /etc/hostname".format(new1))
    sudo("hostname -F /etc/hostname")
    fqdn = '{0}.{1}'.format(new1, dutyData['domain'])
    sudo("echo '127.0.0.1 {0} {1}' > /etc/hosts".format(fqdn, new1))
