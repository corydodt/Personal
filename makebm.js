#!/usr/bin/rhino -f
"use strict";
importPackage(java.io);
importPackage(java.lang);

// "in" is a keyword in JavaScript. 
// In JavaScript you could query for an attribute using [] syntax: 
var reader = new BufferedReader( new InputStreamReader(System['in']) );


function MakeBM() {

    var s = true, Text = new String();
    while (s) {
        s = reader.readLine();
        if (s) {
            Text += s;
        }
    }

    // Standardize newlines
    Text = Text.replace(/\r/g, '\n');

//    // Remove comments
//    Text = removeComments(Text);

    // No multiple spaces
    Text = Text.replace(/[\t ]+/g, ' ');

    // Shameful hack to avoid replacing inside literal strings
    Text = Text.replace(/'/g, '"<$<$<$<$<$<');

    // Replace line-by-line
    var NewlineArray = Text.split('\n');
    var LineCount = NewlineArray.length;
    var QuoteArray = Array();
    var SplitCount = 0;

    for ( var i = 0; i < LineCount; i++ ) {

        // Trim each line
        NewlineArray[i] = NewlineArray[i].replace(/^[\t ]+/g, '');
        NewlineArray[i] = NewlineArray[i].replace(/[\t ]+$/g, '');

        QuoteArray = NewlineArray[i].split('"');
        SplitCount = QuoteArray.length;

        for ( var j = 0; j < SplitCount; j++ ) {
            if ( (j % 2) == 0 ) QuoteArray[j] = MakeReplaces(QuoteArray[j]);
        }

        NewlineArray[i] = QuoteArray.join('"');

    }

    Text = NewlineArray.join('');

    // Restore single quotes
    Text = Text.replace(/"<\$<\$<\$<\$<\$</g, "'");

    // Percent-encode special characters
    Text = Text.replace(/%/g, '%25');
    Text = Text.replace(/"/g, '%22');
    Text = Text.replace(/</g, '%3C');
    Text = Text.replace(/>/g, '%3E');
    Text = Text.replace(/#/g, '%23');
    Text = Text.replace(/@/g, '%40');
    Text = Text.replace(/ /g, '%20');
    Text = Text.replace(/\&/g, '%26');
    Text = Text.replace(/\?/g, '%3F');

    if ( Text.substring(0, 11) == 'javascript:' ) Text = Text.substring(11);
    var TextLength = Text.length;

    if ( (Text.substring(0, 12) + Text.substring(TextLength - 5)) != '(function(){})();' ) Text = '(function(){' + Text + '})();';
    Text = 'javascript:' + Text;

    System.out.println(Text);

}

function MakeReplaces(Text) {
    Text = Text.replace(/ ?; ?/g, ';');
    Text = Text.replace(/ ?: ?/g, ':');
    Text = Text.replace(/ ?, ?/g, ',');
    Text = Text.replace(/ ?= ?/g, '=');
    Text = Text.replace(/ ?% ?/g, '%');
    Text = Text.replace(/ ?\+ ?/g, '+');
    Text = Text.replace(/ ?\* ?/g, '*');
    Text = Text.replace(/ ?\? ?/g, '?');
    Text = Text.replace(/ ?\{ ?/g, '{');
    Text = Text.replace(/ ?\} ?/g, '}');
    Text = Text.replace(/ ?\[ ?/g, '[');
    Text = Text.replace(/ ?\] ?/g, ']');
    Text = Text.replace(/ ?\( ?/g, '(');
    Text = Text.replace(/ ?\) ?/g, ')');
    return Text;
}

/*
    Comment removal code from:
    http://james.padolsey.com/javascript/removing-comments-in-javascript/
*/

function removeComments(str) {
 
    var uid = '_' + +new Date(),
        primatives = [],
        primIndex = 0;
 
    return (
        str
        /* Remove strings */
        .replace(/(['"])(\\\1|.)+?\1/g, function(match){
            primatives[primIndex] = match;
            return (uid + '') + primIndex++;
        })
 
        /* Remove Regexes */
        .replace(/([^\/])(\/(?!\*|\/)(\\\/|.)+?\/[gim]{0,3})/g, function(match, $1, $2){
            primatives[primIndex] = $2;
            return $1 + (uid + '') + primIndex++;
        })
 
        /*
        - Remove single-line comments that contain would-be multi-line delimiters
            E.g. // Comment /* <--
        - Remove multi-line comments that contain would be single-line delimiters
            E.g. /* // <-- 
       */
        .replace(/\/\/.*?\/?\*.+?(?=\n|\r|$)|\/\*[\s\S]*?\/\/[\s\S]*?\*\//g, '')
 
        /*
        Remove single and multi-line comments,
        no consideration of inner-contents
       */
        .replace(/\/\/.+?(?=\n|\r|$)|\/\*[\s\S]+?\*\//g, '')
 
        /*
        Remove multi-line comments that have a replaced ending (string/regex)
        Greedy, so no inner strings/regexes will stop it.
       */
        .replace(RegExp('\\/\\*[\\s\\S]+' + uid + '\\d+', 'g'), '')
 
        /* Bring back strings & regexes */
        .replace(RegExp(uid + '(\\d+)', 'g'), function(match, n){
            return primatives[n];
        })
    );
 
}


MakeBM();
