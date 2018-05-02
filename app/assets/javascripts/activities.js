$(document).on('turbolinks:load', function() {
  $("#activity_date_picker").datepicker({
    dateFormat: 'dd/mm/yy',
    altFormat: 'yy-mm-dd',
    altField: "#activity_happened_on",
    maxDate: 0,
    orientation: 'bottom'
  });
  // clear altfield if picker field is cleared
  $("#activity_date_picker").change(function() {
    if (!$(this).val()) {
      $("#activity_happened_on").val("");
    }
  });
});