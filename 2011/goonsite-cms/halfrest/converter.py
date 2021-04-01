"""
Convert RST strings into HTML strings
"""
from docutils.core import publish_parts, publish_string
from docutils.utils import SystemMessage

import cgi

from . import STYLESHEET

def convert(s, parts=False):
    """
    Convert s, an RST string, to an HTML string.  Return the HTML *and* the
    title of the document.

    If parts=True, return the body and title only
    """
    over = {'stylesheet_path': STYLESHEET,
            'link_stylesheet': True,
            'embed_stylesheet': False,
            }
    if parts:
        try:
            parts = publish_parts(s, writer_name="html", settings_overrides=over)
            return parts['body'], parts['title']
        except SystemMessage, e:
            return u'''<h2>%s</h2>
''' % (e.message,), "ERROR CONVERTING THIS DOCUMENT"

    try:
        return publish_string(s, writer_name="html", settings_overrides=over)
    except SystemMessage, e:
        return '''<h2>%s</h2>''' % (cgi.escape(e.message.encode('utf-8')),)
