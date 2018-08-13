"use strict";

var commonOptions = {
  title: { text: null },
  xAxis: { showEmpty: false },
  yAxis: { showEmpty: false },
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
    bar: {
      stacking: 'normal',
      tooltip: {
        headerFormat: '<b>{series.name}</b><br>',
        pointFormat: '£ {point.y:.2f}'
      }
    },
    column: {
      dataLabels: {
        color: '#232b49'
      },
      tooltip: {
        headerFormat: '<b>{series.name}</b><br>',
        pointFormat: '{point.y:.2f} kWh'
      }
    },
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
    line: {
      tooltip: {
        headerFormat: '<b>{point.key}</b><br>',
        pointFormat: '{point.y:.2f} kW'
      }
    },
    scatter: {
      marker: {
        radius: 5,
        states: {
          hover: {
            enabled: true,
            lineColor: 'rgb(100,100,100)'
          }
        }
      },
      states: {
        hover: {
          marker: {
            enabled: false
          }
        }
      },
      tooltip: {
        headerFormat: '<b>{series.name}</b><br>',
        pointFormat: '{point.x:.2f} °C, {point.y:.2f} kWh'
      }
    }
  }
};

function barColumnLine(d, c, chartIndex, seriesData, yAxisLabel, chartType) {
  var subChartType = d.chart1_subtype;
  var xAxisCategories = d.x_axis_categories;
  var y2AxisLabel = d.y2_axis_label;

  c.xAxis[0].setCategories(xAxisCategories);

  // BAR Charts
  if (chartType == 'bar') {
    c.update({ chart: { inverted: true }, yAxis: [{ stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
  }

  // LINE charts
  if (chartType == 'line') {
    if (y2AxisLabel !== undefined && y2AxisLabel == 'Temperature') {
      c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} °C' }}}});
    }
  }

  // Column charts
  if (chartType == 'column') {
    if (subChartType == 'stacked') {
      c.update({ plotOptions: { column: { stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
    }

    if (y2AxisLabel !== undefined && (y2AxisLabel == 'Degree Days' || y2AxisLabel == 'Temperature')) {
      c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} °C' }}}});
    }
  }

  Object.keys(seriesData).forEach(function (key) {
    if (seriesData[key].name == 'CUSUM') {
      c.update({ plotOptions: { line: { tooltip: { pointFormat: '{point.y:.2f} kWh' }}}});
    }
    c.addSeries(seriesData[key]);
  });

  if (yAxisLabel.length) {
    c.update({ yAxis: [{ title: { text: yAxisLabel }}]});
  }
}

function scatter(d, c, chartIndex, seriesData, yAxisLabel) {
  c.update({chart: { type: 'scatter' }});

  if (yAxisLabel.length) {
    c.update({ xAxis: [{ title: { text: 'Degree Days' }}], yAxis: [{ title: { text: yAxisLabel }}]});
  }

  Object.keys(seriesData).forEach(function (key) {
    c.addSeries(seriesData[key]);
  });
}

function pie(d, c, chartIndex, seriesData, $chartDiv) {
  $chartDiv.addClass('pie-chart');

  c.addSeries(seriesData);
  c.update({chart: {
    height: 450,
    plotBackgroundColor: null,
    plotBorderWidth: null,
    plotShadow: false,
    type: 'pie'
  }});
}

function chartSuccess(d, c, chartIndex) {

  var chartDiv = c.renderTo;
  var $chartDiv = $(chartDiv);
  var titleH3 = $chartDiv.prev('h3');

   if (chartIndex === 0) {
     titleH3.text(d.title);
   } else {
    titleH3.before('<hr class="analysis"/>');
    titleH3.text(d.title);
  }

  var chartType = d.chart1_type;
  var seriesData = d.series_data;
  var yAxisLabel = d.y_axis_label;

  var adviceHeader = d.advice_header;
  var adviceFooter = d.advice_footer;

  if (adviceHeader !== undefined) {
    $chartDiv.before('<div>' + adviceHeader + '</div>');
  }

  if (adviceFooter !== undefined) {
    $chartDiv.after('<div>' + adviceFooter + '</div>');
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
      var thisChart = Highcharts.chart(thisId, commonOptions );
      var chartType = $(this).data('chart-type');
      var chartIndex = $(this).data('chart-index');
      var currentPath = window.location.href;
      var dataPath = currentPath.substr(0, currentPath.lastIndexOf("/")) + '/chart.json?chart_type=' + chartType;
      thisChart.showLoading();

      $.ajax({
        type: 'GET',
        async: true,
        dataType: "json",
        url: dataPath,
        success: function (returnedData) {
          chartSuccess(returnedData.charts[0], thisChart, chartIndex);
        },
        error: function(broken) {
          var titleH3 = $('div#chart_wrapper_' + chartIndex + ' h3');
          titleH3.text('There was a problem with this chart');
          $('div#chart_' + chartIndex).remove();
        }
      });
    });
  }
});

