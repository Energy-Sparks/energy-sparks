"use strict"

$(document).ready(function() {

  $('select.form-control.select2').select2({theme: 'bootstrap'});

  // Switch on select2 after cocoon insert. Needed for todos
  $('.admin-todos').on('cocoon:after-insert', function(e, insertedItem) {
    $(insertedItem).find('select.form-control.select2').select2({theme: 'bootstrap'});
  });

  // When using select2 with bootstrap tabs
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    changeSelect();
  })

  function changeSelect() {
    $("select.select2").select2({
      tags: true
    })
  }

  $(document).on('change','.must-select', function() {
    if ($(this).val()) {
      $(this).closest('form').find(':submit').prop('disabled', false);
    } else {
      $(this).closest('form').find(':submit').prop('disabled', true);
    }
  });

  if ($("form .must-select").length > 0) {
    $("form .must-select").closest('form').find(':submit').prop('disabled', true);
  }

  $(document).on('change','.must-select.disable-tooltip', function() {
    if ($(this).val()) {
      $(this).closest('form').find(':submit').tooltip('dispose');
    } else {
      $(this).closest('form').find(':submit').tooltip('enable');
    }
  });

});
