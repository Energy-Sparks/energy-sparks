"use strict"

var commonOptions = {
  title: {
    text: "Loading data...",
    // floating: true,
    // x: 0,
    // y: -60
  },
  xAxis: {},
  yAxis: { showEmpty: false },
  legend: {
    align: 'right',
    x: -60,
    margin: 30,
    verticalAlign: 'top',
    y: 25,
    floating: false,
    backgroundColor: 'white',
    borderColor: '#232b49',
    borderWidth: 1,
    shadow: false
  },
  plotOptions: {
    column: {
      dataLabels: {
        color: '#232b49'
      }
    },
    pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: { enabled: false },
        showInLegend: true
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
            pointFormat: '{point.x} cm, {point.y} kg'
        }
    }
  }
}

function updateData(c, d, chartDiv) {

  c.setTitle({ text: d.title});

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

    console.log('bar or column or line');
    c.xAxis[0].setCategories(xAxisCategories);

    // BAR Charts
    if (chartType == 'bar') {
      console.log('bar');
      c.update({ chart: { inverted: true }, plotOptions: { bar: { stacking: 'normal'}}, yAxis: [{ stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
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
      }
    }

    Object.keys(seriesData).forEach(function (key) {
      console.log(seriesData[key].name);
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

    Object.keys(seriesData).forEach(function (key) {
      console.log(seriesData[key].name);
      c.addSeries(seriesData[key]);
    });

  // Pie
  } else if (chartType == 'pie') {
    c.addSeries(seriesData);
    c.update({chart: {
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
      for (var i = 0; i < numberOfCharts; i++) {
        var this_chart = $("div.analysis-chart")[i];
        var chartDiv = $('div#' + this_chart.id);
        var chart = chartDiv.highcharts();
        chart.hideLoading();

        var chartData = returnedData.charts[i];
        if (chartData !== undefined) { updateData(chart, chartData, chartDiv); }
      }
    }
  });
});