"use strict"

$(document).ready(function() {
  if ($("form.calendar_event_form").length) {

    function setUpDatePicker(date_type) {
      var $datePickerDiv = $('div#' + date_type + '_date_picker_field');

      if ($datePickerDiv.length) {
        var calendar_event_date_value = $('input#calendar_event_' + date_type + '_date').val();
        var defaultDate = $datePickerDiv.data('default-date');
        var momentDate = moment(calendar_event_date_value);
        console.log(momentDate);
        $datePickerDiv.datetimepicker({
          format: 'DD/MM/YYYY',
          date: momentDate,
          allowInputToggle: true
        });
      }
    }

    setUpDatePicker('start');
    setUpDatePicker('end');
  }

  var calendar_event_date_value = $('#calendar_event_holder .datetimepicker-input').val();
  $('#calendar_event_holder').datetimepicker({
    format: 'DD/MM/YYYY',
    allowInputToggle: true,
    date: moment(calendar_event_date_value)
  });
});
