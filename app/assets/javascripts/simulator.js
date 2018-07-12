"use strict";

$(document).ready(function() {
  if ($("div.simulator-chart").length ) {
    $('button#update-simulator').on('click', function(e) {
      e.preventDefault();
      var data = $("#new_simulator :input").serializeArray();
      var dataPath = window.location.href + '.json';
      $.get(dataPath, data).done(function(data) {
        $.each(data.charts, function( index, value ) {
          var chart = $('div#chart_' + index).highcharts();
          chart.series[0].setData(value.series_data[0].data);
          chart.series[1].setData(value.series_data[1].data);
        });
      });
    });
  }
});
