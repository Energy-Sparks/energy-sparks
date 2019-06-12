"use strict";

$(document).ready(function() {
  if ($("div.aggregated-meter-collection-loader").length) {
    // Post to controller
    $.post(window.location.href, function(data) {
      window.location.href = data.referrer;
    });
  }
});
