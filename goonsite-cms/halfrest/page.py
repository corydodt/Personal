"""
The pages in halfrest

TODO: ReST syntax highlighting using e.g. Helene or codepress
"""

import datetime

import pysqlite2

from storm import locals

from nevow import rend, loaders, static, url, util as nevowutil, tags as T
from nevow.inevow import IRequest

from . import converter, TEMPLATE, DBFILE, CHARSHEET_T


def bootstrap(store):
    """
    Create tables when needed
    """
    store.execute(CREATE_SCRIPT)


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
    date14 = locals.Int()
    who = locals.Unicode()

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
            doc.who = req.args['who'][0].decode(charset)
            doc.date14 = int(datetime.datetime.now().strftime('%Y%m%d%H%M%S'))
            self.store.add(doc)
            self.store.commit()

            if docID:
                return url.here
            else:
                return url.here.child('doc').child('%s' % (doc.id,))
        elif req.args.get('delete', None) == ['delete']:
            if 'docID' not in req.args or req.args['docID'][0] == '':
                pass
            else:
                docID = int(req.args['docID'][0])
                doc = self.store.find(Document, Document.id==docID).one()
                self.store.remove(doc)
                self.store.commit()
                return url.here.up().up().up()

        return rend.Page.renderHTTP(self, ctx)

    def render_title(self, ctx, data):
        if self.title is None:
            return ctx.tag.clear()["HalfReST Paste"]
        ctx.tag.fillSlots('title', self.title.encode('utf-8'))
        return ctx.tag

    def render_pastebin(self, ctx, data):
        p = lambda s: ctx.tag.onePattern(s)()

        ctx.tag.fillSlots('sheetTemplate', CHARSHEET_T)


        if self.doc is not None:
            displayDoc = p("displayDoc")
            displayDoc.fillSlots('displayDoc', T.raw(self.body.encode('utf-8')))
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
            if next == 'doc':
                if segs:
                    # no document number, but ends with slash:
                    if segs[0] == '':
                        return url.here.up(), ()
                    else:
                        # document number included
                        next = segs[0]
                        segs = segs[1:]
                        if next.isdigit():
                            id = int(next)
                            doc = self.store.find(Document, Document.id==id).one()
                            if doc is not None:
                                return PastePage(self.store, doc), segs
                            else:
                                return url.here.up().up(), ()
                else:
                    # no document number no slash
                    return url.here.up(), ()

        return rend.Page.locateChild(self, ctx, [next]+list(segs))

    def render_document(self, ctx, data):
        if self.doc is not None:
            return ctx.tag
        return []

    def render_source(self, ctx, data):
        ta = ctx.tag.onePattern('textarea')()
        if self.doc is not None:
            editControls = ctx.tag.onePattern('editControls')()
            editControls.fillSlots('title', self.title)

            ta.fillSlots('textareaClass', 'hidden')
            ta.fillSlots('source', self.doc.text)
            ta.fillSlots('who', self.doc.who)

            docID = ta.onePattern('docID')()
            docID.fillSlots('docID', self.doc.id)

            return ctx.tag[editControls, ta, docID]
        ta.fillSlots('textareaClass', '')
        ta.fillSlots('source', '')
        ta.fillSlots('who', '')
        return ctx.tag[ta]


