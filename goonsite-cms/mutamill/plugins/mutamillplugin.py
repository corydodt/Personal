"""
Mutamill: The mutagenic chargen

!!! Install this file in, e.g. /usr/lib/python2.5/site-packages/goonsite/plugins/
"""

from zope.interface import implements
from twisted.plugin import IPlugin
from goonsite.app import IAppFactory, dbopen
from mutamill.page import MillPage
from mutamill import DBFILE

class MutamillFactory(object):
    implements(IPlugin, IAppFactory)
    name = "mutamill"
    title = "Mutamill Chargen"
    store = dbopen(DBFILE)

    def getResource(self):
        return PastePage(self.store)


plugin = HalfrestFactory()
