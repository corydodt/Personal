// rhino.js
// 2009-06-04
/*
Copyright (c) 2002 Douglas Crockford  (www.JSLint.com) Rhino Edition
*/

// This is the Rhino companion to fulljslint.js.

/*extern JSLINT */
/*jslint rhino: true*/

(function (a) {
    if (!a[0]) {
        print("Usage: jslint.js file.js");
        quit(1);
    }
    var input = readFile(a[0]);
    if (!input) {
        print("jslint: Couldn't open file '" + a[0] + "'.");
        quit(1);
    }
    if (!JSLINT(input, {rhino:true, passfail:false})) {
        for (var i = 0; i < JSLINT.errors.length; i += 1) {
            var e = JSLINT.errors[i];
            if (e) {
                print(''+(e.line+1)+':'+(e.character+1)+':'+e.reason);
            }
        }
        quit(2);
    } else {
        print("jslint: No problems found in " + a[0]);
        quit();
    }
}(arguments));

