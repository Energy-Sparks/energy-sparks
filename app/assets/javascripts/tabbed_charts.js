$(document).ready(function() {
  $(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function (e) { // on tab selection event
    $(".analysis-chart.tabbed").each(function() {
      $(this).highcharts().setSize();
    });
  });
});