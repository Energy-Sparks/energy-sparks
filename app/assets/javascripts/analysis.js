"use strict";

function chartSuccess(d, c, chartIndex, noAdvice) {

  var chartDiv = c.renderTo;
  var $chartDiv = $(chartDiv);
  var chartType = d.chart1_type;
  var seriesData = d.series_data;
  var yAxisLabel = d.y_axis_label;

  if (! noAdvice) {
    var titleH3 = $chartDiv.prev('h3');

    if (chartIndex === 0) {
      titleH3.text(d.title);
    } else {
      titleH3.before('<hr class="analysis"/>');
      titleH3.text(d.title);
    }

    var adviceHeader = d.advice_header;
    var adviceFooter = d.advice_footer;

    if (adviceHeader !== undefined) {
      $chartDiv.before('<div>' + adviceHeader + '</div>');
    }

    if (adviceFooter !== undefined) {
      $chartDiv.after('<div>' + adviceFooter + '</div>');
    }
  }

  if (chartType == 'bar' || chartType == 'column' || chartType == 'line') {
    barColumnLine(d, c, chartIndex, seriesData, yAxisLabel, chartType);

  // Scatter
  } else if (chartType == 'scatter') {
    scatter(d, c, chartIndex, seriesData, yAxisLabel);

  // Pie
  } else if (chartType == 'pie') {
    pie(d, c, chartIndex, seriesData, $chartDiv);
  }
  c.hideLoading();
}

$(document).ready(function() {
  if ($("div.analysis-chart").length ) {
    $("div.analysis-chart").each(function(){
      var thisId = this.id;
      var thisChart = Highcharts.chart(thisId, commonChartOptions);
      var chartType = $(this).data('chart-type');
      var chartIndex = $(this).data('chart-index');
      var dataPath = $(this).data('chart-json');
      var noAdvice = $(this).is("[data-no-advice]");

      // Each chart handles it's own data, except for the simulator
      var processChartIndex = 0;

      if (dataPath === undefined) {
        var currentPath = window.location.href;
        dataPath = currentPath.substr(0, currentPath.lastIndexOf("/")) + '/chart.json?chart_type=' + chartType;
      }
      console.log(chartIndex);
      console.log(chartType);
      console.log(dataPath);
      thisChart.showLoading();

      if ($(this).hasClass('simulator-chart')) {
        // the simulator uses the chart index
        processChartIndex = chartIndex;
      }

      $.ajax({
        type: 'GET',
        async: true,
        dataType: "json",
        url: dataPath,
        success: function (returnedData) {
          chartSuccess(returnedData.charts[processChartIndex], thisChart, chartIndex, noAdvice);
        },
        error: function(broken) {
          var titleH3 = $('div#chart_wrapper_' + chartIndex + ' h3');
          titleH3.text('There was a problem loading this chart');
          $('div#chart_' + chartIndex).remove();
        }
      });
    });
  }
});

