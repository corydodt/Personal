import sys, os
# hack taken from <http://www.livejournal.com/users/glyf/7878.html>
import _winreg
def getGtkPath():
    subkey = 'Software/GTK/2.0/'.replace('/','\\')
    path = None
    for hkey in _winreg.HKEY_LOCAL_MACHINE, _winreg.HKEY_CURRENT_USER:
        reg = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, subkey)
        for vname in ("Path", "DllPath"):
            try:
                try:
                    path, val = _winreg.QueryValueEx(reg, vname)
                except WindowsError:
                    pass
                else:
                    return path
            finally:
                _winreg.CloseKey(reg)

path = getGtkPath()
if path is None:
    raise ImportError("Couldn't find GTK DLLs.")
os.environ['PATH'] += ';'+path.encode('utf8')


# this must happen first because reactors are magikal
from twisted.internet import gtk2reactor
gtk2reactor.install()

# win32all
try:
    from win32ui import CreateFileDialog
    import win32con
except:
    def CreateFileDialog(*args, **kwargs):
        """TODO - use gtk one"""

import gtk
from gtk import glade

from twisted.internet import reactor, defer
from twisted.python import log, usage, util, failure

class {FIXME}Thing:
    def __getattr__(self, name):
        if name.startswith("gw_"):
            return self.glade.get_widget(name[3:])
        raise AttributeError, "%s instance has no attribute %s" % (
            self.__class__, name)

    def __init__(self, deferred, gladefile):
        self.deferred = deferred

        self.glade = glade.XML(gladefile)
        self.glade.signal_autoconnect(self)

    def on_{FIXME}_destroy(self, widget):
        log.msg("Goodbye.")
        self.deferred.callback(None)

class Options(usage.Options):
    optParameters = [['logfile', 'l', None, 'File to use for logging'],
                     ]

def quitWithMessage(fail=failure.Failure()):
    log.err(fail)
    gtk.mainquit()

# for py2exe, make sure __file__ is real
if not os.path.isfile(__file__):
    __file__ = sys.executable

def run(argv = sys.argv):
    o = Options()
    o.parseOptions(argv[1:])
    try:
        logfile = file(o['logfile'], 'w+')
        log.startLogging(logfile)
    except (TypeError, EnvironmentError):
        log.startLogging(sys.stderr)

    gladefile = util.sibpath(__file__, {FIXME}".glade")

    d = defer.Deferred()
    gui = {FIXME}Thing(d, gladefile)

    d.addCallback(gtk.mainquit).addErrback(quitWithMessage)
    reactor.run()

