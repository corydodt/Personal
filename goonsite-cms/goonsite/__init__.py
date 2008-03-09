"""The website thesoftworld.com"""
from twisted.python.util import sibpath

RESOURCE = lambda f: sibpath(__file__, f)

from goonsite.web import root

