$(function () {
    var $ta, $insertButton, $convertButton, $anti, $edit, $deleter;

    // antispam must be answered before you can convert
    $anti = $('#antispam');
    $convertButton = $('.convertButton');
    setInterval(function () {
        var hasAnswer = ($anti.val() != '');
        if (hasAnswer) { 
            $convertButton.removeAttr('disabled');
        } else {
            $convertButton.attr('disabled', 'disabled');
        }
    }, 500);

    // you may not use "insert template" if there is already content present
    $ta = $('.textareaMain');
    setInterval(function () {
        var hasText = ($ta.val() != '');
        if (hasText) {
            $insertButton.attr('disabled', 'disabled');
        } else {
            $insertButton.removeAttr('disabled');
        }
    }, 500);

    // enable the control to show the edit box
    $edit = $('.source').find('.editControls');
    if ($edit.length > 0) {
        $edit.find('.textareaHandle').click(function () {
            $ta.parents('.textareaContainer').removeClass('hidden');
            $edit.addClass('hidden');
        });
    }

    // enable the template insert
    $insertButton = $('.insertTemplateButton');
    $insertButton.click(function () {
        $insertButton.attr('disabled', 'disabled');
        if ($ta.val() == '') {
            $ta.val($('.sheetTemplate').val());
        }
    });

    // enable delete
    $deleter = $('.deleteThis');
    $deleter.click(function () {
        var title, ok;
        title = $deleter.attr('rel');
        ok = confirm("Really delete " + title + "?");
        if (!ok) {
            return false;
        } else {
           $('.deleteInput').val("delete");
           document.forms[0].submit();  
           return true;
        }
    });

});

