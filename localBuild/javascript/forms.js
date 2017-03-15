$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

$(function() {
 $('.lambdaform>.alert-danger').hide();
  $('.lambdaform').submit(function(){
      $('.alert-danger', this).hide();
      var url = $(this).data().url;
      var data = $(this).serializeObject();
      var redirectUrl = $(this).children("#redirect").val();

      $(this).prop('disabled', true);

      $.ajax({
          type: "POST",
          url: url,
          data: JSON.stringify(data),
          dataType: "json",
          contentType: "application/json",
          success: function() {
            if(redirectUrl){
                window.location = redirectUrl;
            }else{
                window.location.reload();
            }
          },
          error: function(){
              $('.alert-danger').show();
          }

        });

      event.preventDefault();
      return false;
  });
});
