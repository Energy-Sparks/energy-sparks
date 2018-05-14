"use strict"

$(document).ready(function() {
  $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    window.dispatchEvent(new Event('resize'));
  })
});
