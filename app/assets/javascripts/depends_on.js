"use strict"

$(document).ready(function() {

  $(document).on('change','input[data-dependee]',function() {
    let id = $(this).attr("data-dependee");
    handler(id);
  });

  $(document).on('change','input[data-dependant]',function() {
    let id = $(this).prop('id');
    handler(id);
  });

  function handler(id) {
    let dependee = $('#' + id);
    let dependants = $('input[data-dependee="' + id + '"]');

    var dependant_has_value = false;
    dependants.each(function() {
      let dependant_value = $(this).val();
      if (dependant_value.length > 0) {
        dependant_has_value = true;
      }
    });

    if (dependant_has_value === true && dependee.val().length == 0) {
      $('#' + id).tooltip('show');
    } else {
      $('#' + id).tooltip('hide');
    }
  }
});
