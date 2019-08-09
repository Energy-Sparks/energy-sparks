"use strict"

$(document).ready(function() {
  $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    window.dispatchEvent(new Event('resize'));
  })
  if($('.more-alerts')){
    $('.more-alerts').on('click', function(e) {
      $('.dashboard-alert').show();
      $(this).hide();
      event.preventDefault();
    });
    $(".dashboard-alert:not(:first)").hide();
  }
});
