"use strict"

$(document).ready(function() {
 if ($("form.activity-form").length) {
    var $datePickerDiv = $('div#activity_date_picker_field');
    if ($datePickerDiv.length) {
      $datePickerDiv.datetimepicker({
        format: 'DD/MM/YYYY',
        allowInputToggle: true,
        debug: true
      });
    }
  }
});