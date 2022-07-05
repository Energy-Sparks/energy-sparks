"use strict"

$(document).ready(function() {

  // This stops content disappearing under the site navigation
  function getNavHeight() {
    let height = 0;
    $("body > nav.navbar").each( function(index) {
      height += $(this).height();
    })
    return height;
  }

  $('#ts-header-nav').css('margin-top', getNavHeight());
  $(window).resize(function() {
    $('#ts-header-nav').css('margin-top', getNavHeight());
  });
});