(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

if(window.location.hostname.toLowerCase().indexOf('mypurecloud') > 0){
  ga('create', 'UA-73002812-1', 'none');
}else{
  ga('create', 'UA-73002812-2', 'none');
}
ga('send', 'pageview');

$('body').ready(function(){
    function sendEvent(category){
        ga('send', {
          hitType: 'event',
          eventCategory: 'tutorial',
          eventAction: category,
          eventLabel: window.tutorial
        });

        //NewRelic code
        newrelic.addPageAction ('tutorial', {
            action: category,
            tutorial: "tutorial"
        });

    }
    $('.tutorial-previous').click(function(){
        sendEvent('previous');
    });

    $('.tutorial-next').click(function(){
        sendEvent('next');
    });

    var languageOptions = $("#languageSelect");
    languageOptions.change(function(){
        sendEvent('newlanguage');
    });
});
