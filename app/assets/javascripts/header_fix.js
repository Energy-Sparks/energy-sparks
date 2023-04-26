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

  // For the element which is disappearing under the header, give it a class of header-fix
  $('.header-fix').css('margin-top', getNavHeight());

  $(window).resize(function() {
    $('.header-fix').css('margin-top', getNavHeight());
  });
});
