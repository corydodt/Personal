"""
Put salt (master or minion) on a server
"""

from cStringIO import StringIO

from fabric import api
from fabric.api import (local as l, run as r, sudo)

from fabfile import util

SALT_MINION_HOME = '/home/salt-minion'
SALT_TREE_ROOT = SALT_MINION_HOME + '/tree'
SALT_DOMAIN = 'goonmill.org'

PKG_NAME = "salt-minion"
PPAS = {
        "ppa:saltstack/salt-daily": 
            'http://ppa.launchpad.net/saltstack/salt-daily/ubuntu',
        "ppa:saltstack/salt-depends": 
            'http://ppa.launchpad.net/saltstack/salt-depends/ubuntu',
    }


def _highstate():
    """
    Deploy the salt configuration tree to the master, and set highstate
    """
    putTrees(SALT_MINION_HOME)
    sudo("salt-call -l debug state.highstate")

@api.task(default=True)
def highstate():
    """
    Deploy the salt configuration tree to the master, and set highstate
    """
    if api.env.host is None:
        api.execute(_highstate, role='wip')
    else:
        _highstate()

@api.task
def putTrees(path):
    """
    Copy the salt state and pillar files to the master
    """
    # rsync is faster than put()
    l('rsync -avL --exclude "*.rej" --exclude "*.orig" --delete tree pillar root@{host}:{path}'.format(
        host=api.env['host'], path=path))

@api.task
@api.with_settings(warn_only=True)
def installed(pkg):
    """
    Check that a package is installed according to dpkg -s
    """
    return r("dpkg -s {0} | grep 'Status: install ok installed'".format(pkg)
            ).succeeded

def renderMinionConfig():
    """
    Return a file-like object containing the /etc/salt/minion config
    """
    pillarData = {'domain': SALT_DOMAIN }
    text = util.renderTemplate('tree/os/minion', pillar=pillarData,
            )
    return StringIO(text.encode('utf-8'))

@api.task
def installMinionPackage():
    """
    Install the software for salt-minion, including the config file, and check that it ran.
    """
    with api.settings(warn_only=True):
        fqdn = r("python -c 'import socket; print socket.getfqdn()'")
        if 'localhost' in fqdn:
            api.abort("Fix /etc/hosts first. This minion has a bad hostname!")
    r("mkdir -p /etc/salt")

    openFile = renderMinionConfig()
    api.put(openFile, '/etc/salt/minion', use_sudo=True)
    r("if [ ! -d /root/salt ]; then git clone https://github.com/corydodt/salt; else cd /root/salt; git pull; fi")

    # we install salt-minion so that all the dependencies are pulled in. then
    # we hold it so it never gets upgraded.
    r("aptitude -o Dpkg::Options::='--force-confold' install -y " + PKG_NAME)
    r("aptitude hold " + PKG_NAME)

    # install my salt fork over the existing, frozen salt-minion installation
    r("cd salt; pip install -U .")

    # make sure it's running
    r("restart salt-minion || start salt-minion || true")
    r("service salt-minion status | grep start/running")

@api.task
def singleState(state, env=None, **kw):
    """
    Run just one named state.
    Pass in the name of the state, and any arguments, like:
        fab -H blah salt.singleState:apache2,x=y,z=abc
    """
    args = ''
    for k,v in kw.items():
        args = args + ' {k}={v}'.format(k=k, v=v)

    _env = ''
    if env:
        for k,v in env.items():
            _env = _env + ' {k}={v}'.format(k=k, v=v)

    cmd = "{env} salt-call -l trace --no-color --json-out state.single {state} {args}".format(
        env=_env.strip(),
        state=state,
        args=args.strip())
    sudo(cmd + r" | egrep '\bresult\b.*\btrue\b'")

def _firstTimeSetup():
    """
    Kick off the slow parts of the initial setup of a minion (runs as root)
    """
    putTrees(SALT_MINION_HOME)
    singleState('file.managed', name='/etc/hosts', source='salt://os/hosts',
            template='jinja', mode='0644')
    pkg = 'apache2' if 'Ubuntu' in r('cat /etc/issue') else 'httpd'
    singleState('pkg.installed', name=pkg)

    sudo('service salt-minion restart')
    _highstate()

@api.task
def firstTimeSetup():
    """
    Kick off the slow parts of the initial setup of a minion

    The first time highstate runs on a minion it takes a very long time, often
    causing errors. If we do it this way it works better. We also front-load
    some states:

    The apachemod module doesn't work unless the apache package is installed
    first. **FIXME** -- the dependencies look right, not sure why this is
    failing. Install apache package.

    postgresql: in order for grains.postgresqlClusters to be right we must
    install postgresql first.

    hosts: for grains.fqdn to be correct we must set up hosts and restart the
    minion.
    """
    api.execute(_firstTimeSetup, host='root@'+api.env['host'])

def _createMinion():
    """
    Do all steps needed to start running salt on a target machine; and then run highstate (runs as root)
    """
    installMinionDependencies()
    installMinionPackage()
    firstTimeSetup()

@api.task
def createMinion():
    """
    Do all steps needed to start running salt on a target machine; and then run highstate
    """
    # the minion usually doesn't have any other users yet, so force root
    api.execute(_createMinion, host='root@'+api.env['host'])

def installMinionDependencies():
    """
    Configure salt repo and get common packages
    """
    with api.settings(warn_only=True):
        if r("test -e /etc/apt/sources.list.d/saltstack-salt*.list").succeeded:
            return
    # we have to update twice.. brand new servers have no index at all.
    sudo("aptitude update")
    sudo("aptitude install -y python-software-properties git python-pip")
    for ppa, url in PPAS.items():
        sudo("add-apt-repository -y {ppa}".format(ppa=ppa))

    sudo("aptitude update")


@api.task
@api.with_settings(warn_only=True)
def clean():
    """
    Remove salt and all traces
    """
    sudo("service stop salt-minion")
    sudo("pkill -f salt-")
    sudo("aptitude remove --purge -y salt-minion")
    sudo("rm -rvf ~/salt /etc/salt /var/cache/salt /etc/apt/sources.list.d/saltstack-salt*")

