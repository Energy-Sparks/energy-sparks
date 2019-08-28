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

  $('[data-revealed-by]').hide();

  $('[data-reveals]').on('change', function(){
    var checkbox = $(this);
    if(this.checked) {
      $(checkbox.data('reveals')).show();
    }else{
      $(checkbox.data('reveals')).hide();
      $(checkbox.data('reveals')).find('input').each(function(){
        var input = $(this);
        switch(input.attr('type')) {
          case 'hidden':
            break;
          case 'checkbox':
            input.prop('checked', false).change();
            break;
          default:
            input.val('');
        }

      });
    }
  });
  $('[data-reveals]').trigger('change');
});
