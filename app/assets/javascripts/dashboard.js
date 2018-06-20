"use strict"

var commonOptions = {
  title: {
    text: "Loading data...",
    // floating: true,
    // x: 0,
    // y: -60
  },
  xAxis: { showEmpty: false },
  yAxis: { showEmpty: false },
  legend: {
    align: 'center',
    x: -60,
    margin: 30,
    verticalAlign: 'bottom',
    //y: 25,
    floating: false,
    backgroundColor: 'white',
    borderColor: '#232b49',
    borderWidth: 1,
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
          pointFormat: '{point.y:.2f} kW' }
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

function updateData(c, d, chartDiv, index) {

  c.setTitle({ text: null });
  if (index == 0) {
    chartDiv.before('<h3 class="analysis">' + d.title + '</h3>');
  } else {
    chartDiv.before('<hr/><h3 class="analysis">' + d.title + '</h3>');
  }


  var chartType = d.chart1_type;
  var subChartType = d.chart1_subtype;
  var seriesData = d.series_data;
  var yAxisLabel = d.y_axis_label;
  var y2AxisLabel = d.y2_axis_label;
  var xAxisCategories = d.x_axis_categories;
  var adviceHeader = d.advice_header;
  var adviceFooter = d.advice_footer;

  if (adviceHeader !== undefined) {
    chartDiv.before('<div>' + adviceHeader + '</div>');
  }

  if (adviceFooter !== undefined) {
    chartDiv.after('<div>' + adviceFooter + '</div>');
  }

  console.log("################################");
  console.log(d.title);
  console.log("################################");

  if (chartType == 'bar' || chartType == 'column' || chartType == 'line') {

    console.log('bar or column or line ' + subChartType);
    c.xAxis[0].setCategories(xAxisCategories);

    // BAR Charts
    if (chartType == 'bar') {
      console.log('bar');
      c.update({ chart: { inverted: true }, yAxis: [{ stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
    }

    // Column charts
    if (chartType == 'column') {
      console.log('column: ' + subChartType);

      if (subChartType == 'stacked') {
        c.update({ plotOptions: { column: { stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
      }

      if (y2AxisLabel !== undefined && y2AxisLabel == 'Degree Days') {
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
      c.addSeries(seriesData[key]);
    });

    if (yAxisLabel.length) {
      console.log('we have a yAxisLabel ' + yAxisLabel);
      c.update({ yAxis: [{ title: { text: yAxisLabel }}]});
    }

  // Scatter
  } else if (chartType == 'scatter') {
    console.log('scatter');
    c.update({chart: { type: 'scatter' }});

    if (yAxisLabel.length) {
      console.log('we have a yAxisLabel ' + yAxisLabel);
      c.update({ xAxis: [{ title: { text: 'Degree Days' }}], yAxis: [{ title: { text: yAxisLabel }}]});
    }

    Object.keys(seriesData).forEach(function (key) {
      console.log(seriesData[key].name);
      c.addSeries(seriesData[key]);
    });

  // Pie
  } else if (chartType == 'pie') {
    chartDiv.addClass('pie-chart');

    c.addSeries(seriesData);
    c.update({chart: {
      height: 300,
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false,
      type: 'pie'
    }});
  }
}

$(document).ready(function() {

  $("div.analysis-chart").each(function(){
    var this_id = this.id;
    var this_chart = Highcharts.chart(this_id, commonOptions );
    this_chart.showLoading();
  });

  $.ajax({
    type: 'GET',
    async: true,
    dataType: "json",
    success: function (returnedData) {
      var numberOfCharts = returnedData.charts.length;
      for (var index = 0; index < numberOfCharts; index++) {
        var this_chart = $("div.analysis-chart")[index];
        var chartDiv = $('div#' + this_chart.id);
        var chart = chartDiv.highcharts();
        chart.hideLoading();

        var chartData = returnedData.charts[index];
        if (chartData !== undefined) { updateData(chart, chartData, chartDiv, index); }
      }
    }
  });
});