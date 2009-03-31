document.observe('dom:loaded', function() {

    var bindEditBox;

    bindEditBox = function() {
        var edit;
        edit = $$('.source')[0].down('.textareaHandle');
        if (edit !== undefined) {
            edit.observe('click', function () {
                edit.next('.textareaContainer').removeClassName('hidden');
                edit.addClassName('hidden');
            });
        }
    };
    bindEditBox();

});


resizeIframe = function() {
    var ifr, newHeight;
    ifr = $$('iframe.displayDoc')[0];
    if (ifr !== undefined) {
        // adjust for margin and scrollbar
        newHeight = ifr.contentDocument.height + 50;
        new Effect.Morph(ifr, {
                'style': 'height: ' + newHeight + 'px',
                'duration': '0.5',
                });
    }
};

