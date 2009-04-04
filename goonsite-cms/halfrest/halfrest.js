document.observe('dom:loaded', function() {

    var bindInsertTemplate, bindTextArea, bindEditBox, insertButton, ta,
        timer;

    ta = $$('.textareaMain')[0];
    insertButton = $$('.insertTemplateButton')[0];

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

    bindTextarea = function() {
        timer = setInterval(function() {
            if (ta.value == '' && insertButton.disabled) {
                insertButton.enable();
            } else if (ta.value != '' && !insertButton.disabled) {
                insertButton.disable();
            }
        }, 500);
    }
    bindTextarea();

    bindInsertTemplate = function() {
        insertButton.observe('click', function(event) {
            insertButton.disable();
            var sheet;
            sheet = $$('.sheetTemplate')[0].value;
            event.preventDefault();
            event.stopPropagation();
            if (ta.value == '') {
                ta.value = sheet;
            }
        });

        if (ta.value != '') {
            insertButton.disable();
        }

    };
    bindInsertTemplate();

    bindDelete = function() {
        var ok, deleter, deleteInput, title;
        deleter = $$('.deleteThis')[0];
        deleteInput = $$('.deleteInput')[0];
        title = deleter.getAttribute('rel');
        // deleter.observe('click', function(ev) {
        deleter.observe('click', function(ev) {
            ok = confirm("Really delete " + title + "?");
            if (!ok) {
                ev.stopPropagation();
                ev.preventDefault();
            } else {
               deleteInput.value = "delete";
               document.forms[0].submit();  
            }
        });
    }
    bindDelete();

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

