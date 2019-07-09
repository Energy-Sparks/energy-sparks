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

  if(chart_data.annotations){
    var xAxis = chart.xAxis[0];

    var xAxisCategories = xAxis.categories;
    if(chart_data.annotations == 'weekly'){
      var data = {
        date_grouping: chart_data.annotations,
        x_axis_categories: xAxisCategories
      };
    } else {
      var data = {
        date_grouping: chart_data.annotations,
        x_axis_start: xAxisCategories[0],
        x_axis_end: xAxisCategories.slice(-1)[0]
      };
    }

    $.ajax({
      type: 'GET',
      dataType: "json",
      url: $chartDiv.data('chart-annotations'),
      data: data,
      success: function (returnedData) {
        processAnnotations(returnedData, chart)
      }
    });
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
      var thisChart = Highcharts.chart(thisId, commonChartOptions());
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

function processAnnotations(loaded_annotations, chart){
  var xAxis = chart.xAxis[0];
  var xAxisCategories = xAxis.categories;

  var annotations = loaded_annotations.map(function(annotation){
    var categoryIndex = xAxisCategories.indexOf(annotation.x_axis_category);
    var date = new Date(annotation.date);
    var point = xAxis.series[0].getValidPoints()[categoryIndex];
    if(xAxis.series[0].stackKey){
      var y = point.total;
    } else {
      var y = point.y;
    }
    return {
      point: {
        x: categoryIndex,
        y: y,
        xAxis: 0,
        yAxis: 0,
      },
      text: '<i class="fas fa-'+annotation.icon+'" data-toggle="tooltip" data-placement="right" title="'+annotation.event+'"></i>',
    };
  });
  chart.addAnnotation({
    labelOptions:{
      useHTML: true,
      style: {
        fontSize: '15px'
      }
    },
    labels: annotations
  }, true);
  $('.highcharts-annotation [data-toggle="tooltip"]').tooltip()
}

$(document).ready(processAnalysisCharts);

