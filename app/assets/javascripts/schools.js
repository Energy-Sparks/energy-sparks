"use strict"

$(document).ready(function() {
  $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    window.dispatchEvent(new Event('resize'));
  })
  if($('.more-alerts').length){
    $('.more-alerts').on('click', function(e) {
      $('.act-on-energy-usage .alert').show();
      $(this).hide();
      event.preventDefault();
    });
    $(".act-on-energy-usage .alert:not(:first)").hide();
  }
});
