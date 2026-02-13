"use strict"

$(document).ready(function() {
  // Activate tooltips
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-bs-toggle="tooltip"]').tooltip();

  // Activate popovers
  $('[data-toggle="popover"]').popover();
  $('[data-bs-toggle="popover"]').popover();
});