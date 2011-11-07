"use strict";
function onLoad() {
    $.noConflict();
    jQuery(function ($) {
        var newLevel = prompt("New level?");
        var $opt = $('[name="classLevel_1"] option:first, [name="class1_level"] option:first');
        $opt.val(newLevel);
        $opt.text(newLevel);
        $opt.select();
    });
}

if (document.getElementById('dingle')) {
    onLoad();
} else {
    var jqScr = document.createElement('script');
    jqScr.setAttribute('id', 'fixdingle');
    jqScr.setAttribute('src', 
        'http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js');
    jqScr.onload = onLoad;
    document.body.appendChild(jqScr);
}
