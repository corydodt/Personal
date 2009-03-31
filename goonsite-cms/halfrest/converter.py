"""
Convert RST strings into HTML strings
"""
from docutils.core import publish_parts, publish_string

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
        parts = publish_parts(s, writer_name="html", settings_overrides=over)
        return parts['body'], parts['title']
    return publish_string(s, writer_name="html", settings_overrides=over)
