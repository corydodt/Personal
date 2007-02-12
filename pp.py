#!/usr/bin/env python
import sys
import os

try:
  # this is easier than figuring out how to make cygwin fix it
  import msvcrt
  msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)
except ImportError:
  pass

import imp
from twisted.python import usage

class Options(usage.Options):
    """Search sys.path for files or module names.  Look for filename first 
    and if not found look for a Python module name.

    Caveats: 
    1) Will find a matching filename, even a directory, before a matching
    modulename.  For example, if you have a package myessay containing a
    module named doc.py, "pp myessay.doc" would return doc.py, unless there
    was already a file named myessay.doc sitting around in your sys.path.

    2) There's no way to find a non-module filename (e.g. a data file) that's
    inside a package.  For example, if you have a module foo, containing a file
    named config.ini, there's no way to find config.ini with pp.  If
    config.ini is a sibling of foo, you could find it.

    3) pp will return a module's filename even if you give a name inside the
    module, for example, "pp compileall.compile_dir" will return the path to
    compileall.py.  Usually this is what you want, but it might be
    surprising that "pp compileall.THIS_DOES_NOT_EXIST" also returns
    compileall.py with no warning or error.  Nevertheless, it does.  This is
    because pp will not actually import compileall, by design; it simply keeps
    trying modules until it gets an ImportError.
    """
    optFlags = [["all", "A", 
                 "Show all the matching files found in the python path, "
                 "in order."],
                 ]

    def parseArgs(self, args):
        if len(args) != 1:
            raise usage.UsageError("Provide a single filename to find.")
        self['filename'] = args[0]

def findDotted(name):
    """Return a filename by trying each dotted element."""
    nodes = name.split(".")
    found = None
    for name in nodes:
        if found is None:
            searchpath = sys.path
        else:
            searchpath = [found]
        try:
            _, found, _ = imp.find_module(name, searchpath)
        except ImportError, e:
            if found is None:
                raise FileNotFoundError(name)
            else:
                break
    return found

def find(name):
    for p in sys.path:
        if os.path.isdir(p):
            file_p = os.path.join(p, name)
            if os.path.exists(file_p):
                return file_p
    return findDotted(name)


class FileNotFoundError(EnvironmentError):
    def __init__(self, name): 
        self.name = name
    def __str__(self): 
        return "File %s was not found." % (self.name,)


def run(argv=sys.argv):
    opt = Options()
    try:
        opt.parseArgs(argv[1:])
    except usage.UsageError, e:
        print str(opt)
        print str(e)
        sys.exit(1)

    try:
        sys.stdout.write(find(opt['filename']) + '\n')
    except FileNotFoundError, e:
        print >>sys.stderr, e

    

if __name__ == '__main__':
    run()
