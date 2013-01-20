import os.path


def isAvailable(module):
    return os.path.exists('/etc/apache2/mods-available/{0}.load'.format(module))

def loadModule(module):
    return not __salt__['cmd.run_all']('a2enmod {0}'.format(module))['retcode']

def unloadModule(module):
    return not __salt__['cmd.run_all']('a2dismod {0}'.format(module))['retcode']

def configTest():
    test = __salt__['cmd.run_all']('apache2ctl configtest')
    return test

