"""
Useful general-purpose fab tasks
"""

import os
from cStringIO import StringIO

from jinja2 import Environment, FileSystemLoader

import yaml

from fabric import api
from fabric.api import (local as l, run as r, sudo)

@api.task(default=True)
def printHost():
    """
    Just print the hostname.
    For other scripts that need access to the list of hosts.
    """
    print api.env.host

@api.task
def put(sourceFile, destFile, **kw):
    """
    Copy a file to the context host, possibly after first processing its template.

    If you pass in anything for **kw, we will assume this is a jinja template
    and pass in your kwargs as context for the template, then transfer the
    output as your file.

    This will also parse your kwarg. If the arg's name contains any dots, a
    dictionary will be constructed.
    """
    if not kw:
        api.put(sourceFile, destFile)
    else:
        data = parseKW(kw)
        text = renderTemplate(sourceFile, **data)
        openFile = StringIO(text.encode('utf-8'))
        api.put(openFile, destFile)

def parseKW(kwargs):
    """
    Convert dotted kwargs into dictionaries
    """
    ret = {}
    _tmp = []
    for k, v in kwargs.items():
        k = k.split('.')
        _tmp.append((k,v))

    for keys, value in _tmp:
        for k in reversed(keys):
            value = {k: value}
        ret.update(value)
    return ret

def renderTemplate(path, **kw):
    """
    Pass a file through jinja, using **kw as the items in the context.
    """
    dn, bn = os.path.split(path)
    loader = FileSystemLoader(dn)
    env = Environment(loader=loader)
    tpl = env.get_template(bn)
    ret = tpl.render(**kw)
    return ret


def _getLoginData(username):
    """
    Fetch dict of username, password, shell, authorized_keys from context host
    """
    shadowent = sudo('getent shadow {0}'.format(username))
    shadow = shadowent.split(':')[1]

    userent = r('getent passwd {0}'.format(username))
    keys = sudo('cat ~{0}/.ssh/authorized_keys 2> /dev/null || true'.format(
        username))
    keys = keys.strip().splitlines()
    shell = userent.strip().split(':')[-1]

    return dict(username=username, shadow=shadow, shell=shell, keys=keys)
_getLoginData.readOnly = True

@api.task
def getLoginData(username):
    """
    Dump password, shell, and authorized_keys for username@host
    """
    ret = _getLoginData(username=username)
    print yaml.dump(ret, default_flow_style=False, width=1000)
    return ret
getLoginData.readOnly = True

def _addOrMod(cmd):
    """
    Produce both usermod and useradd tasks.

    useradd and usermod work exactly the same way, and we even do the same
    tasks after completing them.
    """
    def _addOrModFn(username, shadow, defgroup, groups, shell, keys):
        assert shadow[:3] in ['$6$', '*', '!'], "shadow password must be a sha-512 encrypted string"

        if cmd == 'useradd':
            homeoption = '--create-home'
        else:
            homeoption = ''

        r('{cmd} {homeoption} --gid {defgroup} '
          '--shell {shell} '
          '--groups {groups} '
          '-p \'{shadow}\' {username}'.format(
            cmd=cmd,
            homeoption=homeoption,
            shell=shell,
            defgroup=defgroup, 
            groups=','.join(groups),
            shadow=shadow,
            username=username,
            ))
        sudo('chmod 750 ~{0}'.format(username))
        sudo('install -d -m700 -o{0} -g{1} ~{0}/.ssh'.format(username, defgroup))
        if keys:
            openFile = StringIO('\n'.join(keys))
            # bug - fabric expands ~ in a confusing way when using the put API
            userHome = r('echo ~{0}'.format(username))
            dest = "{0}/.ssh/authorized_keys".format(userHome)
            api.put(openFile, dest, mode=0600)
                
            r('chown {0} ~{0}/.ssh/authorized_keys'.format(username))
    return _addOrModFn

_useradd = _addOrMod('useradd')

@api.task
def useradd(username, shadow, defgroup, groups, shell, keys):
    """
    Install a new user on the context host.

    username  the userid to be created
    shadow    the sha-512 hashed password
    defgroup  the user's default group (gid)
    groups    optional list of groups to put the user in
    shell     user's login shell
    keys      user's .ssh authorized_keys
    """
    api.execute(_useradd, 
            username, 
            shadow, 
            defgroup, 
            groups, 
            shell,
            keys, 
            host="root@" + api.env['host'])

_usermod = _addOrMod('usermod')

@api.task
def usermod(username, shadow, defgroup, groups, shell, keys):
    """
    Set properties of the existing user

    Will also update permissions of certain directories necessary for ssh
    login
    """
    api.execute(_usermod, 
            username, 
            shadow, 
            defgroup, 
            groups, 
            shell,
            keys, 
            host="root@" + api.env['host'])

def _getUsersByGroup(group):
    """
    List all users on the context host that are in a particular group.
    - Includes those with the gid of that group.
    - Restricted to users with uid >= 1000
    """
    name, _, ogid, users = r('getent group {0}'.format(group)).split(':')
    gusers = []
    for u in users.split(','):
        if u.strip():
            gusers.append(u)

    ret = []

    pwents = r('getent passwd').splitlines()
    for pw in pwents:
        name, _, uid, ugid, rest = pw.split(':', 4)

        if int(uid) < 1000:
            continue

        elif name in gusers:
            ret.append(name)

        elif ugid == ogid:
            ret.append(name)

    return sorted(ret)
_getUsersByGroup.readOnly = True

@api.task
def getUsersByGroup(group):
    """
    List all users on the context host that are in a group
    """
    ret = _getUsersByGroup(group)
    print yaml.dump(ret, default_flow_style=False, width=1000)
getUsersByGroup.readOnly = True

@api.task
def migrateUsersByGroup(group, fromHost, outGroups):
    """
    Find every user in group `group`, on `fromHost`. Migrate those users.
    Assign them to the groups in `outGroups`.
    """
    inGroup = api.execute(_getUsersByGroup, group, host=fromHost)[fromHost]

    for user in inGroup:
        migrateUser(user, fromHost, outGroups)

@api.task
def migrateUser(username, fromHost, groups):
    """
    Copy username creds and data, from fromHost, to context host

    In cases where user does not exist, create user with util.adduser
    In cases where user does exist, update user with util.usermod
    """
    fromHost = 'root@' + fromHost
    data = api.execute(_getLoginData, username, host=fromHost)[fromHost]
    groups = [x.strip() for x in groups.split()]
    defgroup = groups[0]

    with api.settings(warn_only=True):
        if sudo('getent passwd {0}'.format(username)):
            cmd = usermod
        else:
            cmd = useradd

    api.execute(cmd, 
            defgroup=defgroup, 
            groups=groups, 
            host='root@' + api.env['host'], 
            **data)

@api.task
def deluser(username, homedir=False):
    """
    Remove username from the context host.

    With homedir=True, also scrub the homedir.
    """
    removeHome = "--remove-home" if homedir else ""
    sudo("deluser {0} {1}".format(removeHome, username))


@api.task
def rsyncMigrate(fromHost):
    """
    Use rsync and other tools to copy filesystem and postgresql data
    from fromHost to the context host
    """
    cmd = ("rsync -avR "
            "/home "
            "/etc/logrotate.d "
            "/etc/ssh/ssh_host* "
            "/etc/cron.d "
            "/etc/nginx "
            "/usr/local "
            "/var/spool/cron "
            "/etc/apache2 " +
            api.env['host'] + ":/ ")
    api.execute(sudo, cmd, host='root@' + fromHost)
