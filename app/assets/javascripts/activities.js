"use strict"

$(document).ready(function() {
  if ($("form.activity-form").length) {
    var $datePickerDiv = $('div#activity_date_picker_field');
    var defaultDate = moment($datePickerDiv.data('default-date'), 'DD/MM/YYYY')

    if ($datePickerDiv.length) {
      $datePickerDiv.datetimepicker({
        format: 'DD/MM/YYYY',
        allowInputToggle: true,
        date: defaultDate
      });
    }

    function showHideTitle(selectedName) {
      var expr = /please specify/;
      if (selectedName.match(expr)) {
        $('div#title-field').show();
      } else {
        $('div#title-field').hide();
      }
    }

    var currentSelectedName = $('#activity_activity_type_id').find('option:selected').text();
    showHideTitle(currentSelectedName);

    $(document).on('change', '#activity_activity_type_id', function() {
      var selectedName = $(this).find('option:selected').text();
      showHideTitle(selectedName);
    });
  }
});