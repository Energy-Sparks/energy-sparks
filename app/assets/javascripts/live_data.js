"use strict"

$(document).ready(function() {

  function getRandomInt(max) {
    return Math.floor(Math.random() * max);
  }

  function setupLiveDataChart(el) {

    var rawData = 50;

    var chart = Highcharts.chart(el[0], {
      chart: {
        type: 'solidgauge',
        marginTop: 10
      },

      title: {
        text: ''
      },

      subtitle: {
        text: rawData,
        style: {
          'font-size': '60px'
        },
        y: 200,
        zIndex: 7
      },

      tooltip: {
        enabled: false
      },

      pane: [{
        startAngle: -120,
        endAngle: 120,
        background: [{ // Track for Move
          outerRadius: '100%',
          innerRadius: '80%',
          backgroundColor: Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0.3).get(),
          borderWidth: 0,
          shape: 'arc'
        }],
        size: '120%',
        center: ['50%', '65%']
      }, {
        startAngle: -120,
        endAngle: 120,
        size: '95%',
        center: ['50%', '65%'],
        background: []
      }],

      yAxis: [{
        min: 0,
        max: 100,
        lineWidth: 2,
        lineColor: 'white',
        tickInterval: 10,
        labels: {
          enabled: false
        },
        minorTickWidth: 0,
        tickLength: 50,
        tickWidth: 5,
        tickColor: 'white',
        zIndex: 6,
        stops: [
          [0, '#fff'],
          [0.101, '#0f0'],
          [0.201, '#2d0'],
          [0.301, '#4b0'],
          [0.401, '#690'],
          [0.501, '#870'],
          [0.601, '#a50'],
          [0.701, '#c30'],
          [0.801, '#e10'],
          [0.901, '#f03'],
          [1, '#f06']
        ]
      }, {
        linkedTo: 0,
        pane: 1,
        lineWidth: 5,
        lineColor: 'white',
        tickPositions: [],
        zIndex: 6
      }],

      series: [{
        animation: false,
        dataLabels: {
          enabled: false
        },
        borderWidth: 0,
        color: Highcharts.getOptions().colors[0],
        radius: '100%',
        innerRadius: '80%',
        data: [rawData]
      }]

    });

    return chart;
  }

  function startLiveDataChartUpdates(chart) {
    setInterval(function () {
      var point = chart.series[0].points[0];
      var inc = getRandomInt(20) - 10;
      var newVal = point.y + inc;

      if (newVal < 0 || newVal > 100) {
        newVal = point.y - inc;
      }

      point.update(newVal);
      chart.setTitle(null, { text: newVal});
    }, 2000);
  }

  $(".live-data-chart").each( function() {
    var chart = setupLiveDataChart($(this));
    startLiveDataChartUpdates(chart);
  });

});
