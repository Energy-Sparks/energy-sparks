/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('Hello World from Webpacker')

require("trix")
require("@rails/actiontext")

require("chartkick").use(require("highcharts"))
require("chart.js")


import 'bootstrap/dist/js/bootstrap';
import Highcharts from 'highcharts'


Highcharts.setOptions({
  lang: {
    numericSymbols: null,  //otherwise by default ['k', 'M', 'G', 'T', 'P', 'E']
    thousandsSep: ','
  }
});

var commonChartOptions = {
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
    },
    column: {
      dataLabels: {
        color: '#232b49'
      },
    },
    pie: {
      allowPointSelect: true,
      colors: ["#9c3367", "#67347f", "#501e74", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749"],
      cursor: 'pointer',
      dataLabels: { enabled: false },
      showInLegend: true,
      point: {
        events: {
          legendItemClick: function () {
            return false;
          }
        }
      }
    },
    line: {
      tooltip: {
        headerFormat: '<b>{point.key}</b><br>',
        pointFormat: orderedPointFormat('kW')
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
}


function barColumnLine(d, c, chartIndex, seriesData, chartType, noZoom) {
  var subChartType = d.chart1_subtype;
  console.log('bar or column or line ' + subChartType);

  var xAxisCategories = d.x_axis_categories;
  var yAxisLabel = d.y_axis_label;
  var y2AxisLabel = d.y2_axis_label;

  c.xAxis[0].setCategories(xAxisCategories);

  // BAR Charts
  if (chartType == 'bar') {
    console.log('bar');
    c.update({ chart: { inverted: true }, yAxis: [{ stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }], plotOptions: { bar: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel)}}}});
  }

  // LINE charts
  if (chartType == 'line') {
    if (y2AxisLabel !== undefined && y2AxisLabel.length) {
      if (y2AxisLabel == 'Temperature') {
        var axisTitle = '°C';
        var pointFormat = '{point.y:.2f} °C';
      } else if (isAStringAndStartsWith(y2AxisLabel, 'Carbon')) {
        var axisTitle = 'kWh';
        var pointFormat = '{point.y:.2f} kWh';
      } else if (isAStringAndStartsWith(y2AxisLabel, 'Solar')) {
        var axisTitle = 'W/m2';
        var pointFormat = '{point.y:.2f} W/m2';
      }
      c.addAxis({ title: { text: axisTitle }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: pointFormat }}}});
    } else {
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: orderedPointFormat(yAxisLabel) }}}});
    }
  }

  // Column charts
  if (chartType == 'column') {
    console.log('column: ' + subChartType);
    if (! noZoom) {
      c.update({ chart: { zoomType: 'x'}, subtitle: { text: document.ontouchstart === undefined ?  'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in' }});
    }

    if (subChartType == 'stacked') {
      c.update({ plotOptions: { column: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel) }, stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
    } else {
      c.update({ plotOptions: { column: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel)}}}});
    }

    if (y2AxisLabel !== undefined && y2AxisLabel.length) {
      console.log('Y2 axis label' + y2AxisLabel);
      var colour = '#232b49';
      if (y2AxisLabel == 'Temperature') {
        var axisTitle = '°C';
        var pointFormat = '{point.y:.2f} °C';
      } else if (y2AxisLabel == 'Degree Days') {
        var axisTitle = 'Degree days';
        var pointFormat = '{point.y:.2f} Degree days';
      } else if (y2AxisLabel == 'Solar Irradiance') {
        var axisTitle = 'W/m2';
        var pointFormat = '{point.y:.2f} W/m2';
      }
      c.addAxis({ title: { text: axisTitle }, stackLabels: { style: { fontWeight: 'bold',  color: colour }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: pointFormat }}}});
    }
  }

  Object.keys(seriesData).forEach(function (key) {
    console.log('Series data name: ' + seriesData[key].name);

    if (seriesData[key].name == 'CUSUM') {
      c.update({ plotOptions: { line: { tooltip: { pointFormat: '{point.y:.2f}', valueSuffix: yAxisLabel }}}});
    }

    if (isAStringAndStartsWith(seriesData[key].name, 'Energy') && seriesData[key].type == 'line') {
      console.log(seriesData[key]);
      seriesData[key].tooltip = { pointFormat: orderedPointFormat(yAxisLabel) }
      seriesData[key].dashStyle =  'Dash';
    }
    // The false parameter stops it being redrawed after every addition of series data
    c.addSeries(seriesData[key], false);
  });

  updateChartLabels(d, c);

  c.redraw();
}

function updateChartLabels(data, chart){

  var yAxisLabel = data.y_axis_label;
  var xAxisLabel = data.x_axis_label;

  if (yAxisLabel) {
    console.log('we have a yAxisLabel ' + yAxisLabel);
    chart.update({ yAxis: [{ title: { text: yAxisLabel }}]});
  }

  if (xAxisLabel) {
    console.log('we have a xAxisLabel ' + xAxisLabel);
    chart.update({ xAxis: [{ title: { text: xAxisLabel }}]});
  }
}

function isAStringAndStartsWith(thing, startingWith) {
  // IE Polyfill for startsWith
  if (!String.prototype.startsWith) {
    Object.defineProperty(String.prototype, 'startsWith', {
      value: function(search, pos) {
        pos = !pos || pos < 0 ? 0 : +pos;
        return this.substring(pos, pos + search.length) === search;
      }
    });
  }

  return (typeof thing === 'string' || thing instanceof String) && thing.startsWith(startingWith);
}

function scatter(d, c, chartIndex, seriesData) {
  console.log('scatter');


  updateChartLabels(d, c);
  c.update({chart: { type: 'scatter', zoomType: 'xy'}, subtitle: { text: document.ontouchstart === undefined ?  'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in' }});


  Object.keys(seriesData).forEach(function (key) {
    console.log(seriesData[key].name);
    c.addSeries(seriesData[key], false);
  });
  c.redraw();
}

function pie(d, c, chartIndex, seriesData, $chartDiv) {
  $chartDiv.addClass('pie-chart');
  var chartHeight = $chartDiv.height();
  var yAxisLabel = d.y_axis_label;

  c.addSeries(seriesData, false);
  c.update({chart: {
    height: chartHeight,
    plotBackgroundColor: null,
    plotBorderWidth: null,
    plotShadow: false,
    type: 'pie'
  },
  plotOptions: {
   pie: {
    tooltip: {
        headerFormat: '<b>{point.key}</b><br>',
        pointFormat: orderedPointFormat(yAxisLabel)
      }
    }
  }
  });
  c.redraw();
}

function orderedPointFormat(label){
  var format = '{point.y:.2f}';
  if(label == '£'){
    return label + format;
  } else {
    return format + ' ' + label;
  }
}


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
          if (this_chart_data.series_data == null) {
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

