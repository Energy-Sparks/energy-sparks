"use strict";

$(document).ready(function() {
  if ($("div.alert-reports-chart").length) {
    function renderChart(chartType) {
      var chartData = JSON.parse($('div#alert-chart-data-' + chartType).text());
      var chartTitle = $('div#alert-chart-data-' + chartType).data('chart-title');

      var alertOption = {
        title: { text: chartTitle },
        xAxis: { showEmpty: false },
        yAxis: { showEmpty: false },
        chart: { type: 'pie' },
        series: [chartData],
        legend: {
          align: 'center',
          x: -30,
          margin: 20,
          verticalAlign: 'bottom',
          floating: false,
          backgroundColor: 'white',
          shadow: false
        },
        plotOptions: {
          pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: { enabled: false },
            showInLegend: true,
            tooltip: {
              headerFormat: '<b>{point.key}</b><br>',
              pointFormat: '{point.y:.2f} kWh'
            }
          },
        }
      };
      Highcharts.chart('alert-chart-wrapper-' + chartType, alertOption );
    }

    $("div.alert-reports-chart").each(function(){
      var chartType = $(this).data('chart-type');
      renderChart(chartType);
    });
  }
});

