"use strict"

$(document).ready(function() {
  if ($("form.activity-form").length) {

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
});
