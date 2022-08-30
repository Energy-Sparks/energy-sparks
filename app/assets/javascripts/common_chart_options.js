Highcharts.setOptions({
  lang: {
    numericSymbols: null,  //otherwise by default ['k', 'M', 'G', 'T', 'P', 'E']
    thousandsSep: ','
  },
  chart: {
    style: {
      fontFamily: 'Quicksand'
    }
  }
});

function commonChartOptions(clickListener){
  return {
    colors: ["#9c3367", "#67347f", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749"],
    title: { text: null },
    xAxis: { showEmpty: false },
    yAxis: { showEmpty: false, title: { rotation: 0, margin: 30, useHTML: true, style: {fontSize: '18px'} } },
    tooltip: {
      backgroundColor: null,
      borderWidth: 0,
      shadow: false,
      useHTML: true,
      style: {
          padding: 0
      }
    },
    legend: {
      align: 'left',
      margin: 20,
      verticalAlign: 'top',
      floating: false,
      backgroundColor: 'white',
      shadow: false,
      itemStyle: { fontWeight: 'normal', fontSize: '18px' },
      itemHoverStyle: { fontWeight: 'bold', fontSize: '18px' }

    },
    plotOptions: {
      series: {
        states: {
          inactive: {
            opacity: 1
          },
          hover: {
            brightness: -0.2
          }
        },
        events: {
          legendItemClick: function(e) {
            logEvent("legend", e.target.name);
            return true;
          }
        }
      },
      bar: {
        stacking: 'normal',
      },
      column: {
        dataLabels: {
          color: '#232b49'
        },
        point: {
          events: {
            click: clickListener
          }
        }
      },
      pie: {
        allowPointSelect: true,
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
        },
        point: {
          events: {
            click: clickListener
          }
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
        },
        point: {
          events: {
            click: clickListener
          }
        }
      }
    }
  };
}

function barColumnLine(chartData, highchartsChart, seriesData, chartConfig) {
  var subChartType = chartData.chart1_subtype;
  var chartType = chartData.chart1_type;

  //console.log(chartType + ': ' + subChartType);

  var xAxisCategories = chartData.x_axis_categories;
  var yAxisLabel = chartData.y_axis_label;
  var y2AxisLabel = chartData.y2_axis_label;

  var noAdvice = chartConfig.no_advice;
  var noZoom = chartConfig.no_zoom;

  highchartsChart.xAxis[0].setCategories(xAxisCategories);

  // BAR Charts
  if (chartType == 'bar') {
    if (chartData.uses_time_of_day) {
      //console.log('time of day set');
      highchartsChart.update({yAxis: { type: 'datetime', dateTimeLabelFormats: { day: '%H:%M'} }})
    }

    highchartsChart.update({ chart: { inverted: true, marginLeft: 200, marginRight: 100 }, yAxis: [{ reversedStacks: false, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }], plotOptions: { bar: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel)}}}});

    if (chartData.x_max_value) {
      highchartsChart.update({yAxis: { max: chartData.x_max_value, min: -chartData.x_max_value }})
    }
  }

  // LINE charts
  if (chartType == 'line') {
    if (! y2AxisLabel) {
      highchartsChart.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: orderedPointFormat(yAxisLabel) }}}});
    }
  }

  // Column charts
  if (chartType == 'column') {
    if (! noZoom) {
      highchartsChart.update({ chart: { zoomType: 'x'}, subtitle: { text: document.ontouchstart === undefined ?  chartData.click_and_drag_message : chartData.pinch_and_zoom_message }});
    }

    if (subChartType == 'stacked') {
      highchartsChart.update({ plotOptions: { column: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel) }, stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
    } else {

      if(seriesData[0]['day_format'] && seriesData[0]['day_format']) {
        highchartsChart.update({ plotOptions: { column: { tooltip: { headerFormat: '', pointFormat: dayAndPointFormat(yAxisLabel)}}}});
      }
      else {
        highchartsChart.update({ plotOptions: { column: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel)}}}});
      }

    }
  }

  // Handle Y2 axis
  if (y2AxisLabel) {
    var colour = '#232b49';

    //console.log('Y2 axis label' + y2AxisLabel);

    axisFontSize = '18px'

    highchartsChart.addAxis({ title: { text: chartData.y2_axis_label, rotation: 0, useHTML: true, margin: 10, style: {fontSize: axisFontSize} }, stackLabels: { style: { fontWeight: 'bold',  color: colour }}, opposite: true, max: chartData.y2_max });
    highchartsChart.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: chartData.y2_point_format }}}});
  }

  Object.keys(seriesData).forEach(function (key) {
    //console.log('Series data name: ' + seriesData[key].name);

    if (seriesData[key].name == 'CUSUM') {
      highchartsChart.update({ plotOptions: { line: { tooltip: { pointFormat: '{point.y:.2f}', valueSuffix: yAxisLabel }}}});
    }

    if (isAStringAndStartsWith(seriesData[key].name, 'Energy') && seriesData[key].type == 'line') {
      //console.log(seriesData[key]);
      seriesData[key].tooltip = { pointFormat: orderedPointFormat(yAxisLabel) }
    }
    // The false parameter stops it being redrawed after every addition of series data
    highchartsChart.addSeries(seriesData[key], false);
  });

  updateChartLabels(chartData, highchartsChart);
  normaliseYAxis(highchartsChart);

  highchartsChart.redraw();
}

function updateChartLabels(data, chart){

  var yAxisLabel = data.y_axis_label;
  var xAxisLabel = data.x_axis_label;

  if (yAxisLabel) {
    //console.log('we have a yAxisLabel ' + yAxisLabel);
    chart.update({ yAxis: [{ title: { text: yAxisLabel, useHTML: true }}]});
  }

  if (xAxisLabel) {
    //console.log('we have a xAxisLabel ' + xAxisLabel);
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

function scatter(chartData, highchartsChart, seriesData) {
  //console.log('scatter');

  updateChartLabels(chartData, highchartsChart);
  highchartsChart.update({chart: { type: 'scatter', zoomType: 'xy'}, subtitle: { text: document.ontouchstart === undefined ? chartData.click_and_drag_message : chartData.pinch_and_zoom_message }});


  Object.keys(seriesData).forEach(function (key) {
    //console.log(seriesData[key].name);
    highchartsChart.addSeries(seriesData[key], false);
  });
  normaliseYAxis(highchartsChart);
  highchartsChart.redraw();
}

function pie(chartData, highchartsChart, seriesData, $chartDiv) {
  $chartDiv.addClass('pie-chart');
  var chartHeight = $chartDiv.height();
  var yAxisLabel = chartData.y_axis_label;

  highchartsChart.addSeries(seriesData, false);
  highchartsChart.update({chart: {
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
  highchartsChart.redraw();
}

function dayAndPointFormat(label) {
  var format = '<b>{point.day}</b><br>{point.y:.2f}';
  if(label == '£'){
    return label + format;
  } else {
    return format + ' ' + label;
  }
}

function orderedPointFormat(label){
  var format = '{point.y:.2f}';
  if(label == '£'){
    return label + format;
  } else {
    return format + ' ' + label;
  }
}

// If there are 2 axis and one or both of them dips under 0
// then make sure the scales are in the same ratio

function normaliseYAxis(chart){
  if(chart.yAxis.length === 2){
    var firstAxis = chart.yAxis[0];
    var firstExtremes = firstAxis.getExtremes();
    var secondAxis = chart.yAxis[1];
    var secondExtremes = secondAxis.getExtremes();
    if((firstExtremes.min < 0 && secondExtremes.min >= 0)){
      normaliseAxis(secondAxis, firstExtremes, secondExtremes);
    }
    if((firstExtremes.min >= 0 && secondExtremes.min <  0)){
      normaliseAxis(firstAxis, secondExtremes, firstExtremes);
    }
    if((firstExtremes.min < 0 && secondExtremes.min <  0)){
      var firstMinMaxRatio = firstExtremes.max / firstExtremes.min;
      var secondMinMaxRatio = secondExtremes.max / secondExtremes.min;
      if(firstMinMaxRatio > secondMinMaxRatio){
        normaliseAxis(secondAxis, firstExtremes, secondExtremes);
      } else {
        normaliseAxis(firstAxis, secondExtremes, firstExtremes);
      }
    }
  }
}

function normaliseAxis(axisToChange, axisAExtremes, axisBExtremes){
  var ratio = axisAExtremes.max / axisAExtremes.min;
  axisToChange.setExtremes((axisBExtremes.max / ratio), axisBExtremes.max)
}

function logEvent(action, label){
  //console.log("Logging:" + action + " - " + label);
  if (typeof gtag !== 'undefined') {
    gtag('event', action, {
      'event_category': 'Charts',
      'event_label': label
    });
  }
}
