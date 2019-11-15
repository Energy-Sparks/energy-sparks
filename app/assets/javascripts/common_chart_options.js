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
    title: { text: null },
    xAxis: { showEmpty: false },
    yAxis: { showEmpty: false },
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
      align: 'center',
      margin: 20,
      verticalAlign: 'bottom',
      floating: false,
      backgroundColor: 'white',
      shadow: false
    },
    plotOptions: {
      series: {
        states: {
          inactive: {
            opacity: 1
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

function teachersChartOptions(pointFormat) {
  return {
    legend: {
      itemStyle: {
        fontWeight: 'normal'
      }
    },
    plotOptions: {
      series: {
        pointPadding: 0.02, groupPadding: 0.07
      },
      column: {
        tooltip: {
          headerFormat: '<b>{series.name}</b><br>', pointFormat: pointFormat
        }
      }
    },
    xAxis: {
      lineWidth: 3, lineColor: 'rgb(151,151,151)'
    },
    yAxis: [{
      title: {
        text: "£"
      }
    }],
    navigation: {
      buttonOptions: {
        enabled: false
      }
    }
  }
}

function teachersColumn(chart_data, chart, seriesData) {

  console.log('Teachers column chart');

  var xAxisCategories = chart_data.x_axis_categories;
  var yAxisLabel = chart_data.y_axis_label;

  chart.xAxis[0].setCategories(xAxisCategories);
  chart.update(teachersChartOptions(orderedPointFormat(yAxisLabel)));

  Object.keys(seriesData).forEach(function (key) {
    // The false parameter stops it being redrawed after every addition of series data
    chart.addSeries(seriesData[key], false);
  });

  chart.redraw();
}

function barColumnLine(d, c, seriesData, chartType, noZoom) {
  var subChartType = d.chart1_subtype;
  console.log('bar or column or line ' + subChartType);

  var xAxisCategories = d.x_axis_categories;
  var yAxisLabel = d.y_axis_label;
  var y2AxisLabel = d.y2_axis_label;

  c.xAxis[0].setCategories(xAxisCategories);

  // BAR Charts
  if (chartType == 'bar') {
    console.log('bar');
    c.update({ chart: { inverted: true }, yAxis: [{ reversedStacks: false, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }], plotOptions: { bar: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: orderedPointFormat(yAxisLabel)}}}});
  }

  // LINE charts
  if (chartType == 'line') {
    if (y2AxisLabel) {

      var axisTitle;
      var pointFormat;

      if (y2AxisLabel == 'Temperature') {
        axisTitle = '°C';
        pointFormat = '{point.y:.2f} °C';
      } else if (isAStringAndStartsWith(y2AxisLabel, 'Carbon')) {
        axisTitle = 'kWh';
        pointFormat = '{point.y:.2f} kWh';
      } else if (isAStringAndStartsWith(y2AxisLabel, 'Solar')) {
        axisTitle = 'Brightness of sunshine W/m2';
        pointFormat = '{point.y:.2f} W/m2';
      }
      c.addAxis({ title: { text: axisTitle }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true});
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

    if (y2AxisLabel) {

      var axisTitle;
      var pointFormat;
      var max;

      console.log('Y2 axis label' + y2AxisLabel);
      colour = '#232b49';
      if (y2AxisLabel == 'Temperature') {
        axisTitle = '°C';
        pointFormat = '{point.y:.2f} °C';
      } else if (y2AxisLabel == 'Degree Days') {
        axisTitle = 'Degree days';
        pointFormat = '{point.y:.2f} Degree days';
      } else if (isAStringAndStartsWith(y2AxisLabel, 'Carbon Intensity')) {
        axisTitle = 'kg/kWh';
        pointFormat = '{point.y:.2f} kg/kWh';
        max = 0.5;
      } else if (y2AxisLabel == 'Solar Irradiance') {
        axisTitle = 'Brightness of sunshine W/m2';
        pointFormat = '{point.y:.2f} W/m2';
      }
      c.addAxis({ title: { text: axisTitle }, stackLabels: { style: { fontWeight: 'bold',  color: colour }}, opposite: true, max: max});
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
    }
    // The false parameter stops it being redrawed after every addition of series data
    c.addSeries(seriesData[key], false);
  });

  updateChartLabels(d, c);
  normaliseYAxis(c);

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

function scatter(d, c, seriesData) {
  console.log('scatter');


  updateChartLabels(d, c);
  c.update({chart: { type: 'scatter', zoomType: 'xy'}, subtitle: { text: document.ontouchstart === undefined ?  'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in' }});


  Object.keys(seriesData).forEach(function (key) {
    console.log(seriesData[key].name);
    c.addSeries(seriesData[key], false);
  });
  normaliseYAxis(c);
  c.redraw();
}

function pie(d, c, seriesData, $chartDiv) {
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
