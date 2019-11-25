"use strict";

function chartFailure(chart, title) {
  var $chartDiv = $(chart.renderTo);
  var $chartWrapper = $chartDiv.parents('.chart-wrapper');

  $chartWrapper.addClass('alert alert-warning');
  $chartWrapper.html(`<h3>${title} chart</h3>`)
}

function chartSuccess(chartConfig, chartData, chart) {

  var $chartDiv = $(chart.renderTo);
  var chartType = chartData.chart1_type;
  var seriesData = chartData.series_data;
  var noAdvice = chartConfig.no_advice;

  var $chartWrapper = $chartDiv.parents('.chart-wrapper');

  var titleH3 = $chartWrapper.find('h3');
  var titleH5 = $chartWrapper.find('h5');

  titleH3.text(chartData.title);

  if (chartData.subtitle) {
    titleH5.text(chartData.subtitle);
  } else {
    titleH5.hide();
  }

  if (! noAdvice) {

    var adviceHeader = chartData.advice_header;
    var adviceFooter = chartData.advice_footer;

    if (adviceHeader) {
      $chartWrapper.find('.advice-header').html(adviceHeader);
    }

    if (adviceFooter) {
      $chartWrapper.find('.advice-footer').html(adviceFooter);
    }
  }

  if (chartType == 'bar' || chartType == 'column' || chartType == 'line') {

    barColumnLine(chartData, chart, seriesData, chartConfig);

  // Scatter
  } else if (chartType == 'scatter') {
    scatter(chartData, chart, seriesData);

  // Pie
  } else if (chartType == 'pie') {
    pie(chartData, chart, seriesData, $chartDiv);
  }

  if(chartData.allowed_operations){
    processAnalysisOperations(chartConfig, chart, chartData.allowed_operations, chartData.drilldown_available, chartData.parent_timescale_description)
  }

  if(chartData.annotations){
    var xAxis = chart.xAxis[0];

    var xAxisCategories = xAxis.categories;
    if(chartData.annotations == 'weekly'){
      var data = {
        date_grouping: chartData.annotations,
        x_axis_categories: xAxisCategories
      };
    } else {
      var data = {
        date_grouping: chartData.annotations,
        x_axis_start: xAxisCategories[0],
        x_axis_end: xAxisCategories.slice(-1)[0]
      };
    }

    $.ajax({
      type: 'GET',
      dataType: "json",
      url: chartConfig.annotations,
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
      var chartConfig = $(this).data('chart-config');
      processAnalysisChart(this, chartConfig);
      setupAnalysisControls(this, chartConfig);
    });
  }
}

function processAnalysisChart(chartContainer, chartConfig){
  var thisId = chartContainer.id;
  var thisChart = Highcharts.chart(thisId, commonChartOptions(function(event){processChartClick(chartConfig, chartContainer, event)}));
  var chartType = chartConfig.type;
  var yAxisUnits = chartConfig.y_axis_units;
  var mpanMprn = chartConfig.mpan_mprn;
  var seriesBreakdown = chartConfig.series_breakdown;
  var dateRanges = chartConfig.date_ranges;
  var dataPath = chartConfig.jsonUrl;
  var chartData = chartConfig.jsonData;
  var transformations = chartConfig.transformations;

  if (dataPath !== undefined && dataPath.length) {
    var requestData = {
      chart_type: chartType,
      chart_y_axis_units: yAxisUnits,
      mpan_mprn: mpanMprn,
      transformations: transformations,
      series_breakdown: seriesBreakdown,
      date_ranges: dateRanges
    };

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
          chartSuccess(chartConfig, thisChartData, thisChart);
        }
      },
      error: function(broken) {
        chartFailure(thisChart, "We do not have enough data at the moment to display this ");
      }
    });
  } else {
    chartSuccess(chartConfig, chartData, thisChart);
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

function setupAnalysisControls(chartContainer, chartConfig){
  var controls = $(chartContainer).parent().find('.analysis_controls');
  if(controls.length){
    controls.find('.move_back').hide().on('click', function(event){
      event.preventDefault();
      pushTransformation(chartConfig, chartContainer, 'move', -1);
    });
    controls.find('.move_forward').hide().on('click', function(event){
      event.preventDefault();
      pushTransformation(chartConfig, chartContainer, 'move', 1);
    });

    controls.find('.drillup').hide();
    controls.find('.drillup').on('click', function(event){
      event.preventDefault();

      var transformations = chartConfig.transformations;
      var inDrilldown = transformations.some(isDrilldownTransformation);
      var lastDrilldownIndex = transformations.reverse().findIndex(isDrilldownTransformation);
      var sliceTo = transformations.length - lastDrilldownIndex - 1;
      var newTransformtions = transformations.reverse().slice(0, sliceTo);

      chartConfig.transformations = newTransformtions;
      processAnalysisChart(chartContainer, chartConfig);
    });
  }
}

function processAnalysisOperations(chartConfig, chart, operations, drilldownAvailable, parentTimescaleDescription){
  var chartContainer = $(chart.renderTo);
  var controls = $(chartContainer).parent().find('.analysis_controls');
  if(controls.length){
    $.each(operations, function(operation, config ) {
      $.each(config.directions, function(direction, enabled ) {
        var control = controls.find(`.${operation}_${direction}`);
        if(enabled){
          control.show();
        } else {
          control.hide();
        }
        control.find('span.period').html(config.timescale_description);
      });
    });

   chartConfig.drilldown_available =  drilldownAvailable;

    if(drilldownAvailable){
      chart.update({subtitle: {text: 'Click on the chart to explore the data'}});
    }

    var transformations = chartConfig.transformations;
    var inDrilldown = transformations.some(isDrilldownTransformation);
    var drillup = controls.find('.drillup');
    if(inDrilldown){
      drillup.find('span.period').html(parentTimescaleDescription);
      drillup.show();
    } else {
      drillup.hide();
    }
  }
}

function pushTransformation(chartConfig, chartContainer, transformation_type, transformation_value){
  var transformations = chartConfig.transformations;
  var last_transformation = transformations[transformations.length -1];

  if(transformation_type != 'drilldown' && last_transformation && last_transformation[0] == transformation_type){
    var new_transformation_value = last_transformation[1] + transformation_value;
    transformations.pop();
    if(new_transformation_value != 0){
      transformations.push([transformation_type, last_transformation[1] + transformation_value]);
    }
  } else {
    transformations.push([transformation_type, transformation_value]);
  }
  chartConfig.transformations = transformations;
  processAnalysisChart(chartContainer, chartConfig);
}

function processChartClick(chartConfig, chartContainer, event){
  var controls = $(chartContainer).parent().find('.analysis_controls');
  if(controls.length){
    if(chartConfig.drilldown_available){
      pushTransformation(chartConfig, chartContainer, 'drilldown', event.point.index)
    }
  }
}

function isDrilldownTransformation(transformation){
  return transformation[0] == 'drilldown';
}

$(document).ready(processAnalysisCharts);

