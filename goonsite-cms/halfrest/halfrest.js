$(function () {
    var $ta, $insertButton, $convertButton, $anti, $edit;

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

    $ta = $('.textareaMain');
    setInterval(function () {
        var hasText = ($ta.val() != '');
        if (hasText) {
            $insertButton.attr('disabled', 'disabled');
        } else {
            $insertButton.removeAttr('disabled');
        }
    }, 500);

    $edit = $('.source').find('.editControls');
    if ($edit !== undefined) {
        $edit.find('.textareaHandle').click(function () {
            $ta.parents('.textareaContainer').removeClass('hidden');
            $edit.addClass('hidden');
        });
    }

    $insertButton = $('.insertTemplateButton');
    $insertButton.click(function () {
        $insertButton.disable();
        var sheet;
        sheet = $('.sheetTemplate').val();
        if ($ta.val() == '') {
            $ta.val() = sheet;
        }

        if ($ta.val() != '') {
            $insertButton.disable();
        }
        return false;
    });

    var $deleter, $deleteInput, title, ok;
    $deleter = $('.deleteThis');
    $deleteInput = $('.deleteInput');

    $deleter.click(function () {
        title = $deleter.attr('rel');
        ok = confirm("Really delete " + title + "?");
        if (!ok) {
            return false;
        } else {
           $deleteInput.value = "delete";
           document.forms[0].submit();  
           return true;
        }
    });

});
