"""
Twistd plugin to run thesoftworld-cms

Twisted 2.5 or later is required to use this.
"""

from zope.interface import implements

from twisted.python import usage, util
from twisted.plugin import IPlugin
from twisted.application.service import IServiceMaker
from twisted.application import strports

from nevow import appserver

import goonsite

class Options(usage.Options):
    optParameters = [['port', 'p', '800', 'Port to run on'],
                     ['directory', 'd', '.', 'Directory containing files'],
                     ]

class TheSoftWorldMaker(object):
    """
    Framework boilerplate class: This is used by twistd to get the service
    class.

    Basically exists to hold the IServiceMaker interface so twistd can find
    the right makeService method to call.
    """
    implements(IServiceMaker, IPlugin)
    tapname = "thesoftworld-cms"
    description = "Listen for HTTP requests and simulate the FF partner server"
    options = Options

    def makeService(self, options):
        """
        Construct a sender daemon.
        """
        resource = goonsite.root(options['directory'])
        factory = appserver.NevowSite(resource)
        port = 'tcp:%s' % (options['port'],)
        ## port = 'ssl:%s:privateKey=%s:certKey=%s' % (options['port'],
        ##        options['privkey'], options['certificate'])
        return strports.service(port, factory)

# Now construct an object which *provides* the relevant interfaces

# The name of this variable is irrelevant, as long as there is *some*
# name bound to a provider of IPlugin and IServiceMaker.

serviceMaker = TheSoftWorldMaker()
