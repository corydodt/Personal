"""
The pages in halfrest

TODO: ReST syntax highlighting using e.g. Helene or codepress
"""

import pysqlite2

from storm import locals

from nevow import rend, loaders, static, url, util as nevowutil
from nevow.inevow import IRequest

from . import converter, TEMPLATE, DBFILE


def bootstrap(store):
    """
    Create tables when needed
    """
    store.execute("CREATE TABLE document (id INTEGER PRIMARY KEY, text VARCHAR)")


def dbopen():
    db = locals.create_database('sqlite:///%s' % (DBFILE,))
    store = locals.Store(db)
    try:
        store.execute("select count(*) from document")
    except pysqlite2.dbapi2.OperationalError:
        bootstrap(store)
    return store


class Document(object):
    __storm_table__ = 'document'
    id = locals.Int(primary=True)
    text = locals.Unicode()

    def convert(self):
        return converter.convert(self.text)


class PastePage(rend.Page):
    addSlash = True
    docFactory = loaders.xmlfile(TEMPLATE)

    def __init__(self, store, appURL=None, doc=None, *a, **kw):
        self.appURL = appURL
        self.store = store
        self.doc = None
        if doc is not None:
            self.doc = doc

    def renderHTTP(self, ctx):
        """
        Render new paste, render the document page, or process a form post.
        """
        req = IRequest(ctx)
        # accept form post when 'convert' was clicked.
        if 'convert' in req.args:
            docID = None
            if 'docID' in req.args and req.args['docID'][0] != '':
                docID = int(req.args['docID'][0])
                doc = self.store.find(Document, Document.id==docID).one()
            else:
                doc = Document()
            charset = nevowutil.getPOSTCharset(ctx)
            doc.text = req.args['text'][0].decode(charset)
            self.store.add(doc)
            self.store.commit()

            if docID:
                return url.here
            else:
                return url.here.child('doc').child('%s' % (doc.id,))
        return rend.Page.renderHTTP(self, ctx)

    def render_title(self, ctx, data):
        # TODO - incorporate the document's title
        return ctx.tag["HalfReST Paste"]

    def render_pastebin(self, ctx, data):
        p = lambda s: ctx.tag.onePattern(s)()

        if self.doc is not None:
            return ctx.tag[p("miniTitle"), p("form"), p("displayDoc")]
        else:
            return ctx.tag[p("mainTitle"), p("form")]

    def locateChild(self, ctx, segs):
        next = segs[0]
        segs = segs[1:]
        if self.doc is not None:
            if next == 'convert':
                return static.Data(self.doc.convert(), 'text/html'), segs

        else:
            if next == 'doc':
                next = segs[0]
                segs = segs[1:]
                if next.isdigit():
                    id = int(next)
                    doc = self.store.find(Document, Document.id==id).one()
                    if doc is not None:
                        return PastePage(self.store, self.appURL, doc), segs
                    else:
                        return url.here.up().up(), ()

        return rend.Page.locateChild(self, ctx, [next]+list(segs))

    def render_document(self, ctx, data):
        if self.doc is not None:
            return ctx.tag
        return []

    def render_source(self, ctx, data):
        ta = ctx.tag.onePattern('textarea')()
        if self.doc is not None:
            handle = ctx.tag.onePattern('textareaHandle')()

            ta.fillSlots('textareaClass', 'hidden')
            ta[self.doc.text]

            docID = ctx.tag.onePattern('docID')()
            docID.fillSlots('docID', self.doc.id)

            return ctx.tag[handle, ta, docID]
        ta.fillSlots('textareaClass', '')
        return ctx.tag[ta]


