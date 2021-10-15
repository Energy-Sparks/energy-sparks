"use strict"

$(document).ready(function() {

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
        tickInterval: maxValue / 10,
        labels: {
          enabled: false
        },
        minorTickWidth: 0,
        tickLength: 50,
        tickWidth: 2,
        tickColor: 'white',
        zIndex: 6,
        stops: getStops()
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
        data: 0
      }]

    });

    return chart;
  }

  function getStops() {
    var i = 0;
    var stops = [];
    for (i = 0; i < 0.6; i += 0.01) {
      stops.push([i, '#5cb85c']); // $green
    }
    for (i = 0.6; i < 0.8; i += 0.01) {
      stops.push([i, '#ffac21']); // $light-orange
    }
    for (i = 0.8; i < 1.0; i += 0.01) {
      stops.push([i, '#FF3A5B']); // $bg-negative
    }
    stops.push([1, '#FF3A5B']); // $bg-negative
    return stops;
  }

  function getData(rawData) {
    var data = [rawData];
    var start = Math.round(Math.floor(rawData / 10) * 10);
    for (var i = start; i > 0; i -= 10) {
      data.push(i);
    }
    return data;
  }

  function updateLiveChart(chart, newVal) {
    chart.series[0].setData(getData(newVal));
    chart.setTitle(null, { text: subtitleWithTimestamp(newVal, new Date()) });
  }

  function startLiveDataChartUpdates(chart, url, refreshInterval) {
    setInterval(function () {
      $.get(url).done(function(data) {
        var newVal = data['value'];
        updateLiveChart(chart, newVal);
      });
    }, refreshInterval);
  }

  function subtitleWithTimestamp(value, date) {
    return (value / 1000) + " kW<br/><div class='live-data-subtitle'>Last updated: " + date.toLocaleTimeString() + "</div>";
  }

  $(".live-data-chart").each( function() {
    var container = $(this).attr('id');
    var maxValue = $(this).data('max-value') * 1000;
    var url = $(this).data("url");
    var refreshInterval = $(this).data("refresh-interval") * 1000;
    var chart = setupLiveDataChart(container, maxValue);
    startLiveDataChartUpdates(chart, url, refreshInterval);
  });

});
