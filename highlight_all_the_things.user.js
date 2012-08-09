// ==UserScript==
// @name        All your highlights are belong to you
// @namespace   http://goonmill.org
// @description Persistent highlighter information
// @include     http://kb.decipherinc.com/*
// @version     1
// @require     http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// ==/UserScript==
//
//


function run() {

"use strict";


function BadRange() {
    Error.apply(this, arguments);
}
BadRange.prototype = new Error();
BadRange.prototype.constructor = BadRange;
BadRange.prototype.name = 'BadRange';



function Marking(range, style) {
    "A single highlighted range within the document.";
    this.fgStyle = this.bgStyle = this.range = null;
    this.setStyle(style);
    this.setRange(range);
};
Marking.prototype = {
    setStyle: function _a_setStyle(properties) {
        if (! properties) {
            return;
        }
        this.fgStyle = (properties.fgStyle || this.fgStyle);
        this.bgStyle = (properties.bgStyle || this.bgStyle);
    },
    setRange: function _a_setRange(range) {
        if (! range) {
            return;
        }
        this.range = (range || this.range);
    },

    display: function _a_display() {
        if (! this.range || ! (this.bgStyle || this.fgStyle)) {
            throw new BadRange("Tried to display a Marking with no range or no style");
        }
        var sel = window.getSelection();
        document.designMode = "on";
        sel.removeAllRanges();
        sel.addRange(this.range);
        document.execCommand("hiliteColor", false, this.bgStyle);
        sel.removeAllRanges();
        // TODO - fgStyle, fgTextDecoration
        document.designMode = "off"
    }
};
Marking.fromRangeBounds = function _a_fromRangeBounds(start, end) {
    "Create a new Marking from a pair of start/end range duples";
    var $start = $(start[0]);
    var $end = $(end[0]);

    var rng = document.createRange();
    rng.setStart($start[0], start[1]);
    rng.setEnd($end[0], end[1]);

    return new Marking(rng);
}
Marking.fromSelection = function _a_fromSelection(sel) {
    var sel = window.getSelection();
    if (sel.rangeCount && sel.getRangeAt) {
        var range = sel.getRangeAt(0);
        return new Marking(range, {bgStyle: thePen.bgStyle});
    }
}



function Pen() {
    this.bgStyle = 'blue';
}
Pen.prototype = {
    setBG: function _a_setBG(color) {
        this.bgStyle = color;
    }
};

window.thePen = new Pen();


function HighlightStorage() {
    this.markings = {};
}
HighlightStorage.prototype = {
    add: function _a_add(marking) {
        this.markings[HighlightStorage.count] = marking;
        HighlightStorage.count++;
    },
    save: function _a_save() {
        var saveCounter = 0;
        var out = {};
        for (var marking in this.markings) {
            if (! this.markings.hasOwnProperty(marking)) {
                continue;
            }
            var marking = this.markings[marking];
            var rng = marking.range;
            var css1 = $(rng.startContainer).getPath();
            var css2 = $(rng.endContainer).getPath();
            out["" + saveCounter] = [
                [css1, rng.startOffset], 
                [css2, rng.endOffset],
                {bgStyle: marking.bgStyle,
                 fgStyle: marking.fgStyle
                }]; 
            saveCounter++;
        }
        var ret = JSON.stringify(out);
        localStorage[LOCALSTORAGE_MARKINGS] = ret;
        return ret;
    }
};
HighlightStorage.count = 0;
HighlightStorage.load = function _a_load(stored) {
    "Get all markings from disk.";
    var storage = new HighlightStorage();
    var regions = $.parseJSON(stored);
    for (var region in regions) {
        if (! regions.hasOwnProperty(region)) {
            continue;
        }
        var region = regions[region];
        var bgStyle = region[2];
        var marking = Marking.fromRangeBounds(region[0], region[1]);
        marking.setStyle(bgStyle);
        storage.add(marking);
    }
    return storage;
};



jQuery.fn.getPath = function _a_getPath() {
    "Return the jquery-compatible css selector of a single element";
    if (this.length != 1) throw 'Requires one element.';

    var path, node = this;
    while (node.length) {
        var realNode = node[0], name = realNode.localName;
        if (!name) break;
        name = name.toLowerCase();

        var parent = node.parent();

        var siblings = parent.children(name);
        if (siblings.length > 1) { 
            name += ':eq(' + siblings.index(realNode) + ')';
        }

        path = name + (path ? '>' + path : '');
        node = parent;
    }

    return path;
};


var LOCALSTORAGE_ROOT = 'http://goonmill.org/hatt';
var LOCALSTORAGE_MARKINGS = LOCALSTORAGE_ROOT + '/markings';

// localStorage[LOCALSTORAGE_MARKINGS] = '{"0": [["#apache-config", 0], ["#apache-config", 4], {"bgStyle": "yellow", "fgStyle": null }]}';


window.theStorage = HighlightStorage.load(localStorage[LOCALSTORAGE_MARKINGS]);
for (var marking in theStorage.markings) {
    if (! theStorage.markings.hasOwnProperty(marking)) {
        continue;
    }
    var marking = theStorage.markings[marking];
    marking.display();
}


var KEY_YELLOW = ['y', true, false, true];
var KEY_RED = ['r', true, false, true];
var KEY_REMOVE = ['0', true, false, true];
var KEY_SAVE = ['s', true, false, true];


$(window).keypress(function _a_onKeypress(ev) {
    var key = String.fromCharCode(ev.which).toLowerCase();
    var match = function _a_match(comp) {
        return (comp[0] == key &&
                comp[1] == ev.shiftKey &&
                comp[2] == ev.ctrlKey &&
                comp[3] == ev.altKey
                );
    }
    if (match(KEY_YELLOW)) {
        thePen.setBG('yellow');
        var marking = Marking.fromSelection();
        marking.display();
        theStorage.add(marking);
    } else if (match(KEY_RED)) {
        thePen.setBG('red');
        var marking = Marking.fromSelection();
        marking.display();
        theStorage.add(marking);
    } else if (match(KEY_REMOVE)) {
        // TODO
    } else if (match(KEY_SAVE)) {
        theStorage.save();
    }
});


}
run();

console && console.log('hatt loaded');

// vim:set foldmethod=indent:
