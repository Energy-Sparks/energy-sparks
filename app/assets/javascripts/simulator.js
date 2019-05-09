"use strict";

$(document).ready(function() {

  function alignYAxes() {
    $('div.synchronise-y-axis').each(function() {

      var maxY = 0;

      $(this).find('div.simulator-chart').each(function() {
        console.log('got this one: ' + $(this));
        var thisChart = $(this).highcharts();
        var thisChartYAxisMax = thisChart.yAxis[0].dataMax;
        if (thisChartYAxisMax > maxY) {
          maxY = thisChartYAxisMax;
        }
      });

      $(this).find('div.simulator-chart').each(function() {
        var thisChart = $(this).highcharts();
        thisChart.update({ yAxis: { max: maxY }});
      });
    });
  }

  if ($("div.simulator-chart").length ) {
    var dataPath = window.location.href + '.json';

    $("div.simulator-chart").each(function(){
      var thisId = this.id;
      var thisChart = Highcharts.chart(thisId, commonChartOptions);
      thisChart.showLoading();
    });

    function successfulData(returnedData) {
      $("div.simulator-chart").each(function(){
        var thisId = this.id;
        var thisChart = Highcharts.chart(thisId, commonChartOptions);
        var chartType = $(this).data('chart-type');
        var chartIndex = $(this).data('chart-index');
        var noAdvice = $(this).is("[data-no-advice]");
        var noZoom = $(this).is("[data-no-zoom]");

        chartSuccess(returnedData.charts[chartIndex], thisChart, chartIndex, noAdvice, noZoom);
      });
      alignYAxes();
    }

    $.ajax({
      type: 'GET',
      async: true,
      dataType: "json",
      url: dataPath,
      success: successfulData,
      error: function(broken) {
        console.log('snap');
        var titleH3 = $('div#chart_wrapper_' + chartIndex + ' h3');
        titleH3.text('There was a problem loading this chart');
        $('div#chart_' + chartIndex).remove();
      }
    });
  }

  if ($("div.simulator-chart").length ) {
    $('button.update-simulator').on('click', function(event) {
      event.preventDefault();
      updateSimulatorCharts();
    });

    $('form').bind('keypress', function(event) {
      if ( event.keyCode == 13 ) {
        event.preventDefault();
        updateSimulatorCharts();
      }
    });

    $('div.timepicker').datetimepicker({
      format: 'LT'
    });


    var controlType = $('input[name="simulation[security_lighting][control_type]"]:checked').val();
    $('p.control-type-description').hide();
    $('div#security_lighting div.hidden').hide();
    $('p#' + controlType).show();
    $('div.hidden.' + controlType).show();

    $('input[name="simulation[security_lighting][control_type]"]').click(function(event) {
      var controlType = event.target.value;
      $('p.control-type-description').hide();
      $('div#security_lighting div.hidden').hide();
      $('p#' + controlType).show();
      $('div.hidden.' + controlType).show();
    });

    function updateSimulatorCharts() {
      var data = $("form.simulation :input").serializeArray();

      var dataPath = location.protocol + "//" + location.host + location.pathname + '.json'

      // TODO there are neater ways to do this!
      if (location.search == '?fitted_configuration=true') {
        data[data.length] = { name: "fitted_configuration", value: "true" };
      }

      $.get(dataPath, data).done(function(data) {
        $.each(data.charts, function( index, value ) {
          var chart = $('div#chart_' + index).highcharts();
          chart.series[0].setData(value.series_data[0].data);
          chart.series[1].setData(value.series_data[1].data);
        });
        alignYAxes();
      });
    }
  }
});


