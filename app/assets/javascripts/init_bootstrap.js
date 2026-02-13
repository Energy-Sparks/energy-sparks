"use strict"

document.addEventListener("DOMContentLoaded", function () {

  // Tooltips
  document
    .querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach(el => new bootstrap.Tooltip(el));

  // Popovers
  document
    .querySelectorAll('[data-bs-toggle="popover"]')
    .forEach(el => new bootstrap.Popover(el));

});