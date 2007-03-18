import os
import sys

import win32api

from twisted.python.procutils import which

cygwinlink = os.path.join(os.environ['HOME'], 'Application Data', 'Microsoft',
                          'Internet Explorer', 'Quick Launch', 'Cygwin')

if __name__ == '__main__':
    os.environ['START_DIR'] = ' '.join(sys.argv[1:]) or os.getcwd()
    win32api.ShellExecute(0, 'open', cygwinlink, None, None, 0)
