"""
Convert RST strings into HTML strings
"""
from docutils.core import publish_string

from . import STYLESHEET

def convert(s):
    """
    Convert s, an RST string, to an HTML string.
    """
    return publish_string(s, writer_name="html",
            settings_overrides={'stylesheet_path':STYLESHEET}
            )
