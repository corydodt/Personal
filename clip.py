#!python24.dll
import site

import sys, os
from twisted.python import usage
import win32clipboard as cb

class Options(usage.Options):
    synopsis = "some-program | clip [options]"
    optParameters = [['path', 'p', None, 
'''Copy the absolute path of the filename to the clipboard'''],
                     ['svn', None, None, 
'''Copy the absolute path of an svn working copy to the clipboard'''],
                     ]
    optFlags = [['keep-newline', 'N', '''The default is to remove the trailing
    newline in the output before copying to the clipboard.  With -N, the
    newline is not removed.'''],
                ]

    def __init__(self):
        usage.Options.__init__(self)
        self['status'] = 0
        self['text'] = None

    def opt_path(self, path):
        self['text'] = os.path.abspath(path)

    def opt_svn(self, svnpath):
        import pysvn
        cli = pysvn.Client()
        self['text'] = cli.info(svnpath).url

    def postOptions(self):
        text = self['text']
        cb.OpenClipboard(0)
        try:
            if text is None:
                self['text'] = sys.stdin.read()
            if not self['keep-newline']:
                text = self['text'].rstrip('\r\n')
            cb.EmptyClipboard()
            cb.SetClipboardText(text)
        finally:
            if not cb.GetClipboardData() == text:
                self['status'] = 1
            cb.CloseClipboard()

def run(argv=sys.argv):
    o = Options()
    try:
        o.parseOptions(argv[1:])
    except usage.UsageError, e:
        print >>sys.stderr, str(o)
        print >>sys.stderr, str(e)
        return 1
    return o['status']

if __name__ == '__main__':
    sys.exit(run())
