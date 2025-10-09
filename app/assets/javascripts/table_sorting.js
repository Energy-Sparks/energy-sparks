"use strict"

$(document).ready(function() {
  DataTable.ext.errMode = 'throw';

  $('.table-sorted').DataTable({
    'columnDefs': [{ targets: 'no-sort', orderable: false }],
    'order': [],        // Default do not sort
    'paging': false,
    'searching': false, // Switch off search field
    'info': false,       // Switch off the summary of rows at the bottom of the page
    'orderCellsTop': false, // Switch off adding sorting to first header row
    'autoWidth': false // Switch off auto resizing
  });

  $('.table-large').DataTable({
    'scrollX': true,
    'order': [],        // Default do not sort
    'paging': true,
    'searching': false, // Switch off search field
    'info': false       // Switch off the summary of rows at the bottom of the page
  });

  $('.table-paged').DataTable({
    'columnDefs': [{ targets: 'no-sort', orderable: false }],
    'order': [],        // Default do not sort
    'paging': true,
    'searching': true, // Switch off search field
    'info': true,       // Switch off the summary of rows at the bottom of the page
    'orderCellsTop': false, // Switch off adding sorting to first header row
    'autoWidth': false // Switch off auto resizing
  });
});
