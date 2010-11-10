"""
Grammar for SeeDo
"""
from pymeta.grammar import OMeta

from seedo import util

class Action(object):
    """
    An action a user can perform to achieve a new ui state
    """
    def __init__(self, name, event, target):
        self.name = name
        if event:
            assert len(event) == 2, "malformed event %r" % (event,)
            self.selector = event[0]
            self.eventCall = event[1]
        self.target = target

def d(x):
    print x


class UIState(object):
    """
    One state the UI can be, with things that the user can do
    """
    actions = ()
    def __init__(self, name, ids):
        self.name = name
        self.ids = ids
        self.actions = []

    def addAction(self, action):
        self.actions.append(action)

seedoGrammar = open(util.RESOURCE('grammar.txt')).read()

Parser = None

def parse(s):
    """
    Produce a sequence of UIState objects from a text representation of a
    seedo diagram
    """
    globs = globals().copy()
    global Parser
    if Parser is None:
        Parser = OMeta.makeGrammar(seedoGrammar, globs, "Parser")
    return Parser(s).apply('uiTests')

