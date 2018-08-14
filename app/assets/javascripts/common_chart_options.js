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
      },
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
}


function barColumnLine(d, c, chartIndex, seriesData, yAxisLabel, chartType) {
  var subChartType = d.chart1_subtype;
  console.log('bar or column or line ' + subChartType);

  var xAxisCategories = d.x_axis_categories;
  var y2AxisLabel = d.y2_axis_label;

  c.xAxis[0].setCategories(xAxisCategories);

  // BAR Charts
  if (chartType == 'bar') {
    console.log('bar');
    c.update({ chart: { inverted: true }, yAxis: [{ stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
  }

  // LINE charts
  if (chartType == 'line') {
    if (y2AxisLabel !== undefined && y2AxisLabel == 'Temperature') {
      console.log('Yaxis - Temperature');
      c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} °C' }}}});
    }
  }

  // Column charts
  if (chartType == 'column') {
    console.log('column: ' + subChartType);

    if (subChartType == 'stacked') {
      c.update({ plotOptions: { column: { stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
    }

    if (y2AxisLabel !== undefined && (y2AxisLabel == 'Degree Days' || y2AxisLabel == 'Temperature')) {
      console.log('Yaxis - Degree days');
      c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} °C' }}}});
    }
  }

  Object.keys(seriesData).forEach(function (key) {
    console.log('Series data name: ' + seriesData[key].name);

    if (seriesData[key].name == 'CUSUM') {
      c.update({ plotOptions: { line: { tooltip: { pointFormat: '{point.y:.2f} kWh' }}}});
    }
    // The false parameter stops it being redrawed after every addition of series data
    c.addSeries(seriesData[key], false);
  });

  if (yAxisLabel.length) {
    console.log('we have a yAxisLabel ' + yAxisLabel);
    c.update({ yAxis: [{ title: { text: yAxisLabel }}]});
  }
  c.redraw();
}

function scatter(d, c, chartIndex, seriesData, yAxisLabel) {
  console.log('scatter');
  c.update({chart: { type: 'scatter' }});

  if (yAxisLabel.length) {
    console.log('we have a yAxisLabel ' + yAxisLabel);
    c.update({ xAxis: [{ title: { text: 'Degree Days' }}], yAxis: [{ title: { text: yAxisLabel }}]});
  }

  Object.keys(seriesData).forEach(function (key) {
    console.log(seriesData[key].name);
    c.addSeries(seriesData[key], false);
  });
  c.redraw();
}

function pie(d, c, chartIndex, seriesData, $chartDiv) {
  $chartDiv.addClass('pie-chart');

  c.addSeries(seriesData, false);
  c.update({chart: {
    height: 450,
    plotBackgroundColor: null,
    plotBorderWidth: null,
    plotShadow: false,
    type: 'pie'
  }});
  c.redraw();
}