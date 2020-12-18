"use strict"

$(document).ready(function() {
  if ($("form.mailchimp-form").length) {
    var otherToggle = function() {
      var idVal = $(this).attr("id");
      var label = $("label[for='"+idVal+"']").text();
      if (label == 'Other') {
        $(this).closest('.form-group').find('input:text').show();
      } else {
        $(this).closest('.form-group').find('input:text').hide();
      }
    };
    $(document).on('change', 'input:radio', otherToggle);
  }
});
