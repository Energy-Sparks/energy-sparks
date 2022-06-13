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
      renderError();
    })
  }

  function renderError() {
    alert("error!");
    let titleH3 = $('#transport_surveys_pie h3');
    titleH3.text('There was a problem loading this chart');
    $('#transport_surveys_pie').remove();
  }

  function renderChart(data, pieChart) {
    let chartConfig =  { y_axis_label: '%' };
    let series = { data: data };

    pie(chartConfig, pieChart, series, $(chartId));
    pieChart.hideLoading();
  }

  function ajaxCall() {
    return $.ajax({
      type: 'GET',
      async: true,
      dataType: "json",
      url: window.location.href + '.json'
    })
  }

  // public methods
  return {
    render: render
  }

}());

