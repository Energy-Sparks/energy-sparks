"use strict"

$(document).ready(function() {
  if ($("form#audit_form").length) {
    $('select.form-control.select2').select2({theme: 'bootstrap'});
  }
});
