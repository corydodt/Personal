#!python24.dll
import site

import sys, os

from win32process import CreateProcess, STARTUPINFO
import win32process, win32con, win32api

from twisted.python.procutils import which

def cygpath(filename):
    """Return a windows-y (mixed) path for filename, which may be unix-y"""
    # this is pretty slow.
    return os.popen('%s -m "%s"' % (which('cygpath')[0], filename)).read().strip()

def run(argv=None):
    if argv is None:
        argv = sys.argv
    args = []
    exists = os.path.exists
    # munge unix-y path-like args into windows-y path-like args
    for a in argv[1:]:
        if exists(a):
            kept = a
        else:
            # delay the call to cygpath until here, where it's necessary
            _a = cygpath(a)
            # _a may be an existing or new file (new if containing dir exists)
            e = os.path.exists
            if exists(_a) or os.path.isdir(os.path.dirname(_a)):
                kept = _a
            else:
                kept = a
        if ' ' in kept or '\r' in kept or '\n' in kept:
            kept = '"%s"' % (kept,)
        args.append(kept)

    # read from stdin, which is sometimes useful
    si = STARTUPINFO() # I hate boilerplate crap
    si.hStdInput = win32api.GetStdHandle(win32api.STD_INPUT_HANDLE)
    si.dwFlags = win32process.STARTF_USESTDHANDLES


    # clobber $SHELL, which breaks ! commands when set to something Cygwin-y
    os.environ['SHELL'] = os.environ['COMSPEC']
    CreateProcess(None, 
                  r'%s %s' % (which("gvim_.exe")[0], ' '.join(args)),
                  None, None, 1,
                  win32con.CREATE_NO_WINDOW, None, None, si)
    return 1


if __name__ == '__main__':
    sys.exit(run())
