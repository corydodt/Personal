"""
euler.4

A palindromic number reads the same both ways. The largest palindrome made
from the product of two 2-digit numbers is 9009 = 91 * 99.

Find the largest palindrome made from the product of two 3-digit numbers.
"""
import operator

def isPalindrome(n):
    return str(n) == str(n)[::-1]

r = []
for m in range(1000, 100, -1):
    for n in range(1000, 100, -1):
        if isPalindrome(m*n):
            r.append((m*n,m,n))

print sorted(r, )[-1]

