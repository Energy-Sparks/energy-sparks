"use strict"

$(document).ready(function() {
  $(".term_datepicker").datepicker({
    dateFormat: 'dd/mm/yy',
    altFormat: 'yy-mm-dd',
    orientation: 'bottom'
  });
  // set altField from data attribute
  $(".term_datepicker").each(function() {
    const altfield = $(this).data("altfield");
    $(this).datepicker("option", "altField", altfield);
  });

  var calendar_event_date_value = $('#calendar_event_holder .datetimepicker-input').val();
  $('#calendar_event_holder').datetimepicker({
    format: 'DD/MM/YYYY',
    allowInputToggle: true,
    date: moment(calendar_event_date_value)
  });
});
