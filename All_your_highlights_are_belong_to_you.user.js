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


// display: function _a_display() {
// 
//     function _makeEditableAndHighlight() {
//         var sel = window.getSelection();
//         if (sel.rangeCount && sel.getRangeAt) {
//             range = sel.getRangeAt(0);
//         }
//         document.designMode = "on";
//         if (range) {
//             sel.removeAllRanges();
//             sel.addRange(range);
//         }
//         // Use HiliteColor since some browsers apply BackColor to the whole block
//         if (!document.execCommand("HiliteColor", false, this.color)) {
//             document.execCommand("BackColor", false, this.color);
//         }
//         document.designMode = "off";
//     }
// 
//     if (window.getSelection) {
//         // IE9 and non-IE
//         try {
//             if (!document.execCommand("BackColor", false, this.color)) {
//                 _makeEditableAndHighlight();
//             }
//         } catch (ex) {
//             _makeEditableAndHighlight();
//         }
//     } else if (document.selection && document.selection.createRange) {
//         // IE <= 8 case
//         range = document.selection.createRange();
//         range.execCommand("BackColor", false, this.color);
//     }
// }
 

if (true) {
    function BadRange() {
        Error.apply(this, arguments);
    }
    BadRange.prototype = new Error();
    BadRange.prototype.constructor = BadRange;
    BadRange.prototype.name = 'BadRange';
}



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
        this.fgStyle = (properties.fg || this.fgStyle);
        this.bgStyle = (properties.bg || this.bgStyle);
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
        document.execCommand("HiliteColor", false, this.bgStyle);
        sel.removeAllRanges();
        // TODO - fgStyle, fgTextDecoration
        document.designMode = "off"
    }
};
Marking.fromSelectors = function _a_fromSelectors(start, end) {
    "Create a new Marking from a pair of start/end selector duples";
    var $start = $(start[0]);
    var $end = $(end[0]);

    var rng = document.createRange();
    rng.setStart($start[0], start[1]);
    rng.setEnd($end[0], end[1]);

    return new Marking(rng);
}



// function Pen() {
//     this.color = 'blue';
// }
// Pen.prototype = {
//     setColor: function _a_setColor(color) {
//         this.color = color;
//     }
// };


// var _DUMMY_DATA = '[[["body", 0], ["body", ' + ($('body').children().length - 1) + '], {"bg": "yellow", "fg": null }]]';
var _DUMMY_DATA = '[[["#apache-config", 0], ["#apache-config", 4], {"bg": "yellow", "fg": null }]]';

function HighlightStorage() {
    this.markings = [];
}
HighlightStorage.prototype = {
    load: function _a_load() {
        "Get all markings from disk.";
        // TODO
        var stored = _DUMMY_DATA;
        var regions = $.parseJSON(stored);
        for (var n=0; n < regions.length; n++) {
            var region = regions[n];
            var bgStyle = region[2];
            var marking = Marking.fromSelectors(region[0], region[1]);
            marking.setStyle(bgStyle);
            this.markings.push(marking);
        }
    }
};



function run() {

"use strict";

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

// var pen = new Pen();
// pen.setColor('yellow');

var storage = new HighlightStorage();
storage.load();
for (var n=0; n < storage.markings.length; n++) {
    var marking = storage.markings[n];
    marking.display();
}


}
run();

console && console.log('ayhabty loaded');

// vim:set foldmethod=indent:
