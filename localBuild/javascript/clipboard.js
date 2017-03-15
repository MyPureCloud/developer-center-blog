$(function() {
    function setTooltip(btn, message) {
        $(btn).tooltip({placement: 'left',trigger: 'manual'})
        .tooltip('hide')
        .attr('data-original-title', message)

        .tooltip("show");
    }

    function hideTooltip(btn) {
        setTimeout(function() {
            $(btn).tooltip('hide');
        }, 1000);
    }

    function registerCopyHandler(selector, textFunction){
        var clipboard = new Clipboard(selector, {
            text: textFunction
        });

        clipboard.on('success', function(e) {
            setTooltip(e.trigger, 'Copied!');
            hideTooltip(e.trigger);
        });

        clipboard.on('error', function(e) {
            setTooltip(e.trigger, 'Failed!');
            hideTooltip(e.trigger);
        });

    }

    registerCopyHandler('#copypartial', function(trigger) {
        return "https://developer.mypurecloud.com/api/rest/postman/collections/" +  $( "#postmangroup option:selected" ).val() + '.json';
    });

    registerCopyHandler('.direct-link-copy', function(trigger) {
        var operationId = trigger.getAttribute('data-operationId');

        $('#heading'+ operationId +'>h4>div').addClass('collapsed');
        $('#' + operationId).removeClass('in');

        return window.location.origin + window.location.pathname + "#" + operationId;
    });

    registerCopyHandler('.direct-link-markdown-copy', function(trigger) {
        var operationId = trigger.getAttribute('data-operationId');
        var operationMethod = trigger.getAttribute('data-operationMethod');
        var operationUri = trigger.getAttribute('data-operationUri');

        $('#heading'+ operationId +'>h4>div').addClass('collapsed');
        $('#' + operationId).removeClass('in');

        return "["+ operationMethod.toUpperCase() + " "+ operationUri +"]("+ window.location.origin + window.location.pathname + "#" + operationId +")";
    });

    new Clipboard('#copyfull');
});
