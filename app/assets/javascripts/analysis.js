"use strict";

function chartFailure(chart, title) {
  var $chartDiv = $(chart.renderTo);
  var $chartWrapper = $chartDiv.parent();
  var $titleH3 = $chartWrapper.find('h3');

  $titleH3.text(title + ' chart');
  $chartWrapper.addClass('alert alert-warning');
  $chartDiv.remove();

  $('div#nav-row').before('<div class="alert alert-warning" role="alert">' + title + ' <a href="#' + $chartWrapper.attr('id') + '" class="alert-link">chart</a></div>');
}

function chartSuccess(chart_data, chart, noAdvice, noZoom) {

  var $chartDiv = $(chart.renderTo);
  var chartType = chart_data.chart1_type;
  var seriesData = chart_data.series_data;

  if (! noAdvice) {
    var titleH3 = $chartDiv.prev('h3');

    if ($chartDiv.data('chart-index') === 0) {
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

    barColumnLine(chart_data, chart, seriesData, chartType, noZoom);

  // Scatter
  } else if (chartType == 'scatter') {
    scatter(chart_data, chart, seriesData);

  // Pie
  } else if (chartType == 'pie') {
    pie(chart_data, chart, seriesData, $chartDiv);
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

function teachersChartSuccess(chart_data, chart) {
  var $chartDiv = $(chart.renderTo);
  var chartType = chart_data.chart1_type;
  var seriesData = chart_data.series_data;
  teachersColumn(chart_data, chart, seriesData);

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
      var dataPath = $(this).data('chart-json');
      var noAdvice = $(this).is("[data-no-advice]");
      var noZoom = $(this).is("[data-no-zoom]");
      var teachersDashboard = $(this).is("[data-teachers-dashboard]");

      var requestData = {
        chart_type: chartType,
        chart_y_axis_units: yAxisUnits,
        mpan_mprn: mpanMprn
      };

      if (dataPath === undefined) {
        var currentPath = window.location.href;
        dataPath = currentPath.substr(0, currentPath.lastIndexOf("/")) + '/chart.json'
      }

      thisChart.showLoading();

      $.ajax({
        type: 'GET',
        async: true,
        dataType: "json",
        url: dataPath,
        data: requestData,
        success: function (returnedData) {
          var thisChartData = returnedData.charts[0];
          if (thisChartData == undefined) {
            chartFailure(thisChart, "We do not have enough data at the moment to display this ");
          } else if (thisChartData.series_data == null) {
            chartFailure(thisChart, thisChartData.title);
          } else {
            if (teachersDashboard) {
              teachersChartSuccess(thisChartData, thisChart)
            } else {
              chartSuccess(thisChartData, thisChart, noAdvice, noZoom);
            }
          }
        },
        error: function(broken) {
          chartFailure(thisChart, "We do not have enough data at the moment to display this ");
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
    var date = new Date(annotation.date);
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
      text: '<a href="' + annotation.url + '"><i class="fas fa-'+annotation.icon+'" data-toggle="tooltip" data-placement="right" title="(' + date.toLocaleDateString() + ') ' + annotation.event + '"></i></a>',
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

