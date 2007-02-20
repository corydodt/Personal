"""
Add a .pth file to this location, using the given .pth filename

If no .pth filename is given, guess (looks for the first Python package in the
directory).
"""

import sys, os.path
from distutils import sysconfig

def usage():
    sys.stderr.write(
"""makepth: Write a .pth file to the stdlib, using the given directory.
If the directory contains a Python package, the filename of the .pth
file can be inferred from that.  Otherwise, pass the name of the .pth
file explicitly as the second argument.

Usage: makepth <directory> [filename.pth]
""")


def run(argv=None):
    if argv is None:
        argv = sys.argv

    dirname = sys.argv[1]
    if len(sys.argv) > 2:
        pthfile = sys.argv[2]
        if os.path.isdir(pthfile):
            usage()
            sys.stderr.write(
"""** When giving the .pth filename explicitly, it must be the second argument.
** The second argument you gave, %s, is a directory.
""" % (pthfile,))
            return 1
    else:
        try:
            pthfile = guessPthFilename(dirname)
        except NoUsefulGuess:
            usage()
            sys.stderr.write(
"** Please give a filename.pth argument, couldn't guess the dirname\n")
            return 1

    LIBDEST = sysconfig.get_config_var('LIBDEST')

    abspth = os.path.join(LIBDEST, 'site-packages', pthfile)

    absdirname = os.path.abspath(dirname)

    file(abspth, 'w').write(absdirname + '\n')

    print "Updated %s to contain %s" % (pthfile, absdirname)
    return 0


class NoUsefulGuess(Exception):
    """Couldn't find any package in that directory"""
    
def guessPthFilename(dr):
    """Guess the name of the package that should be given for the pth
    filename
    """
    for d in os.listdir(dr):
        if os.path.exists(os.path.join(dr, d, '__init__.py')):
            return '%s.pth' % (d,)
    raise NoUsefulGuess()


if __name__ == '__main__':
    sys.exit(run())
