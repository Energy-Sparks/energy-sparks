"use strict"

$(document).ready(function() {
  $('.table-sorted').DataTable({
    'order': [],        // Default do not sort
    'paging': false,
    'searching': false, // Switch off search field
    'info': false       // Switch off the summary of rows at the bottom of the page
  });
});
