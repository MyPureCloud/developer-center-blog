$('body').ready(function(){
    function selectedLanguage(){
        var language = $( "#tutorial-filter-language option:selected" ).text().toLowerCase().trim();
        if(language === 'all'){
            return ""
        }else{
            return "." + language;
        }
    }
    function selectedCategory(){
        var category = $( "#tutorial-filter-category option:selected" ).text().toLowerCase().trim();
        if(category === 'all'){
            return ""
        }else{
            return "." + category;
        }
    }

    function filter(){
        var language = selectedLanguage();
        var category = selectedCategory();

        var selector = ""+ language + category;
        
        if(selector.length === 0){
            $('.tutorial-row').show();
        }else{
            $('.tutorial-row').hide();
            $(selector).show();
        }

    }

    $( "#tutorial-filter-language" ).change(filter);
    $( "#tutorial-filter-category" ).change(filter);
});
