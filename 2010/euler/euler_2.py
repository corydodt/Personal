def loopFib(max=4000000):
    initial = 1
    _prev = 0
    _top = initial
    while True:
        _prev, _top = _top, _top + _prev
        if _top > max:
            break
        print _top
        yield _top
    print

print sum((x for x in loopFib() if x%2 == 0))
