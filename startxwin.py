import os, sys

from win32process import CreateProcess, STARTUPINFO
from win32api import MessageBox
import win32con as W

from twisted.python.procutils import which

def getCygwinHome():
    import _winreg
    # note: '/' is a key name, not a typo
    sub = r'SOFTWARE\Cygnus Solutions\Cygwin\mounts v2\/'
    print sub

    for hkey in _winreg.HKEY_LOCAL_MACHINE, _winreg.HKEY_CURRENT_USER:
        reg = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, sub)
        try:
            try:
                path, val = _winreg.QueryValueEx(reg, 'native')
            except WindowsError:
                pass
            else:
                return path
        finally:
            _winreg.CloseKey(reg)

    

if __name__ == '__main__':
    cyghome = getCygwinHome().encode('utf8')
    os.environ['PATH'] += ';' + cyghome + r'\bin'
    os.environ['PATH'] += ';' + cyghome + r'\usr\X11R6\bin'
    try:
        xpath = which("XWin.exe")[0]
    except IndexError:
        m = MessageBox(0, 
                   r"Please add X11R6\bin to the System Path.",
                   "Can't Start X",
                   W.MB_OK | W.MB_ICONERROR | W.MB_TOPMOST,)
        sys.exit(1)

    si = STARTUPINFO() # I hate boilerplate crap
    CreateProcess(None, 
                  r'%s  -multiwindow -logfile "%s\XWin.log" -clipboard -ac ' 
                   '-swcursor ' % 
                    (xpath, os.environ['USERPROFILE']),
                  None, None, 1,
                  W.CREATE_NO_WINDOW, None, None, si)

