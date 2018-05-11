$(document).on('turbolinks:load', function() {
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
});
