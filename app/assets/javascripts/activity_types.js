"use strict"

$(document).ready(function() {

  if ($("form#activity_type_form").length) {
    $('select.form-control.select2').select2({theme: 'bootstrap'});
  }

  $("form#activity_type_form .file").change(function(event){
    if (this.files) {
      var reader = new FileReader();
      reader.onload = function(e){
        $(".upload-preview img").attr("width", '300px');
        $(".upload-preview img").attr("src", e.target.result);
      };
      reader.readAsDataURL(this.files[0]);
    }
  });

  $(document).on('change','.must-select', function() {
    if ($(this).val()) {
      $(this).closest('form').find(':submit').prop('disabled', false);
    } else {
      $(this).closest('form').find(':submit').prop('disabled', true);
    }
  });

  if ($("form .must-select").length > 0) {
    $("form .must-select").closest('form').find(':submit').prop('disabled', true);
  }
});
