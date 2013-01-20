"""
Probe durable configuration of postgresql if it is installed
"""

import os
import re
import operator

from salt.grains.core import __salt__

def postgresqlClusters():
    """
    Return a list of all clusters on the machine
    """
    os.environ['PGUSER'] = 'postgres'
    try:
        l = __salt__['cmd.run'](
                'x=$(pg_lsclusters -h | awk \'{ print $1"/"$2 }\') || x=""; echo $x'
                ).split()
        mains = []
        others = []
        for cl in l:
            vv, cc = cl.split('/')
            dct = {'version': vv, 'cluster': cc}
            # the main clusters will be first in the list
            if cc == 'main':
                mains.append(dct)
            else:
                others.append(dct)
        mains = sorted(mains, 
                reverse=True,
                key=operator.itemgetter('version')) # put the highest-versioned main first
        ll = mains + others
    except Exception, e:
        ll = []
    if ll == []:
        ver = __salt__['cmd.run'](
                'dpkg -s postgresql | grep Version | egrep -o "[0-9]+\.[0-9]+"')
        ll = [{'version': str(ver), 'cluster': 'main'}]
    return {'postgresqlClusters': ll}

