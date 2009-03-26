"""
Make it possible and simple to plug applications into goonsite
"""

from zope.interface import Interface
from twisted.plugin import getPlugins
from nevow import rend, url, loaders, page, tags as T

from goonsite import RESOURCE

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


APPS = loadApps()


class AppList(page.Element):
    docFactory = loaders.xmlfile(RESOURCE('templates/AppList'))
    @page.renderer
    def appList(self, req, tag):
        pg = tag.patternGenerator("app")
        for url, app in APPS.items():
            item = pg()
            item.fillSlots('href', '%s/' % (url,))
            item.fillSlots('link text', app.title)
            tag[item]
        return tag

class AppDispatchURL(rend.Page):
    # restart to refresh the apps list.
    addSlash = True
    docFactory = loaders.xmlfile(RESOURCE('templates/goonsite.xhtml'))
    def locateChild(self, ctx, segs):
        next, rest = segs[0], segs[1:]
        if next in APPS:
            r = APPS[next].getResource()
            print r
            return r, rest
        return self, rest

    def render_includedHead(self, ctx, data):
        return []

    def render_title(self, ctx, data):
        return T.title["Application List"]

    def render_everything(self, ctx, data):
        ctx.tag.fillSlots('contentMain', AppList())
        return ctx.tag
