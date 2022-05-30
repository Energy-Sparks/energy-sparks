"use strict"

$(document).ready(function() {

  var liveDataPaused = false;

  function setupLiveDataChart(container, maxVal) {

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
        max: maxVal,
        lineWidth: 2,
        lineColor: 'white',
        tickInterval: maxVal / 10,
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

  function getData(rawData, maxVal) {
    var data = [rawData];
    var start = Math.round(Math.floor(rawData / 10) * 10);
    var step = Math.round(maxVal / 100);
    for (var i = start; i > 0; i -= step) {
      data.push(i);
    }
    return data;
  }

  function updateSuccess(chart, data) {
    var reading = data['value'];
    var power = data['power'];
    var timestamp = (new Date()).toLocaleTimeString();
    var maxVal = chart.yAxis[0].max;
    chart.series[0].setData(getData(reading, maxVal));
    chart.setTitle(null, { text: subtitleWithMessage(reading, timestamp) });
    if ($("#typical-consumption").length && power) {
      $("#typical-consumption").text(I18n.t('schools.live_data.normal_consumption', {power: power}));
    }
  }

  function updateFailure(chart) {
    var reading = 0;
    if (chart.series[0] && chart.series[0].points[0]) {
      reading = chart.series[0].points[0].y;
    }
    chart.setTitle(null, { text: subtitleWithMessage(reading, '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Retrying..') });
  }

  function updateLiveDataChart(chart, url) {
    $.get(url).done(function(data) {
      updateSuccess(chart, data);
    }).fail(function(data) {
      updateFailure(chart);
    });
  }

  function startLiveDataChartUpdates(chart, url, refreshInterval) {
    updateLiveDataChart(chart, url);
    setInterval(function () {
      if (!liveDataPaused) {
        updateLiveDataChart(chart, url);
      }
    }, refreshInterval);
  }

  function startLiveDataTimeout(timeoutInterval) {
    setInterval(function () {
      promptTimeout();
    }, timeoutInterval);
  }

  function promptTimeout() {
    liveDataPaused = true;
    $('#live-data-timeout-modal').modal();
  }

  function subtitleWithMessage(value, timestamp) {
    return (value / 1000) + " kW<br/><div class='live-data-subtitle'>Last updated: " + timestamp + "</div>";
  }

  $('#live-data-timeout-modal').on('hidden.bs.modal', function () {
    location.reload();
  });

  $(".live-data-chart").each( function() {
    var container = $(this).attr('id');
    var maxVal = $(this).data('max-value') * 1000;
    var url = $(this).data("url");
    var refreshInterval = $(this).data("refresh-interval") * 1000;
    var timeoutInterval = $(this).data("timeout-interval") * 1000 * 60;
    var chart = setupLiveDataChart(container, maxVal);
    startLiveDataChartUpdates(chart, url, refreshInterval);
    startLiveDataTimeout(timeoutInterval);
  });

});
