"""
HalfReST

Paste a RestructuredText document, get the formatted document.
"""
from twisted.python import util


RESOURCE    =  lambda s: util.sibpath(__file__, s)
TEMPLATE    =  RESOURCE('halfrest.xhtml')
DBFILE      =  RESOURCE('halfrest.db')
STYLESHEET  =  RESOURCE('character.css')
