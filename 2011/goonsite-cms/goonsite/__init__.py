"""The website goonmill.org"""
from twisted.python.util import sibpath

RESOURCE = lambda f: sibpath(__file__, f)

from goonsite.web import root

