"use strict"

$(document).ready(function() {
  if ($("form.activity-form").length) {
    var $datePickerDiv = $('div#activity_date_picker_field');
    var dateValue = moment($('#activity_happened_on').val(), 'DD/MM/YYYY');

    if ($datePickerDiv.length) {
      $datePickerDiv.datetimepicker({
        format: 'DD/MM/YYYY',
        allowInputToggle: true,
        date: dateValue
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

    $('#activity_activity_type_id').select2({theme: 'bootstrap'});
  }
});