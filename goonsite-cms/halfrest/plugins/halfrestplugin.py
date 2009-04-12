"""
HalfReST: The plugin for goonsite-cms

!!! Install this file in, e.g. /usr/lib/python2.5/site-packages/goonsite/plugins/
"""

from zope.interface import implements
from twisted.plugin import IPlugin

from goonsite.app import IAppFactory
from goonsite.database import dbopen

from halfrest.page import PastePage
from halfrest import DBFILE

class HalfrestFactory(object):
    implements(IPlugin, IAppFactory)
    name = "halfrest"
    title = "HalfReST character formatter"
    store = dbopen(DBFILE)

    def getResource(self):
        return PastePage(self.store)


plugin = HalfrestFactory()
