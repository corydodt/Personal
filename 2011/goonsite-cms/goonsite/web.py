from zope.interface import implements

from twisted.web import microdom, twcgi

from nevow import static, rend, loaders, tags as T, inevow, vhost

from goonsite import RESOURCE
from goonsite.app import AppDispatchURL

class GoonsiteHTML(rend.Page):
    """
    Render an HTML page inside goonsite's template
    """
    docFactory = loaders.xmlfile(RESOURCE('templates/goonsite.xhtml'))
    def __init__(self, path, registry, *a, **kw):
        self.path = path
        self.registry = registry
        doc = microdom.parse(self.path)
        self.content = doc.getElementsByTagName('body')[0].childNodes

        # we will get title out of the original's <head> so we can replace it
        # with a default when necessary.
        _title = doc.getElementsByTagName('title')
        if len(_title) >= 1:
            title = _title[0]
            self.titleNodes = title.childNodes
        else:
            self.titleNodes = None
            title = None

        # then, everything else in original's head
        _head = doc.getElementsByTagName('head')
        if len(_head) >= 1:
            head = _head[0]
            self.originalHead = [n for n in head.childNodes if n is not title]
        else:
            self.originalHead = []

        rend.Page.__init__(self, *a, **kw)

    def render_includedHead(self, ctx, data):
        return self.originalHead

    def render_title(self, ctx, data):
        if self.titleNodes is None:
            return ctx.tag
        return T.title[self.titleNodes]

    def render_everything(self, ctx, data):
        ctx.tag.fillSlots('contentMain', self.content)
        return ctx.tag


class GoonsitePage(static.File):
    """
    Root page
    """
    processors = {'.tsw': GoonsiteHTML}
    indexNames = ['index.tsw'] + list(static.File.indexNames)

    def locateChild(self, ctx, segs):
        if segs[0] == 'a':
            # The /a URL is where our plugin apps live.
            return AppDispatchURL(), segs[1:]
        if segs[0] == 'cgi-bin':
            dir = '/usr/lib/cgi-bin'
            return twcgi.CGIDirectory(dir), segs[1:]
        return static.File.locateChild(self, ctx, segs)


class VhostFakeRoot(object):
    """
    I am a wrapper to be used at site root when you want to combine 
    vhost.VHostMonsterResource with nevow.guard. If you are using guard, you 
    will pass me a guard.SessionWrapper resource.
    """
    implements(inevow.IResource)
    def __init__(self, wrapped):
        self.wrapped = wrapped
    
    def renderHTTP(self, ctx):
        return self.wrapped.renderHTTP(ctx)
        
    def locateChild(self, ctx, segments):
        """Returns a VHostMonster if the first segment is "VHOST". Otherwise
        delegates to the wrapped resource."""
        if segments[0] == "VHOST":
            return vhost.VHostMonsterResource(), segments[1:]
        else:
            return self.wrapped.locateChild(ctx, segments)


def root(directory):
    return VhostFakeRoot(GoonsitePage(directory))


