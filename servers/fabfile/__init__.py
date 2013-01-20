"""
Install a beacon server remotely
"""

import re, sys
import datetime
import pipes

import yaml

from fabric import api

from fabfile import salt
from fabfile import brandnew
from fabfile import util

(util, salt, brandnew ) # for pyflakes


api.env.use_ssh_config = True

# load a list of hostnames that we may operate on, and the roledefs
dutyData = yaml.load(open('pillar/duty.sls'))
api.env.roledefs = dutyData['duty']

def beCareful(env):
    """
    Check roles and hosts against the list of careful hosts, and abort if host
    is disallowed.
    """
    # to prevent sysadmin error, exclude 'careful' hosts and require all hosts to
    # be listed explicitly in duty.sls/everything group
    if 'careful' in env['roles']:
        api.abort("Not allowed: do not use fabric with the 'careful' group")
    everything = env['roledefs']['everything']
    domain = dutyData['domain']
    for n, h in enumerate(env['hosts']):
        if '.' not in h:
            h = h + '.' + domain
            env['hosts'][n] = h

        if h not in everything:
            api.abort("Not allowed: %r must be added to 'everything' in duty.sls" % h)
        if h in env['roledefs']['careful']:
            api.abort("Not allowed: %r is a host in the 'careful' group" % h)


beCareful(api.env)

api.origExecute = api.execute
def carefullyExecute(task, *a, **kw):
    """
    Wrapper for api.execute, asserts the host is not in the careful list

    You can create an explicit exception by marking a task as .readOnly=True
    which bypasses the check.
    """
    if not getattr(task, 'readOnly', None):
        beCareful(api.env)
    return api.origExecute(task, *a, **kw)

api.execute = carefullyExecute


class Logger(object):
    """
    Simultaneously write to both the passed-in input stream and a file
    """
    def __init__(self, stream, filename="fabric.log", bumper=None):
        self.terminal = stream
        self.log = open(filename, "a")
        now = datetime.datetime.now()
        cl = ' '.join(pipes.quote(s) for s in sys.argv)
        if bumper is None:
            bumper = ('{bigline}\n{line}\n{line}\n'
                '{line} {datetime}\n'
                '{line} {cl}\n{line}\n{line}\n'
                '{bigline}\n'.format(
                    bigline='%' * 72,
                    line='%' * 10,
                    datetime=now.strftime('%c'),
                    cl=cl,
                    ))
        self.log.write(bumper)
        self.linebuffer = ''

    def write(self, data):
        self.terminal.write(data)

        # Fabric may be doing unbuffered writes to stdout (a feature), but the
        # writes frequently break in the middle of an escape sequence. That
        # prevents the filtering regex from working.
        # In order to filter out escape sequences, we line-buffer writes to
        # the log.
        self.linebuffer = self.linebuffer + data 
        if '\n' in self.linebuffer:
            n = self.linebuffer.index('\n') + 1
            line = self.linebuffer[:n]
            self.linebuffer = self.linebuffer[n:]
            cleaned = re.sub('(\x1b' + r'.*?m|\r)', '', line)
            self.log.write(cleaned)

    def __getattr__(self, attr):
        return getattr(self.terminal, attr)

sys.stdout = Logger(sys.stdout)
sys.stderr = Logger(sys.stderr, bumper='')


__all__ = ['salt', 'brandnew', 'util']
