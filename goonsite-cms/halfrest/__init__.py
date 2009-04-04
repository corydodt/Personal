"""
HalfReST

Paste a RestructuredText document, get the formatted document.
"""
from twisted.python import util


RESOURCE       =   lambda s: util.sibpath(__file__, s)
TEMPLATE       =   RESOURCE('halfrest.xhtml')
DBFILE         =   RESOURCE('halfrest.db')
STYLESHEET     =   '/static/character.css'
CHARSHEET_T    =   open(RESOURCE('Charsheet_template.txt')).read()
CREATE_SCRIPT  =   """  
CREATE TABLE document (id INTEGER PRIMARY KEY, text VARCHAR, who VARCHAR,
               date14 char(14));
"""
