"use strict";

$(document).ready(function() {
  if ($(".aggregated-meter-collection-loader").length) {
    // Post to controller
    $(".aggregated-meter-collection-loader .error").hide();
    $.post($('.aggregated-meter-collection-loader').data('aggregation-path'), function(data) {
      window.location.reload(true)
    }).fail(function() {
      $(".aggregated-meter-collection-loader .stats").hide();
      $(".aggregated-meter-collection-loader .error").show();

    });
  }
});
