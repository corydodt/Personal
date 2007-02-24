from twisted.web import microdom

from nevow import static, rend, loaders

from tsw import RESOURCE

class TheSoftWorldHtml(rend.Page):
    """
    Render an HTML page inside tsw's template
    """
    docFactory = loaders.xmlfile(RESOURCE('tsw.xhtml'))
    def __init__(self, path, registry, *a, **kw):
        self.path = path
        self.registry = registry
        rend.Page.__init__(self, *a, **kw)

    def render_everything(self, ctx, data):
        return ctx.tag

    def render_contentMain(self, ctx, data):
        """
        Pull everything out of the body of the static file
        and fill contentMain with it.
        """
        doc = microdom.parse(self.path)
        nodes = doc.getElementsByTagName('body')[0].childNodes
        title = doc.getElementsByTagName('title')
        if len(title) >= 1:
            titleNodes = title[0].childNodes
        else:
            titleNodes = ''
        ctx.tag.fillSlots('contentMain', nodes)
        ctx.tag.fillSlots('title', titleNodes)
                
        return ctx.tag

class TheSoftWorldPage(static.File):
    """
    Root page
    """
    processors = {'.tsw': TheSoftWorldHtml}
    indexNames = ['index.tsw'].extend(static.File.indexNames)

def root(directory):
    return TheSoftWorldPage(directory)
