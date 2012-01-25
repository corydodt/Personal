"""
euler.3

The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143 ?
"""
from math import sqrt

knownPrime = set()
knownNotPrime = set()

def isPrime(n):
    if n in knownPrime:
        return True
    if n in knownNotPrime:
        return False

    sn = int(sqrt(n)+1)
    print "trying n==%s sqrt(n)==%s" % (n, sn)
    ret = []
    for x in xrange(2,sn):
        if n%x == 0:
            if isPrime(x):
                ret.append(x)
    print "roots %r" % (ret,)
    if not ret:
        print n, "is prime!"
        knownPrime.add(n)
    else:
        print n, "is not prime.  Largest root: %s" % (ret[-1],)
        knownNotPrime.add(n)
    return len(ret) == 0

isPrime(12)
print
isPrime(600851475143)
print
