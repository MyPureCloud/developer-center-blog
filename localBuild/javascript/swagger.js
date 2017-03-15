$(document).ready(function(){
    if(window.location.hash){
        var operation = window.location.hash.substring(1);
        $('#heading'+ operation +'>h4>div').removeClass('collapsed');
        $('#' + operation).addClass('in');
        setTimeout(function(){
            window.scrollBy(0, -75);
        },50);
    }
});

function showOperationBody(operationid){
    $("#" + operationid + "ShowBody").hide();
    $("#" + operationid + "HideBody").show();
    $("#" + operationid + "Body").show();
}


function hideOperationBody(operationid){
    $("#" + operationid + "ShowBody").show();
    $("#" + operationid + "HideBody").hide();
    $("#" + operationid + "Body").hide();
}


function showOperationResponseBody(operationid){
    $("#" + operationid + "ShowResponseBody").hide();
    $("#" + operationid + "HideResponseBody").show();
    $("#" + operationid + "ResponseBody").show();
}


function hideOperationResponseBody(operationid){
    $("#" + operationid + "ShowResponseBody").show();
    $("#" + operationid + "HideResponseBody").hide();
    $("#" + operationid + "ResponseBody").hide();
}


function showExample(operationid){
    $("#" + operationid + "ShowExample").hide();
    $("#" + operationid + "HideExample").show();
    $("#" + operationid + "Example").show();
}


function hideExample(operationid){
    $("#" + operationid + "ShowExample").show();
    $("#" + operationid + "HideExample").hide();
    $("#" + operationid + "Example").hide();
}


$('body').ready(function(){

    function selectLanguage(language){
        if(language == null || language == ""){
            return;
        }
        $('.code-examples li').removeClass('active');
        $('.code-examples .tab-pane').removeClass('active');

        $('.code-example-'+ language).addClass('active');
        $('.code-example-pane-'+ language).addClass('active');

    }
    $('.code-examples a').click(function(){
        var selectedLanguage = $(this).data('language');
        console.log("example selected - " + selectedLanguage);
        localStorage['dev_center_example_language'] = selectedLanguage;
        selectLanguage(selectedLanguage);
    });

    selectedLanguage = localStorage['dev_center_example_language'];

    selectLanguage(selectedLanguage);
});
