// ==UserScript==
// @name          4chan Accidentally the Whole Thread
// @namespace     http://www.example.com/4chan.accidentally.the.whole.thread/
// @author        4chan Accidentally the Whole Thread Corporation
// @description   In reply mode in any thread, expands images for the entire thread. REQUIRES 4CHAN OFFICIAL EXTENSION
// @match         http://boards.4chan.org/*
// @require       https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// @version       1.0
// ==/UserScript==
//

"use strict";


var load,execute,loadAndExecute;load=function(a,b,c){var d;d=document.createElement("script"),d.setAttribute("src",a),b!=null&&d.addEventListener("load",b),c!=null&&d.addEventListener("error",c),document.body.appendChild(d);return d},execute=function(a){var b,c;typeof a=="function"?b="("+a+")();":b=a,c=document.createElement("script"),c.textContent=b,document.body.appendChild(c);return c},loadAndExecute=function(a,b){return load(a,function(){return execute(b)})};

loadAndExecute("http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js", function() {

    var ENLARGE = "http://i.imgur.com/WVbrk.png";
    var SHRINK = "http://i.imgur.com/MUkZF.png";

    var $button = $('<a href="#" style="background-color: yellow; position: fixed; top: 0px; left: 0px" id="4chanaccidentally"></a>');
    $button.append('<img src="' + ENLARGE + '">');
    $('body').prepend($button);
    $button.data('state', 'SMALL');

    $button.click(function _a_enlargeClick() {
        console.log('clicked');

        if ($button.data('state') == "SMALL") {

            console.log('enlarging');

            $.map($('.fileThumb'), function _a_fixImg(anchor) {
                var $img = $(anchor).children(':first-child');
                $img.data('original-style', $img.attr('style'));
                $img.attr('src', anchor.href);
                $img.attr('style', 'max-width: 1000px');
            });

            $button.data('state', 'LARGE');
            $button.find('img').attr('src', SHRINK);

        } else {
            console.log('shrinking');

            // we don't reinstate the original @src attribute because the
            // damage is done, but we shrink it back to original size.

            $.map($('.fileThumb'), function _a_fixImg(anchor) {
                var $img = $(anchor).children(':first-child');
                $img.attr('style', $img.data('original-style'));
            });

            $button.data('state', 'SMALL');
            $button.find('img').attr('src', ENLARGE);

        }
        return false;

    });

});

console.log('4chan-awt loaded');
