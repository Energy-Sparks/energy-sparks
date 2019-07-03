"use strict"

$(document).ready(function() {
 $('div.input-group.tempus-dominus-date').each(function() {
    $(this).datetimepicker({
      format: 'DD/MM/YYYY',
      allowInputToggle: true,
    });
  });

  $('div.input-group.tempus-dominus-date-time').each(function() {
    var date_picker = $(this);
    var maxDateTime = date_picker.children('input').data('maxDateTime');
    var options = {
      format: 'DD/MM/YYYY HH:mm',
      allowInputToggle: true,
      sideBySide: true
    }

    if (maxDateTime.length) {
      options.maxDate = moment(new Date(maxDateTime));
    }

    date_picker.datetimepicker(options);
  });
});
