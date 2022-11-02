"use strict"

$(document).ready(function() {

  $('select.form-control.select2').select2({theme: 'bootstrap'});

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
