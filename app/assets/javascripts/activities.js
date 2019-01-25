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

    function showHideTitle(customState) {
      if (customState) {
        $('div#title-field').show();
      } else {
        $('div#title-field').hide();
      }
    }

    $(document).on('change', '#activity_activity_type_id', function() {
      var customState = $('#activity_activity_type_id').find('option:selected').data('custom');
      showHideTitle(customState);
    });
    $('#activity_activity_type_id').trigger('change');

    $('#activity_activity_type_id').select2({theme: 'bootstrap'});
  }
});
