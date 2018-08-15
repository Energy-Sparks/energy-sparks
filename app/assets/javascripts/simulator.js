"use strict";

$(document).ready(function() {
  if ($("div.simulator-chart").length ) {
    $('button.update-simulator').on('click', function(event) {
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

    $('div.timepicker').datetimepicker({
      format: 'LT'
    });


    var controlType = $('input[name="simulator[security_lighting][control_type]"]:checked').val();
    $('p.control-type-description').hide();
    $('div#security_lighting div.hidden').hide();
    $('p#' + controlType).show();
    $('div.hidden.' + controlType).show();

    $('input[name="simulator[security_lighting][control_type]"]').click(function(event) {
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
      });
    }
  }

  if ($("div.analysis-chart").length ) {
   function alignYAxes() {

        $('[data-pair]').each(function() {

          var thisPair = $(this).data('pair');
          var pairOfDivs = $('[data-pair=' + thisPair + ']');
          if (pairOfDivs.length) {

            var maxY = 0;
            $('[data-pair=' + thisPair  +']').each(function() {
 //chart.yAxis[0].max;
              var thisChart = $(this).highcharts();
              console.log(thisChart);
              console.log(thisChart.yAxis[0]);
            });
          //  Sort them out

          }

        });

    }
    console.log('HELLLLOOOOO');
    alignYAxes();
  };

});


