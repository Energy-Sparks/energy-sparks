"use strict";

function chartFailure(title, chartIndex) {
  var $divWrapper = $('div#chart_wrapper_' + chartIndex);
  var $titleH3 = $('div#chart_wrapper_' + chartIndex + ' h3');

  $titleH3.text(title + ' chart');
  $divWrapper.addClass('alert alert-warning');
  $('div#chart_' + chartIndex).remove();

  $('div#nav-row').before('<div class="alert alert-warning" role="alert">' + title + ' <a href="#chart_wrapper_' + chartIndex + '" class="alert-link">chart</a></div>');
}

function chartSuccess(chart_data, chart, chartIndex, noAdvice, noZoom) {

  var chartDiv = chart.renderTo;
  var $chartDiv = $(chartDiv);
  var chartType = chart_data.chart1_type;
  var seriesData = chart_data.series_data;

  if (! noAdvice) {
    var titleH3 = $chartDiv.prev('h3');

    if (chartIndex === 0) {
      titleH3.text(chart_data.title);
    } else {
      titleH3.before('<hr class="analysis"/>');
      titleH3.text(chart_data.title);
    }

    var adviceHeader = chart_data.advice_header;
    var adviceFooter = chart_data.advice_footer;

    if (adviceHeader) {
      $chartDiv.before('<div>' + adviceHeader + '</div>');
    }

    if (adviceFooter) {
      $chartDiv.after('<div>' + adviceFooter + '</div>');
    }
  }

  if (chartType == 'bar' || chartType == 'column' || chartType == 'line') {
    barColumnLine(chart_data, chart, chartIndex, seriesData, chartType, noZoom);

  // Scatter
  } else if (chartType == 'scatter') {
    scatter(chart_data, chart, chartIndex, seriesData);

  // Pie
  } else if (chartType == 'pie') {
    pie(chart_data, chart, chartIndex, seriesData, $chartDiv);
  }

  $chartDiv.attr( "maxYvalue", chart.yAxis[0].max );

  // Activate any popovers
  $('[data-toggle="popover"]').popover();

  chart.hideLoading();
}
function processAnalysisCharts(){
  if ($("div.analysis-chart").length ) {
    $("div.analysis-chart").each(function(){
      var thisId = this.id;
      var thisChart = Highcharts.chart(thisId, commonChartOptions);
      var chartType = $(this).data('chart-type');
      var yAxisUnits = $(this).data('chart-y-axis-units');
      var mpanMprn = $(this).data('chart-mpan-mprn');
      var chartIndex = $(this).data('chart-index');
      var dataPath = $(this).data('chart-json');
      var noAdvice = $(this).is("[data-no-advice]");
      var noZoom = $(this).is("[data-no-zoom]");

      var requestData = {
        chart_type: chartType,
        chart_y_axis_units: yAxisUnits,
        mpan_mprn: mpanMprn
      };


      // Each chart handles it's own data, except for the simulator
      var processChartIndex = 0;

      if (dataPath === undefined) {
        var currentPath = window.location.href;
        dataPath = currentPath.substr(0, currentPath.lastIndexOf("/")) + '/chart.json'
      }

      console.log(chartIndex);
      console.log(chartType);
      console.log(dataPath);
      console.log(requestData);
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
        data: requestData,
        success: function (returnedData) {
          var this_chart_data = returnedData.charts[processChartIndex];
          if (this_chart_data == undefined) {
            chartFailure("We do not have enough data at the moment to display this ", chartIndex);
          } else if (this_chart_data.series_data == null) {
            chartFailure(this_chart_data.title, chartIndex);
          } else {
            chartSuccess(this_chart_data, thisChart, chartIndex, noAdvice, noZoom);
          }
        },
        error: function(broken) {
          chartFailure("We do not have enough data at the moment to display this ", chartIndex);
        }
      });
    });
  }
}

$(document).ready(processAnalysisCharts);

