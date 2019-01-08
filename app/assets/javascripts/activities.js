"use strict"

$(document).ready(function() {
 if ($("form.activity-form").length) {
  console.log('hello');
    var $datePickerDiv = $('div#activity_date_picker_field');
    var defaultDate = moment($datePickerDiv.data('default-date'), 'DD/MM/YYYY')

    if ($datePickerDiv.length) {
      $datePickerDiv.datetimepicker({
        format: 'DD/MM/YYYY',
        allowInputToggle: true,
        date: defaultDate
      });
    }
  }
});