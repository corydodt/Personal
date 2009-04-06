"""
HalfReST: The plugin for goonsite-cms
"""

from zope.interface import implements
from twisted.plugin import IPlugin
from goonsite.app import IAppFactory
from halfrest.page import PastePage, dbopen

class HalfrestFactory(object):
    implements(IPlugin, IAppFactory)
    name = "halfrest"
    title = "HalfReST character formatter"
    store = dbopen()

    def getResource(self):
        return PastePage(self.store)


plugin = HalfrestFactory()
