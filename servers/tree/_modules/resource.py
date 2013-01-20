"""
Compute some resource limits
"""

def _getLimits():
    memSize = __grains__['rackspaceMemorySize']
    memDefaults = __pillar__['resource']['memory']['defaults']
    if isinstance(memSize, basestring):
        pillarMemory = __pillar__['resource']['memory'][memSize]
        vmLimit = pillarMemory['vmLimit']
        apacheWarn = pillarMemory['apacheWarn']
    else:
        vmLimit = memDefaults['vmLimitMultiplier'] * memSize
        apacheWarn = memSize / 10 / memDefaults['apacheWarnFactor']

    diskSize = __grains__['rackspaceDiskSize']
    diskDefaults = __pillar__['resource']['disk']['defaults']
    if isinstance(diskSize, basestring):
        pillarDisk = __pillar__['resource']['disk'][diskSize]
        diskWarn = pillarDisk['diskWarn']
    else:
        diskWarn = diskSize / diskDefaults['diskWarnFactor']

    return dict(vmLimit=vmLimit, apacheWarn=apacheWarn, diskWarn=diskWarn)

def getLimits():
    return _getLimits()

def getLimit(limit):
    return _getLimits()[limit]
