"use strict"

$(document).ready(function() {
  if ($("form#activity_type_form").length) {
    $('select.form-control.select2').select2({theme: 'bootstrap'});
  }
});
