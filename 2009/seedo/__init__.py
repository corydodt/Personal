"""
SeeDo - a syntax for describing tests, based on
http://37signals.com/svn/posts/1926-a-shorthand-for-designing-ui-flows

sales page {
    sign up (#signup).click() -> signup page;
    log out (#logout).click() -> logged out page;
    more info (#moreInfo).click() -> more info page
}

signup page #signupPage {
    fill out form (name=signupForm).formFill(name="Cory Dodt",
        username="corydodt", policyCheckbox=True)
}

logged out page {}

more info page #moreInfoPage {
    log out (#logout).click() -> logged out page
}

ideas:

    - declarative syntax instead of procedural: define all paths through
      UI-space, and let the runner figure out what order to run them most
      efficiently

    - states are named; name is any text before first syntax element; name is
      shown in test failures

    - states are also id'd; terminate state with # then single word as id
      (uri?)

    - actions are named; name is any text before first syntax element
    
    - actions have event name and selector; written similar to jquery
      syntax e.g. (#foo .bar).click() or (#bar).type("lalala")

    - actions without selector are considered todos; during test runtime these
      will cause warnings

    - verifications are written in python code which uses decorator to bind it
      to a single ui state, by that state's id. if no python desired, a string
      can be used as verifier e.g. 
        action-name (action-selector).actionEvent() "expected string"

    - want the ability to render screenshots of failures; overwrite screenshot
      with red text such as "failed: from state 'sample sources' did (#foo
      .bar).click() and expected state 'new sample source' next"; or "failed:
      from state 'sample sources' tried action (#bar).type("lalala") but
      couldn't do that"

problems:
    - what if you actually need a sequence? for example, entering the contents
      of several quota cells (each with its own ajax call); maybe, between
      each, check project summary to see new quota info appear there.  naive
      solution requires a new uistate for each of those project summaries,
      furthermore since order is not enforced, seedo would be free to enter
      all the quota data at once, then check project summary a bunch of times
      at once.  Maybe use [brackets] to set off a sequence of actions.  And
      maybe ui states can have multiple ids!  Then the id would be passed to
      the python verifier as an argument.  Verifiers would be registered with
      more than one id as well, if desired.
"""
