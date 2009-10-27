"""
Tests for the syntax and grammar of SeeDo
"""

from twisted.trial import unittest

from seedo import grammar


class GrammarTest(unittest.TestCase):
    def test_oneUnit(self):
        """
        A single, unconnected unit
        """
        def check1(parsed, name, actions):
            self.assertEqual(parsed[0].name, name)
            self.assertEqual([a.name for a in parsed[0].actions], actions)

        t = "see|do"
        check1(grammar.parse(t), "see", ["do"])

        t2 = "see | do1 ;do2"
        check1(grammar.parse(t2), "see", ["do1", "do2"])

        t3 = " see||"
        check1(grammar.parse(t3), "see", [])

    def test_connection(self):
        """
        Can connect two elements
        """
        t = "see|do->bar"
        p = grammar.parse(t)
        self.assertEqual(p[0].actions[0].target, "bar")

    def test_event(self):
        """
        Event syntax in actions produces selectors and events
        """
        t = "action name (#id .class[1]).type('hello') -> target"
        p = grammar.Parser(t).apply("action", )
        self.assertEqual(p.name, u'action name')
        self.assertEqual(p.selector, u'#id .class[1]')
        self.assertEqual(p.eventCall, u".type('hello')")

    def test_escapedSelector(self):
        """
        Escaped slashes and parens in selectors work
        """
        t1 = r"this\)has\)parens"
        p = grammar.Parser(t1).apply("selector")
        self.assertEqual(p, r'this\)has\)parens')
        t2 = r"this\\has\\slashies"
        p = grammar.Parser(t2).apply("selector")
        self.assertEqual(p, r'this\\has\\slashies')
