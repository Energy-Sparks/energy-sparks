"use strict"
$(document).ready(function() {

  $('[data-hidden-by]').hide();
  $('[data-hides]').on('change', function(){
    var checkbox = $(this);
    if(this.checked) {
      $(checkbox.data('hides')).hide();
      $(checkbox.data('hides')).find('input').each(function(){
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
    } else {
      $(checkbox.data('hides')).show();
    }
  });
  $('[data-hides]').trigger('change');

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
