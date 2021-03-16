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

});
