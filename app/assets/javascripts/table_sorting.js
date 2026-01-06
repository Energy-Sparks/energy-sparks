"use strict"

$(document).ready(function() {
  DataTable.ext.errMode = 'throw';

  $('.table-sorted').DataTable({
    columnDefs: [{ targets: 'no-sort', orderable: false }, { targets: '.sort-desc', orderSequence: ['desc', 'asc'] }],
    order: [],        // Default do not sort
    paging: false,
    searching: false, // Switch off search field
    info: false,       // Switch off the summary of rows at the bottom of the page
    orderCellsTop: false, // Switch off adding sorting to first header row
    autoWidth: false // Switch off auto resizing
  });

  $('.table-large').DataTable({
    scrollX: true,
    order: [],        // Default do not sort
    paging: true,
    searching: false, // Switch off search field
    info: false       // Switch off the summary of rows at the bottom of the page
  });

  const isWelsh = document.documentElement.lang === 'cy';

  $('.table-paged').DataTable({
    columnDefs: [{ targets: 'no-sort', orderable: false }],
    order: [],
    paging: true,
    searching: true,
    info: true,
    orderCellsTop: false,
    autoWidth: false,
    layout: {
      topStart: 'search',
      topEnd: {
        pageLength: {
          menu: [ 10, 20, 50, 100, { label: isWelsh ? 'Holl' : 'All', value: -1 } ]
        }
      },
      bottomStart: 'info',
      bottomEnd: 'paging',
    },
    ...(isWelsh && {
      language: {
        url: 'https://cdn.datatables.net/plug-ins/2.0.2/i18n/cy.json'
      }
    })
  });
});
