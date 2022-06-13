"use strict"

$(document).ready(function() { chart.render(); });

const chart = ( function() {

  var chartId = 'transport_surveys_pie';

  function render() {
    let pieChart = Highcharts.chart(chartId, commonChartOptions());
    pieChart.showLoading();

    ajaxCall()
    .done(function(data) {
      renderChart(data, pieChart);
    })
    .error(function() {
      renderError(pieChart);
    })
  }

  function renderChart(data, pieChart) {
    let chartConfig =  { y_axis_label: '%' };
    let series = { data: data };

    pie(chartConfig, pieChart, series, $(pieChart.renderTo));
    pieChart.hideLoading();
  }

  function renderError(pieChart) {
    $(pieChart.renderTo).add("h3").text('There was a problem loading this chart');
    $(pieChart.renderTo).remove();
  }

  function ajaxCall() {
    return $.ajax({
      type: 'GET',
      dataType: "json",
      url: window.location.href + '.json'
    })
  }

  // public methods
  return {
    render: render
  }

}());

