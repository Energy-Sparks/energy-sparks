"use strict"

$(document).ready(function() {

  var TOP = 94;

  function setupLiveDataChart(container, maxValue) {

    var chart = Highcharts.chart(container, {
      chart: {
        type: 'solidgauge',
        marginTop: 10
      },

      title: {
        text: ''
      },

      subtitle: {
        text: '0',
        style: {
          'font-size': '40px'
        },
        y: 200,
        zIndex: 7,
        useHTML: true
      },

      tooltip: {
        enabled: false
      },

      exporting: {
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
        max: maxValue,
        lineWidth: 2,
        lineColor: 'white',
        tickInterval: maxValue / 100,
        labels: {
          enabled: false
        },
        minorTickWidth: 0,
        tickLength: 50,
        tickWidth: 2,
        tickColor: 'white',
        zIndex: 6,
        stops: [
          [0, '#fff'],
          [0.101, '#50E3C2'],
          [0.201, '#50E3C2'],
          [0.301, '#50E3C2'],
          [0.401, '#50E3C2'],
          [0.501, '#50E3C2'],
          [0.601, '#50E3C2'],
          [0.701, '#FF8438'],
          [0.801, '#FF8438'],
          [0.901, '#FF3A5B'],
          [1, '#FF3A5B']
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
        // data: getData(Math.floor(Math.random() * TOP))
        data: 0
      }]

    });

    return chart;
  }

  function getData(rawData) {

    var data = [];

    var start = Math.round(Math.floor(rawData / 10) * 10);

    // var i = 0;
    // while (i < rawData) {
    //   i = i + rawData/10;
    //   data.push(i);
    // }

    data.push(rawData);

    // var i = rawData;

    // var i = start;
    // while (i > 0) {
    //   i = i - rawData/10;
    //   data.push(i);
    // }


    for (var i = start; i > 0; i -= 10) {
      data.push(i);
    }

    return data;
  }

  function updateLiveChart(chart, newVal, units) {
    // console.log(newVal);
    // console.log(getData(newVal));
    console.log(chart.yAxis[0].max);
    // chart.series[0].data = getData(newVal);
    chart.series[0].setData(getData(newVal));
    chart.setTitle(null, { text: subtitleWithTimestamp(newVal, units, new Date()) });
  }

  function startLiveDataChartUpdates(chart, url, refreshInterval) {
    setInterval(function () {
      $.get(url).done(function(data) {

        var newVal = data['value'];
        var units = data['units'];

        newVal = Math.floor(Math.random() * TOP);

        updateLiveChart(chart, newVal, units);
      });
    }, refreshInterval);
  }

  function subtitleWithTimestamp(value, units, date) {
    return value + " " + units + "<br/><div class='live-data-subtitle'>Last updated: " + date.toLocaleTimeString() + "</div>";
  }

  $(".live-data-chart").each( function() {
    var container = $(this).attr('id');
    // var maxValue = $(this).data('max-value');
    var maxValue = 100;
    var url = $(this).data("url");
    var refreshInterval = $(this).data("refresh-interval") * 1000;
    var chart = setupLiveDataChart(container, maxValue);
    startLiveDataChartUpdates(chart, url, refreshInterval);

    // console.log(chart.series[0]);
    // console.log(chart.series[0].points[0]);
    //
    // updateLiveChart(chart, 23, 'kww');
    //
    // console.log(chart.series[0]);

  });

});
