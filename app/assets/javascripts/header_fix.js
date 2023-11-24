"use strict"

$(document).ready(function() {

  // We are using bootstrap fixed navbars, which means the navbar sticks to the top of the page
  // when scrolling the page and the content flows underneath it.
  // Taken from bootstrap 4.0 docs:
  // Fixed navbars use position: fixed, meaning they’re pulled from the normal flow of the DOM and may require custom CSS
  // (e.g., padding-top on the <body>) to prevent overlap with other elements.

  // The order of our page is as follows:
  // mini-nav (fixed to top - height of 51px)
  // sub-nav (also fixed to top but offset by 46px, so it should stay just under mini-nav)
  // content container (when intitally renders, is positioned just below above navs)

  // If we resize a page, sometimes the content of the nav bars can wrap to have more than one row.
  // This means the heights of the navbars change, but unforunately the sub-nav and content below
  // stay in the same place (see above comment of fixed position navbars being pulled from the normal flow of the dom)
  // So this means the sub nav or content can be hidden by the mini-nav that is now bigger than when the page loaded

  // Returns the height of the mini nav
  function getMiniNavHeight() {
    return $("body > nav.navbar.navbar-mini").height();
  }

  // Returns the height of both navs
  function getTotalNavHeight() {
    let height = 0;
    $("body > nav.navbar").each( function(index) {
      height += $(this).height();
    })
    return height;
  }

  // Set the fixed positions of the sub-nav & main content
  function setFixedPositions() {
    // the sub-nav is positioned 5px up under the mini-nav
    $('.fixed-top-sub-nav').css('margin-top', getMiniNavHeight() - 5);
    $('.application.container').css('margin-top', getTotalNavHeight());
  }

  // position on page load
  setFixedPositions();

  // position when the page is reloaded
  $(window).resize(function() {
    setFixedPositions();
  });
});
