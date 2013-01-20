"""
Identify which rackspace cloud server we're on
"""

import os

## import yaml


SALT_MINION_CONFIG = '/etc/salt/minion'


def rackspaceDiskSize():
    """
    Infer the disk size that the rackspace control panel says this node has, and
    report that.
    """
    df = os.popen('df -H /').read().splitlines()[-1].split()[1]
    ret = {}
    if df in ['19G', '21G']:
        ret['rackspaceDiskSize'] = '20GB'
    elif df in ['41G']:
        ret['rackspaceDiskSize'] = '40GB'
    elif df in ['81G']:
        ret['rackspaceDiskSize'] = '80GB'
    elif df in ['161G']:
        ret['rackspaceDiskSize'] = '160GB'
    else:
        ret['rackspaceDiskSize'] = int(df[:-1])
    return ret

def rackspaceMemorySize():
    """
    Infer the memory that the rackspace control panel says this node has, and
    report that.
    """
    ret = {}
    mem = int(os.popen('grep MemTotal /proc/meminfo').read().split()[1])
    if 500000 < mem < 510000:
        ret['rackspaceMemorySize'] = '512MB'
    elif 1000000 < mem < 1200000:
        ret['rackspaceMemorySize'] = '1GB'
    elif 2000000 < mem < 2300000:
        ret['rackspaceMemorySize'] = '2GB'
    elif 4000000 < mem < 4400000:
        ret['rackspaceMemorySize'] = '4GB'
    elif 8000000 < mem < 8800000:
        ret['rackspaceMemorySize'] = '8GB'
    else:
        ret['rackspaceMemorySize'] = mem/1024

    return ret

def _run(cmd):
    from subprocess import Popen, PIPE, STDOUT
    process = Popen(cmd, shell=True, stdout=PIPE, stderr=STDOUT, stdin=PIPE)
    process.stdin.close()
    out = process.stdout.read()
    return (not process.wait(), out)

def inMasterNetwork():
    """
    Test to see whether we're on the same network as the salt master. If we are
    not, we can install some workarounds.
    """
    ret = {}

    rm = __opts__.get('real_master', None)
    if rm is None:
        return {'inMasterNetwork': True}

    return {'inMasterNetwork': False}

__all__ = ['inMasterNetwork', 'rackspaceMemorySize', 'rackspaceDiskSize']


# vim:set tw=80 et sw=4 ts=4 sts=4 si:
