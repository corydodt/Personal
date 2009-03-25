"""
Make it possible and simple to plug applications into goonsite
"""

from zope.interface import Interface
from twisted.plugin import getPlugins
from nevow import rend, url

class IAppFactory(Interface):
    def getResource():
        """
        Return a new instance of a page or resource which can be rendered here
        """

def loadApps():
    """
    Read the IResource plugins
    """
    import goonsite.plugins
    plugins = getPlugins(IAppFactory, goonsite.plugins)
    return dict([(p.name, p) for p in plugins])


class AppDispatchURL(rend.Page):
    # restart to refresh the apps list.
    apps = loadApps()
    addSlash = True
    def locateChild(self, ctx, segs):
        next = segs[0]
        if next in self.apps:
            return self.apps[next].getResource(), segs[1:]
        return None, segs[1:]
