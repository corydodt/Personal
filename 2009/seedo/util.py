from twisted.python.util import sibpath

import seedo
RESOURCE = lambda f: sibpath(seedo.__file__, f)
