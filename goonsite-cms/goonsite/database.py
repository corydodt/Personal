"""
A very simple database layer for goonsite apps to use.
"""
import os

from storm import locals as L


def cannotCreateDatabase(store):
    """
    Default implementation just fails if the database does not exist
    """
    assert 0, "Cannot create this store"

def dbopen(dbfile, bootstrapHook=cannotCreateDatabase):
    """
    Open a Storm database from SQLite file dbfile or, if not possible, create
    one by calling bootstrapHook.

    bootstrapHook is a function which takes one argument, a newly initialized
    storm.store.Store.  bootstrapHook should use this Store to execute the SQL
    necessary to create the database.
    """
    if os.access(dbfile, os.F_OK) and not os.access(dbfile, os.W_OK):
        raise IOError("Database file %s is not writeable" % (dbfile,))

    db = L.create_database('sqlite:///%s' % (dbfile,))
    if not os.access(dbfile, os.F_OK):
        store = L.Store(db) # this physically creates the disk file which
                                 # is why we have to check for existence first
        bootstrapHook(store)
    else:
        store = L.Store(db)
    return store


