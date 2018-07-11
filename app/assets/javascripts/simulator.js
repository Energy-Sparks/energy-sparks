"use strict";

$(document).ready(function() {
  if ($("div.simulator-chart").length ) {
    $('#new_simulator').on('submit', function(e) {
      e.preventDefault();
      var data = $("#new_simulator :input").serializeArray();

      var currentPath = window.location.href;
      var dataPath = currentPath.substr(0, currentPath.lastIndexOf("/")) + '.json';

      $.post(dataPath, data).done(function(data) {
        $.each(data.charts, function( index, value ) {

          var chart = $('div#chart_' + index).highcharts();
          console.log(data);
          chart.series[1].setData(value.series_data[0].data);
        });
      });
    });
  }
});
