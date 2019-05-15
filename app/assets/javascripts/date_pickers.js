"use strict"

$(document).ready(function() {
 $('div.input-group.tempus-dominus-date').each(function() {
    $(this).datetimepicker({
      format: 'DD/MM/YYYY',
      allowInputToggle: true,
    });
  });

  $('div.input-group.tempus-dominus-date-time').each(function() {
    $(this).datetimepicker({
      allowInputToggle: true,
      sideBySide: true
    });
  });
});
