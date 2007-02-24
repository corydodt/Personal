"""The website thesoftworld.com"""
from twisted.python.util import sibpath

RESOURCE = lambda f: sibpath(__file__, f)

from tsw.web import root

