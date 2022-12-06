"use strict"

$(document).ready(function() {

  $(document).on('click','.check-all',function(){
    $(this).closest('.form-group').find(':checkbox').prop('checked',this.checked);
  });

  $(document).on('click','.must-check',function(){
    $(this).closest('form').find(':submit').prop('disabled', !this.checked);
  });

  if ($("form .must-check").length > 0) {
    $("form .must-check").closest('form').find(':submit').prop('disabled', true);
  }

  $(document).on('click','.disable-attributes',function(){
    $(this).closest('.form-group').find(':checkbox').prop('checked',this.checked);
    $(this).closest('.form-group').find('select').prop('disabled', this.checked);
    $(this).closest('.form-group').find('input').prop('disabled', this.checked);
    $(this).prop('disabled', false);
    $(this).next('.disabled-label').toggle();
  });

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
