"use strict"

document.addEventListener('DOMContentLoaded', function() {
  DataTable.ext.errMode = 'throw';

  document.querySelectorAll('.table-sorted').forEach(function(table) {
    new DataTable(table, {
      columnDefs: [{ targets: 'no-sort', orderable: false }, { targets: '.sort-desc', orderSequence: ['desc', 'asc'] }],
      order: [],        // Default do not sort
      paging: false,
      searching: false, // Switch off search field
      info: false,       // Switch off the summary of rows at the bottom of the page
      orderCellsTop: false, // Switch off adding sorting to first header row
      autoWidth: false // Switch off auto resizing
    });
  });

  document.querySelectorAll('.table-large').forEach(function(table) {
    new DataTable(table, {
      scrollX: true,
      order: [],        // Default do not sort
      paging: true,
      searching: false, // Switch off search field
      info: false       // Switch off the summary of rows at the bottom of the page
    });
  });

  const isWelsh = document.documentElement.lang === 'cy';

  document.querySelectorAll('.table-paged').forEach(function(table) {
    new DataTable(table, {
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
            menu: [10, 20, 50, 100, { label: isWelsh ? 'Holl' : 'All', value: -1 }]
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

  // Redraw DataTables when Bootstrap tabs are shown.
  // Fixes pagination issues when tables are initialised in hidden tabs.
  document.querySelectorAll('[data-toggle="tab"], [data-bs-toggle="tab"]').forEach(function(tab) {
    tab.addEventListener('shown.bs.tab', function(e) {
      const target = e.target.getAttribute('href');
      if (!target) return;
      document.querySelector(target).querySelectorAll('table.dataTable').forEach(function(table) {
        DataTable.Api(table).columns.adjust();
      });
    });
  });
});
