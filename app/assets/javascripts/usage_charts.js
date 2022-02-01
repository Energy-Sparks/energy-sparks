"use strict";

$(document).ready(function() {

  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(el) {

    var supply = $("#supply").val();
    var period = $("#period").val();
    var config = $("#configuration").data('configuration');

    var chartContainer = $('.usage-chart').first();
    var chartConfig = chartContainer.data('chart-config');

//    var measurement = $('#measurement').val();
    var meter = $("#meter").val();

    if (meter) {
      chartConfig.series_breakdown = 'none';
      if (meter != 'all') {
        chartConfig.mpan_mprn = meter;
      } else {
        chartConfig.mpan_mprn = null;
      }
    } else {
      chartConfig.mpan_mprn = null;
      chartConfig.series_breakdown = 'meter';
    }

//    chartConfig.y_axis_units = measurement;
    chartConfig.date_ranges = getDateRanges();

    setupAxisControls(chartContainer[0], chartConfig);
    processAnalysisChart(chartContainer[0], chartConfig);
  }

  function getDateRanges(){
    var dateRanges = [];

    if ($('#period').val() ==  'weekly') {
      var rangeExtension = 6;
    } else {
      var rangeExtension = 0;
    }

    // maintain this order of range addition to match input order to chart order
    if($('input#second-date-picker').val()){
      addRange($('input#second-date-picker').val(), dateRanges, rangeExtension);
    }
    addRange($('input#first-date-picker').val(), dateRanges, rangeExtension);

    return dateRanges;
  }

  function addRange(dateString, ranges, rangeExtension){
    if (dateString){
      var date = moment(dateString, 'dddd, D MMMM YYYY');
      ranges.push({start: date.format('YYYY-MM-DD'), end: date.add(rangeExtension, 'days').format('YYYY-MM-DD')});
    }
  }

  //set the minimum and maximum selectable dates in the calendar pickers
  //the dates may vary based on the supply
  //if the currently selected date is greater (or lower) than the new min/max
  //then the dates are updated. otherwise the control sets an empty value
  function setMinMaxReadings() {
    var config = $("#configuration").data('configuration');
    var min = moment(config.earliest_reading);
    var max = moment( config.last_reading );

    //just in case date isn't valid
    if (min == null || max == null) {
      return;
    }

    return { min: min, max: max };
  }

  function setUpDatePicker(divId, inputId, maxMin, defaultDate) {
    $(inputId).val(defaultDate.format('dddd, D MMMM YYYY'));
    $(divId).datetimepicker({
      format: 'dddd, D MMMM YYYY',
      minDate: maxMin.min,
      maxDate: maxMin.max,
      useCurrent: false, // without this set, maxDate takes priority over the set value
      allowInputToggle: true,
    });

    $(divId).on('change.datetimepicker', function() {
      var datePickerValue = $(inputId).val();
      if ($("#period").val() == 'weekly') {
        datePickerValue = moment(datePickerValue, 'dddd, D MMMM YYYY').startOf('week').format('dddd, D MMMM YYYY');
        $(inputId).val(datePickerValue);
      }
      updateChart(this);
    });
  }

  //Initialise this page
  if ($(".charts").length > 0) {
    var supply = $("#supply").val();
    var period = $('#period').val();

    var minMaxReadings = setMinMaxReadings();

    if ( period == 'weekly') {
      var defaultDate = minMaxReadings.max.clone().startOf('week');
      var defaultComparisonDate = defaultDate.clone().subtract(7, 'days');
    } else {
      var minMax = minMaxReadings;
      var defaultDate = minMaxReadings.max;
      var defaultComparisonDate = defaultDate.clone().subtract(1, 'days');
    }

    if ($('#datetimepicker1').length) {
      setUpDatePicker('#datetimepicker1', 'input#first-date-picker', minMaxReadings, defaultDate);
    }
    if ($('#datetimepicker2').length) {
      setUpDatePicker('#datetimepicker2', 'input#second-date-picker', minMaxReadings, defaultComparisonDate);
    }
    updateChart($('.charts').first());
  }

  $(document).on('change', '#meter', function() {
    updateChart(this);
  });

});
