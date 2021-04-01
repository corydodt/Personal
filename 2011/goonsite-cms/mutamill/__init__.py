"""
Mutamill, the mutagenic chargen
"""
from twisted.python import util


RESOURCE       =   lambda s: util.sibpath(__file__, s)
DBFILE         =   RESOURCE('mutamill.db')
CREATE_SCRIPT  =   """  
CREATE TABLE character (id INTEGER PRIMARY KEY, 
"""
