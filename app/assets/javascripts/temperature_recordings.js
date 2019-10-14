"use strict"

$(document).ready(function() {
  if($('a#show_more_recording_fields').length){
    $('a#show_more_recording_fields').on('click', function(e) {
      e.stopImmediatePropagation();
      $('fieldset.d-none').removeClass('d-none');
      $('a#show_more_recording_fields').remove();
      return false;
    });
  }
});

