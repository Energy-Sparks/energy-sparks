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

    var activityTypeCustomCheck = function(activityType){
      var customState = $(activityType.target).find('option:selected').data('custom');
      showHideTitle(customState);
    }

    $(document).on('change', '#activity_activity_type_id', activityTypeCustomCheck);
    activityTypeCustomCheck({target: '#activity_activity_type_id'});

    $('#activity_activity_type_id').select2({theme: 'bootstrap'});
  }

  if ($("form#activity_type_form").length) {
    $('select.form-control.select2').select2({theme: 'bootstrap'});
  }
});
