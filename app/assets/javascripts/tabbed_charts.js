"use strict";

$(document).ready(function() {
  // Bootstrap uses display: none to hide inactive tabs. This means Highcharts
  // is no able to determine a width to initialize the chart with and so defaults to 600 (px)
  // To fix this issue, this resets the size of the chart when the tab is shown.

  $(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function (e) { // on tab selection event
    $(".analysis-chart.tabbed").each(function() {
      $(this).highcharts().setSize();
    });
  });
});
