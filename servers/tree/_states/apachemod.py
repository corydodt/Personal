"""
Loading and unloading of apache modules.
========================================

The apache modules on a system can be managed cleanly with the apachemod state
module:

.. code-block:: yaml E.g.:

apache:
    service:
        - running
        - watch:
            - apachemod: mymodules
mymodules:
    apachemod.managedList:
        modules:
            - ssl
            - proxy
            - rewrite
            - -security


"""

import os.path



def _getModules():
    modules = __salt__['apache.modules']()
    allModules = modules['static'] + modules['shared']
    return [x.split('_module')[0] for x in allModules]


def managedList(name, modules=()):
    """
    Ensure that the list of managed apache modules is the same.
    
 
    name
    Is arbitrary and does not affect behavior.
 
    modules 
    The modules that we will keep installed or uninstalled.
    A name by itself means "keep this module installed," a name prefixed with
    a - means "keep this module uninstalled."
    """
    changes = {}
    ret = {'name': name,
           'result': True,
           'changes': changes,
           'comment': ''}

    current = set(_getModules())
    expected = current.copy()
    
    for mod in modules:
        if mod.startswith('-'):
            mod = mod[1:]
            if mod in expected:
                expected.remove(mod)
        else:
            expected.add(mod)

    added = expected - current
    if added:
        changes['added'] = repr(tuple(added))
    removed = current - expected
    if removed:
        changes['removed'] = repr(tuple(removed))
 
    if not added and not removed:
        ret['comment'] = 'Apache module list unchanged'
        return ret
 
    # we are transitioning to a new module list
    ret['comment'] = 'Apache modules are changing. (add:{a} remove:{r})'.format(
            a=len(added), r=len(removed))
    if __opts__['test']:
        ret['result'] = None
        return ret

    def appendError(msg):
        ret['comment'] = '{0}\n** {1}'.format(ret['comment'], msg)
 
    for mod in added:
        if not __salt__['apachemod.isAvailable'](mod):
            ret['result'] = False
            appendError('Apache module \'{0}\' is unavailable'.format(mod))

        else:
            if not __salt__['apachemod.loadModule'](mod):
                ret['result'] = False
                appendError('Failed to load \'{0}\''.format(mod))
                # don't return yet, we want to attempt to process all modules
                # before we fail so we don't leave this job partly done.
 
    for mod in removed:
        if not __salt__['apachemod.unloadModule'](mod):
            ret['result'] = False
            appendError('Failed to remove \'{0}\''.format(mod))
 
    test = __salt__['apachemod.configTest']()
    if not not test['retcode']:
        ret['comment'] = 'configtest after apache module management failed\n{0}'.format(test['stderr'])
        ret['result'] = False
        return ret
 
    return ret

