"use strict"

var commonOptions = {
  title: {
    text: "Loading data..."
  },
  xAxis: {},
  yAxis: [{
   // min: 0,
    title: {
      text: 'Pounds'
    },
    stackLabels: {
      style: {
        fontWeight: 'bold',
        color: '#232b49'
      }
    }
  }, {
    min: 0,
    title: {
      text: '°C'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: '#232b49'
      }
    },
    opposite: true
  }],
  legend: {
    align: 'right',
    x: -60,
    verticalAlign: 'top',
    y: 25,
    floating: false,
    backgroundColor: 'white',
    borderColor: '#232b49',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
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
        dataLabels: {
            enabled: false
        },
        showInLegend: true
    }
  },
}

function updateData(c, d) {
  if (d.data !== null) {

    c.setTitle({ text: d.title});
    if (d.data.chart1_type == 'bar' || d.data.chart1_type == 'column' || d.data.chart1_type == 'line') {

      var x_axis = d.data.x_axis
      c.xAxis[0].setCategories(x_axis);

      if (d.data.chart1_type == 'bar') {
        c.update({ chart: { inverted: true }, plotOptions: { bar: { stacking: 'normal'}}});
      }

      if (d.chart_type != 'electricity_by_month_acyear_0_1') {
        c.update({  plotOptions: { column: { stacking: 'normal'}}});
      }

      if (d.data.chart1_type == 'line') {
    //    c.update({ yAxis: [{ min: -1000,  title: { text: 'kWh' }}]});
      }

      if (d.data.y_axis_label.length) {
        c.update({ yAxis: [{ title: { text: d.data.y_axis_label }}]});
      }

      var seriesData = d.series_data;
      Object.keys(seriesData).forEach(function (key) {
        c.addSeries(seriesData[key]);
      });

    } else if (d.data.chart1_type == 'pie') {
      c.addSeries(d.series_data);
      c.update({chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie'
      }});
    }
  } else {
    console.log('d.data is null');
  }
}

$(document).ready(function() {

  $("div.analysis-chart").each(function(){
    var this_id = this.id;
    var this_chart = Highcharts.chart(this_id, commonOptions );
    this_chart.showLoading();
    console.log(this.id);
  });

  $.ajax({
    type: 'GET',
    async: true,
    dataType: "json",
    success: function (returnedData) {
      var numberOfCharts = returnedData.charts.length;
      for (var i = 0; i < numberOfCharts; i++) {
          var this_chart = $("div.analysis-chart")[i];
          var chart = $('div#' + this_chart.id).highcharts();
          chart.hideLoading();
          updateData(chart, returnedData.charts[i])
      }
    }
  });
});