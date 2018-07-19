"use strict";

$(document).ready(function() {
  if ($("div.simulator-chart").length ) {
    $('button.update-simulator').on('click', function(event) {
      console.log('heelo');
      event.preventDefault();
      updateSimulatorCharts();
    });

    $('form').bind('keypress', function(event) {
      if ( event.keyCode == 13 ) {
        console.log('here');
        event.preventDefault();
        updateSimulatorCharts();
      }
    });

    function updateSimulatorCharts() {
      var data = $("form.simulation :input").serializeArray();
      var dataPath = window.location.href + '.json';
      $.get(dataPath, data).done(function(data) {
        $.each(data.charts, function( index, value ) {
          var chart = $('div#chart_' + index).highcharts();
          chart.series[0].setData(value.series_data[0].data);
          chart.series[1].setData(value.series_data[1].data);
        });
      });
    }
  }
});
