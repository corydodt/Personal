from twisted.web import microdom

from nevow import static, rend, loaders, tags as T

from tsw import RESOURCE

class TheSoftWorldHtml(rend.Page):
    """
    Render an HTML page inside tsw's template
    """
    docFactory = loaders.xmlfile(RESOURCE('tsw.xhtml'))
    def __init__(self, path, registry, *a, **kw):
        self.path = path
        self.registry = registry
        doc = microdom.parse(self.path)
        self.content = doc.getElementsByTagName('body')[0].childNodes
        _title = doc.getElementsByTagName('title')
        if len(_title) >= 1:
            self.titleNodes = _title[0].childNodes
        else:
            self.titleNodes = None
        rend.Page.__init__(self, *a, **kw)

    def render_title(self, ctx, data):
        if self.titleNodes is None:
            return ctx.tag
        return T.title[self.titleNodes]


    def render_everything(self, ctx, data):
        ctx.tag.fillSlots('contentMain', self.content)
        return ctx.tag

class TheSoftWorldPage(static.File):
    """
    Root page
    """
    processors = {'.tsw': TheSoftWorldHtml}
    indexNames = ['index.tsw'] + list(static.File.indexNames)

def root(directory):
    return TheSoftWorldPage(directory)
