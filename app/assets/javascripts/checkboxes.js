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

  $(document).on('click','.check-all-attributes',function(){
    $(this).closest('.form-group').find(':checkbox').prop('checked',this.checked);
    $(this).closest('.form-group').find('select').prop('disabled',!this.checked);
    $(this).closest('.form-group').find('input:not(:checkbox)').prop('disabled',!this.checked);
  });

  $("form").find('input:not(:checkbox)').each(function(){
    if ($(this).val().length > 0) {
      $(this).prop('disabled',false);
      // alert($(this).closest('fieldset').find(':checkbox').length);
      $(this).closest('fieldset').find(':checkbox').prop('checked',true);
    }
  });

  // $("form").find('select').each(function(){
  //   if ($(this).val().length > 0) {
  //     $(this).prop('disabled',false);
  //     $(this).closest('fieldset').find(':checkbox').prop('checked',true);
  //   }
  // });

});
