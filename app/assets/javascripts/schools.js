$(document).on('turbolinks:load', () =>
  $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    window.dispatchEvent(new Event('resize'));
  })
);
