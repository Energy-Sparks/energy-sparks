"use strict"

$(document).ready(function() {
  $(document).on('change','.ensure-one-checked input',function(){
    let checked = $(this).closest('.ensure-one-checked');
    if (checked.find('input[type=checkbox]:checked').length > 0) {
      $('[data-toggle="tooltip"]').tooltip('dispose');
    } else {
      $(this).next().tooltip('show');
      $(this).prop("checked", true );
    }
  });

  $(document).on('mouseover','.ensure-one-checked',function(){
    $('[data-toggle="tooltip"]').tooltip('dispose');
  });
});
