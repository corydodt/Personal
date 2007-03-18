"""
Add a .pth file to this location, using the given .pth filename

If no .pth filename is given, guess (looks for the first Python package in the
directory).
"""

import sys, os.path
from distutils import sysconfig

def run(argv=None):
    if argv is None:
        argv = sys.argv

    dirname = sys.argv[1]
    if len(sys.argv) > 2:
        pthfile = sys.argv[2]
    else:
        try:
            pthfile = guessPthFilename(dirname)
        except NoUsefulGuess:
            sys.stderr.write(
"Please give a filename.pth argument, couldn't guess the dirname\n")
            sys.exit(1)

    LIBDEST = sysconfig.get_config_var('LIBDEST')

    abspth = os.path.join(LIBDEST, 'site-packages', pthfile)

    absdirname = os.path.abspath(dirname)

    file(abspth, 'w').write(absdirname + '\n')

    print "Updated %s to contain %s" % (pthfile, absdirname)


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
    run()
