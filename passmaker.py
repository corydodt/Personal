#!/usr/bin/env python
####
# Quick Password version 1.1
# Copyright (C) 2000 Zaph, Inc.
#    Author: Dan Grassi <Dan@Grassi.org>
#
# This source is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation, version 2.
#
# If you use and/or modify this code please email the author and
# provide an URL where the updated program code can be obtained.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You can retrieve a copy of the GNU Library General Public License
# from http://www.gnu.org/.  For a copy via US Mail, write to the
#
#     Free Software Foundation, Inc.
#     59 Temple Place - Suite 330,
#     Boston, MA  02111-1307
#     USA
####

import sys
import random
import string

from twisted.python import usage


def GetWord(dictFilePath = "/usr/dict/linux.words", minWordLength=4, maxWordLength=6):
    '''
    This function reads a dictionary, extracts a word at random
    ignoring words that start with an uppercase letter (Proper names.)

    The Parameters are as follows:
        dictFilePath   Path to the dictionary                 default = "/usr/dict/linux.words"
        minWordLength  Minimum character length of the words  default = 4
        maxWordLength  Maximum character length of the words  default = 6
    '''
    # Must be at least twice the size of a word in the password dictionary
    kMargin = 100
    inFile = open(dictFilePath, 'r')
    inFile.seek(0, 2)
    fileSize = inFile.tell() - kMargin

    for i in range(1, 1000):
        pointer = random.randint(0, fileSize-kMargin)
        inFile.seek(pointer)
        word = inFile.readline()    # probably does not start on a word boundry
        word = inFile.readline()[:-1]
        if ((minWordLength <= len(word) <= maxWordLength) and (string.lower(word[0]) == word[0])):
            break
    
    inFile.close()

    return word
    


def GetPass(wordCount=2, minWordLength=4, maxWordLength=6, dictFilePath = "/usr/dict/linux.words"):
    '''
    This function reads a dictionary, extracts words at random
    and joins them with a seperator character.

    The Parameters are as follows:
        wordCount      Number od words to join together       default = 2
        minWordLength  Minimum character length of the words  default = 4
        maxWordLength  Maximum character length of the words  default = 6
        dictFilePath   Path to the dictionary                 default = "/usr/dict/linux.words"
    '''

    # Legal separator characters
    separators = "!#%)*+-23456789=]"

    pw = GetWord(dictFilePath, minWordLength, maxWordLength)

    for i in range(1, wordCount):
        pw = pw + random.choice(separators) + GetWord(dictFilePath, minWordLength, maxWordLength)


    return pw


class PassmakerOptions(usage.Options):
    optParameters=[["wordcount", "w", "3", "Number of words in password"],
                   ["minlength", "n", "3", "Minimum length of each word"],
                   ["maxlength", "x", "5", "Maximum length of each word"],
                   ["dictionary", "d", "/usr/share/dict/american-english",
                    "Filename of dictionary for retrieving words"],
                   ]

if __name__ == '__main__':
    o=PassmakerOptions()
    o.parseOptions(sys.argv[1:])
    print GetPass(int(o['wordcount']), int(o['minlength']),
                 int(o['maxlength']), o['dictionary'])
