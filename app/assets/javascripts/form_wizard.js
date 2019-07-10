"use strict"
$(document).ready(function() {

  $('.wizard').each(function(){
    var form = $(this);
    form.find('.wizard-stage').hide();
    form.find('.wizard-button').removeClass('d-none').on('click', function(event){
      var button = $(this);
      if(button.data('to-stage')){
        form.find('.wizard-stage').hide();
        form.find('.wizard-stage#' + button.data('to-stage')).show();
        event.preventDefault();
      }else{
        return true;
      }
    });

    if(form.find('.is-invalid').length){
      form.find('.is-invalid').first().parents('.wizard-stage').show();
    }else{
      form.find('.wizard-stage').first().show();
    }
  });
});
