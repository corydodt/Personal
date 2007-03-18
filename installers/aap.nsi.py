import os, sys

orig = os.getcwd()
os.chdir(sys.argv[1])
try:
    adds = ['!macro installfiles']
    deletes = ['!macro deletefiles']
    for dir, _, filenames in os.walk('.'):
        dir = os.sep.join(dir.split(os.sep)[1:]) # eliminate the leading dot
        if dir != '': dir = dir + os.sep
        adds.append('SetOutPath "$INSTDIR\\%s"' % (dir,))
        # insert(1,) ensures that deletes will be written in reverse
        # order from adds
        deletes.insert(1, 'RMDir "$INSTDIR\\%s"' % (dir,))
        for f in filenames: 
            adds.append('File %s\\%s%s' % (sys.argv[1], dir, f,))
            deletes.insert(1, 'Delete $INSTDIR\\%s%s' % (dir, f,))
    adds.append('!macroend')
    deletes.append('!macroend')

    os.chdir(orig)
    macro = file('_aapmacro.nsh', 'w')
    macro.write('\n'.join(adds + deletes))
finally:
    os.chdir(orig)
print "Generated _aapmacro.nsh"
