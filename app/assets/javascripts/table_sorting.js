"use strict"

$(document).ready(function() {
  $('.table-sorted').DataTable({
    'columnDefs': [{ targets: 'no-sort', orderable: false }],
    'order': [],        // Default do not sort
    'paging': false,
    'searching': false, // Switch off search field
    'info': false,       // Switch off the summary of rows at the bottom of the page
    'orderCellsTop': false
  });

  $('.table-large').DataTable({
    'scrollX': true,
    'order': [],        // Default do not sort
    'paging': true,
    'searching': false, // Switch off search field
    'info': false       // Switch off the summary of rows at the bottom of the page
  });
});
