"use strict";

$(document).ready(function() {

  function setupBulletChart(el) {
    title = $(el).data("title");
    series = $(el).data("series");
    label = $(el).data("label");
    units = $(el).data("units");
    plotBands = $(el).data("bands");
    Highcharts.chart(el[0], {
        chart: {
            marginTop: 40,
            inverted: true,
            marginLeft: 135,
            type: 'bullet'
        },
        plotOptions: {
            series: {
                pointPadding: 0.25,
                borderWidth: 0,
                color: '#222222',
                targetOptions: {
                    width: '200%'
                }
            }
        },
        legend: {
            enabled: false
        },
        title: {
            text: title
        },
        credits: {
            enabled: false
        },
        exporting: {
            enabled: false
        },
        xAxis: {
            categories: ['<span class="hc-cat-title">' + label + '</span><br/>('+ units + ')']
        },
        yAxis: {
            gridLineWidth: 0,
            plotBands: plotBands,
            title: null
        },
        series: [{
            data: [series]
        }],
        tooltip: {
            pointFormat: '<b>{point.y} '+ units + '</b> (with target at {point.target} ' + units + ')'
        }
    });
  }

  $(".bullet-chart").each( function() {
      setupBulletChart($(this));
  });

});
