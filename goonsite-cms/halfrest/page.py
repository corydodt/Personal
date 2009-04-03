"""
The pages in halfrest

TODO: ReST syntax highlighting using e.g. Helene or codepress
"""

import pysqlite2

from storm import locals

from nevow import rend, loaders, static, url, util as nevowutil, tags as T
from nevow.inevow import IRequest

from . import converter, TEMPLATE, DBFILE, CHARSHEET_T


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

    def convertParts(self):
        """
        Return body and title of converted document
        """
        return converter.convert(self.text, parts=True)


class PastePage(rend.Page):
    addSlash = True
    docFactory = loaders.xmlfile(TEMPLATE)

    def __init__(self, store, doc=None, *a, **kw):
        self.store = store
        self.doc = self.title = self.body = None
        if doc is not None:
            self.doc = doc
            self.body, self.title = doc.convertParts()

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
        if self.title is None:
            return ctx.tag.clear()["HalfReST Paste"]
        ctx.tag.fillSlots('title', self.title)
        return ctx.tag

    def render_pastebin(self, ctx, data):
        p = lambda s: ctx.tag.onePattern(s)()

        ctx.tag.fillSlots('sheetTemplate', CHARSHEET_T)


        if self.doc is not None:
            displayDoc = p("displayDoc")
            displayDoc.fillSlots('displayDoc', T.raw(self.body))
            return ctx.tag[p("miniTitle"), p("form"), displayDoc]
        else:
            return ctx.tag[p("mainTitle"), p("form")]

    def locateChild(self, ctx, segs):
        next = segs[0]
        segs = segs[1:]

        if self.doc is not None:
            if next == 'print':
                return static.Data(self.doc.convert(), 'text/html'), segs
            if next == 'source':
                return static.Data(self.doc.text.encode('utf-8'), 'text/plain; charset=utf-8'), segs
        else:
            if segs and next == 'doc':
                next = segs[0]
                segs = segs[1:]
                if next.isdigit():
                    id = int(next)
                    doc = self.store.find(Document, Document.id==id).one()
                    if doc is not None:
                        return PastePage(self.store, doc), segs
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
            ta.fillSlots('source', self.doc.text)

            docID = ta.onePattern('docID')()
            docID.fillSlots('docID', self.doc.id)

            return ctx.tag[handle, ta, docID]
        ta.fillSlots('textareaClass', '')
        ta.fillSlots('source', '')
        return ctx.tag[ta]


