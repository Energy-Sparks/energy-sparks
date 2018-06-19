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
  // tooltip: {
  //   headerFormat: '<b>{point.x}</b><br/>',
  //   pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  // },
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
    }
  },
}


// anaylsis_type: "daytype_breakdown_electricity"
// ​
// chart1_subtype: null
// ​
// chart1_type: "pie"
// ​
// series_data: Object { name: "Breakdown by type of day/time: Electricity 41,485 kWh", colorByPoint: true, data: (4) […] }
// ​
// title: "Breakdown by type of day/time: Electricity 41,485 kWh"
// ​
// y_axis_label: "kWh"


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

  if (adviceHeader !== undefined && adviceHeader !== 'null') {
    console.log()
    chartDiv.before('<div>' + adviceHeader + '</div>');
  }

  if (adviceFooter !== undefined && adviceFooter !== 'null') {
    chartDiv.after('<div>' + adviceFooter + '</div>');
  }

  console.log("################################");
  console.log(d.title);
  console.log("################################");


    if (chartType == 'bar' || chartType == 'column' || chartType == 'line') {

      console.log('bar or column or line');
      c.xAxis[0].setCategories(xAxisCategories);
      //console.log(xAxisCategories);

      if (chartType == 'bar') {
        console.log('bar');
        c.update({ chart: { inverted: true }, plotOptions: { bar: { stacking: 'normal'}}, yAxis: [{title: { text: 'Pounds' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
      }

      if (chartType == 'column') {
        console.log('column');
        console.log(subChartType);
        console.log(yAxisLabel);

        if (subChartType == 'stacked') {
          c.update({ chart: { plotOptions: { bar: { stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]}});
        }

       // c.update({yAxis: [{ title: { text: 'Pounds' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}}]});


        if (y2AxisLabel !== undefined && y2AxisLabel == 'Degree Days') {
          console.log('Yaxis - Degree days');
          c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });



  //        c.update({yAxis: [{ title: { text: 'Pounds' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}}]});


          // }, {
        //   min: 0,
        //   title: {
        //     text: '°C'
        //   },
        //   stackLabels: {
        //     enabled: true,
        //     style: {
        //       fontWeight: 'bold',
        //       color: '#232b49'
        //     }
        //   },
        //   opposite: true
        // }

// {yAxis: [{title: { text: 'Pounds' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }] }


   // c.update({yAxis: [{

   //        title: {
   //          text: 'Pounds'
   //        },
   //        stackLabels: {
   //          style: {
   //            fontWeight: 'bold',
   //            color: '#232b49'
   //          }
   //        }
   //      // }, {
   //      //   min: 0,
   //      //   title: {
   //      //     text: '°C'
   //      //   },
   //      //   stackLabels: {
   //      //     enabled: true,
   //      //     style: {
   //      //       fontWeight: 'bold',
   //      //       color: '#232b49'
   //      //     }
   //      //   },
   //      //   opposite: true
   //      // }
   //    }]});




      } else {
        // c.update( {yAxis: [
        //       {
        //         title: { text: 'Pounds' },
        //         stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}
        //       }
        //     ]});

       }



     //   console.log(d.data.y2_data);
        // if (d.data.)
        // c.update(yAxis: [{

        //   title: {
        //     text: 'Pounds'
        //   },
        //   stackLabels: {
        //     style: {
        //       fontWeight: 'bold',
        //       color: '#232b49'
        //     }
        //   }
        // }, {
        //   min: 0,
        //   title: {
        //     text: '°C'
        //   },
        //   stackLabels: {
        //     enabled: true,
        //     style: {
        //       fontWeight: 'bold',
        //       color: '#232b49'
        //     }
        //   },
        //   opposite: true
        // }]);

      }



// yAxis: [{
//    // min: 0,
//     title: {
//       text: 'Pounds'
//     },
//     stackLabels: {
//       style: {
//         fontWeight: 'bold',
//         color: '#232b49'
//       }
//     }
//   }, {
//     min: 0,
//     title: {
//       text: '°C'
//     },
//     stackLabels: {
//       enabled: true,
//       style: {
//         fontWeight: 'bold',
//         color: '#232b49'
//       }
//     },
//     opposite: true
//   }],



      if (chartType != 'electricity_by_month_acyear_0_1') {
        console.log("it isn't electricity_by_month_acyear_0_1");

        c.update({  plotOptions: { column: { stacking: 'normal'}}});
      }

      if (chartType == 'line') {
        console.log('it is a line');
    //    c.update({ yAxis: [{ min: -1000,  title: { text: 'kWh' }}]});
      }

      Object.keys(seriesData).forEach(function (key) {
        console.log(seriesData[key].name);
        c.addSeries(seriesData[key]);
      });


      if (yAxisLabel.length) {
        console.log('we have a yAxisLabel ' + yAxisLabel);
        c.update({ yAxis: [{ title: { text: yAxisLabel }}]});
      }


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
          var chartDiv = $('div#' + this_chart.id);
          var chart = chartDiv.highcharts();
          chart.hideLoading();
       //   console.log(returnedData.new_charts[i]);
          var chartData = returnedData.charts[i];
          if (chartData !== undefined) { updateData(chart, chartData, chartDiv); }
      }
    }
  });
});