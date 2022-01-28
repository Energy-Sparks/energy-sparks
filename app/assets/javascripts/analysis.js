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
    if (chartData.drilldown_available) {
      titleH5.text('Click on the chart to explore the data');
    } else {
      titleH5.text('');
    }
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

  enableAxisControls($chartWrapper, chartData);

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
      setupAxisControls(this, chartConfig);
    });
  }

  //activate tooltips
  $('[data-toggle="tooltip"]').tooltip();
}

function processAnalysisChartAjax(chartId, chartConfig, highchartsChart) {
  var chartType = chartConfig.type;
  var yAxisUnits = chartConfig.y_axis_units;
  var mpanMprn = chartConfig.mpan_mprn;
  var seriesBreakdown = chartConfig.series_breakdown;
  var dateRanges = chartConfig.date_ranges;
  var dataPath = chartConfig.jsonUrl;
  var transformations = chartConfig.transformations;
  var requestData = {
    chart_type: chartType,
    chart_y_axis_units: yAxisUnits,
    mpan_mprn: mpanMprn,
    transformations: transformations,
    series_breakdown: seriesBreakdown,
    date_ranges: dateRanges
  };

  highchartsChart.showLoading();

  $.ajax({
    type: 'GET',
    async: true,
    dataType: "json",
    url: dataPath,
    data: requestData,
    success: function (returnedData) {
      var thisChartData = returnedData;
      if (thisChartData == undefined || thisChartData.length == 0) {
        chartFailure(highchartsChart, "We do not have enough data at the moment to display this ");
      } else if (thisChartData.series_data == null) {
        chartFailure(highchartsChart, thisChartData.title);
      } else {
        chartSuccess(chartConfig, thisChartData, highchartsChart);
      }
    },
    error: function(broken) {
      chartFailure(highchartsChart, "We do not have enough data at the moment to display this ");
    }
  });
}

function processAnalysisChart(chartContainer, chartConfig){
  var thisId = chartContainer.id;
  var thisChart = Highcharts.chart(thisId, commonChartOptions(function(event){processChartClick(chartConfig, chartContainer, event)}));
  var chartData = chartConfig.jsonData;

  if (chartData !== undefined) {
    chartSuccess(chartConfig, chartData, thisChart);
  } else {
    processAnalysisChartAjax(thisId, chartConfig, thisChart)
  }
}

//Highcharts filters attributes from HTML given as text labels, so add this
//so we can style the annotation popovers using Bootstrap.
Highcharts.AST.allowedAttributes.push('data-toggle');
Highcharts.AST.allowedAttributes.push('data-placement');

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
  var controls = $(chartContainer).parent().find('.analysis-controls');
  if(controls.length){
    controls.find('.move_back').on('click', function(event){
      event.preventDefault();
      $(this).prop( "disabled", true );
      pushTransformation(chartConfig, chartContainer, 'move', -1);
    });
    controls.find('.move_forward').on('click', function(event){
      event.preventDefault();
      $(this).prop( "disabled", true );
      pushTransformation(chartConfig, chartContainer, 'move', 1);
    });

    controls.find('.drillup').on('click', function(event){
      event.preventDefault();

      $(this).prop( "disabled", true );

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

function setupAxisControls(chartContainer, chartConfig) {
  var controls = $(chartContainer).parent().find('.axis-controls');
  if(controls.length){
    console.log("Setting axis controls");
    $(controls).find('.axis-choice').on('change', function(event){
      //manipulate the chartConfig
      chartConfig['y_axis_units'] = $(this).data("unit");
      console.log(chartConfig);
      processAnalysisChart(chartContainer, chartConfig);
    });
  }
}

//call from chartSuccess to enable controls based on chart options
function enableAxisControls(chartContainer, chartData) {
  var controls = $(chartContainer).find('.axis-controls');
  if(controls.length){
    if(chartData.y1_axis_choices) {
      controls.show();
    }
    console.log('Axis choices: ' + chartData.y1_axis_choices);
    $(controls).find('.axis-choice').each(function() {
      if(chartData.y1_axis_choices.includes( $(this).data("unit"))) {
        $(this).prop('disabled', false);
      } else {
        $(this).prop('disabled', true);
      }
      label = $("label[for='" + $(this).attr("id") + "']");
      if(label) {
        console.log( $(label).text() );
        console.log( chartData.y_axis_label );
        if ($(label).text() == chartData.y_axis_label) {
          $(this).prop('checked', true);
        }
      }
    });
  }
}

function processAnalysisOperations(chartConfig, chart, operations, drilldownAvailable, parentTimescaleDescription){
  var chartContainer = $(chart.renderTo);
  var controls = $(chartContainer).parent().find('.analysis-controls');
  var anyOperations = false;
  if(controls.length){
    $.each(operations, function(operation, config ) {
      $.each(config.directions, function(direction, enabled ) {
        var control = controls.find(`.${operation}_${direction}`);
        anyOperations |= enabled;
        if(enabled){
          control.prop("disabled", false);
          control.show();
        } else {
          control.prop("disabled", true);
        }
        control.find('span.period').html(config.timescale_description);
      });
    });

   chartConfig.drilldown_available =  drilldownAvailable;

   if(drilldownAvailable) {
     chart.update({plotOptions: {series: {cursor: 'pointer'}}});
   }

   var transformations = chartConfig.transformations;
   var inDrilldown = transformations.some(isDrilldownTransformation);

   //if we're in a drilldown
   //or there's a drilldown available
   //or there's any operations available, show the controls
   if(inDrilldown || drilldownAvailable || anyOperations) {
     $(controls).show();
   }

    var drillup = controls.find('.drillup');
    if(inDrilldown){
      drillup.find('span.period').html(parentTimescaleDescription);
      drillup.prop( "disabled", false );
      drillup.show();
    } else {
      drillup.prop( "disabled", true );
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
  var controls = $(chartContainer).parent().find('.analysis-controls');
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
