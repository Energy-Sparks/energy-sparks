"use strict"

$(document).ready(function() {
  if ($("div.analysis-chart").length ) {
    $('#new_simulator').on('submit', function(e) {
      e.preventDefault();
      var data = $("#new_simulator :input").serializeArray();

      var currentPath = window.location.href
      var dataPath = currentPath.substr(0, currentPath.lastIndexOf("/")) + '.json';

      $.post(dataPath, data).done(function(data) {
        var chart = $('div#chart_1').highcharts();
        chart.series[0].setData(data.charts[0].series_data[0].data);
      });
    });
  }
});
