"use strict"

$(document).ready(function() {
  // We are using bootstrap fixed navbars, which means the navbar sticks to the top of the page
  // when scrolling the page and the content flows underneath it.
  // Taken from bootstrap 4.0 docs:
  // Fixed navbars use position: fixed, meaning they’re pulled from the normal flow of the DOM and may require custom CSS
  // (e.g., padding-top on the <body>) to prevent overlap with other elements.

  // If we resize a page, sometimes the content of the nav bars can wrap to have more than one row.
  // This means the heights of the navbars change, but unforunately the content below
  // stays in the same place (see above comment of fixed position navbars being pulled from the normal flow of the dom).
  // This means the content can be hidden by the nav that is now bigger than when the page loaded

  // Returns the height of both navs
  function getTotalNavHeight() {
    let height = 0;
    $("body > div.fixed-top > nav.navbar").each( function(index) {
      height += $(this).height();
    })
    return height;
  }

  function setFixedPositions() {
    let height = getTotalNavHeight();
    if (height > 50) {
      $('.application.container').css('margin-top', getTotalNavHeight());
    }
  }

  // position on page load
  //setFixedPositions();

  // position when the page is reloaded
  $(window).resize(function() {
    //setFixedPositions();
  });
});
