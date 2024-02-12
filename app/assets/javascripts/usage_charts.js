"use strict";

$(document).ready(function() {
  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(chartDiv) {

    var chartContainer = $(chartDiv).find('.usage-chart').first();
    var chartConfig = chartContainer.data('chart-config');

    var meter = $(chartDiv).find("select[name='meter']").val();
    if (meter && meter != 'all') {
      chartConfig.mpan_mprn = meter;
    }

    updateMeterSpecificChartState(chartDiv, chartConfig);

    var seriesBreakdown = $(chartDiv).find("input[name='series_breakdown']").val();
    if (seriesBreakdown) {
      chartConfig.series_breakdown = seriesBreakdown;
    }

    chartConfig.date_ranges = getDateRanges(chartDiv);
    processAnalysisChart(chartContainer[0], chartConfig);
  }

  //used for the per-meter chart switching behaviour on the advice pages
  function updateMeterSpecificChartState(chartDiv, chartConfig) {
    var descriptions = $(chartDiv).find("input[name='descriptions']").data('descriptions');
    var description = $(chartDiv).find('.chart-subtitle');
    var meter = chartConfig.mpan_mprn;
    if(descriptions && description && meter && descriptions[meter]) {
      chartConfig.transformations = [];
      description.html(descriptions[meter]);
    }
  }

  function getDateRanges(chartDiv){
    var dateRanges = [];

    var period = $(chartDiv).find("input[name='period']").val();
    if (period == 'weekly') {
      var rangeExtension = 6;
    } else {
      var rangeExtension = 0;
    }

    // maintain this order of range addition to match input order to chart order
    var secondDate = $(chartDiv).find("input[name='second-date-picker']").val();
    if(secondDate){
      addRange(secondDate, dateRanges, rangeExtension);
    }

    var firstDate = $(chartDiv).find("input[name='first-date-picker']").val();
    addRange(firstDate, dateRanges, rangeExtension);

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
  function setMinMaxReadings(chartDiv) {
    var config = $(chartDiv).find("input[name='configuration']").data('configuration');
    var min = moment(config.earliest_reading);
    var max = moment( config.last_reading );

    //just in case date isn't valid
    if (min == null || max == null) {
      return;
    }

    return { min: min, max: max };
  }

  function setUpDatePicker(divId, inputId, maxMin, defaultDate, period) {
    $(inputId).val(defaultDate.format('dddd, D MMMM YYYY'));
    $(divId).datetimepicker({
      format: 'dddd, D MMMM YYYY',
      minDate: maxMin.min,
      maxDate: maxMin.max,
      useCurrent: false, // without this set, maxDate takes priority over the set value
      allowInputToggle: true,
      locale: moment.locale()
    });

    $(divId).on('change.datetimepicker', function() {
      var datePickerValue = $(inputId).val();
      if (period == 'weekly') {
        datePickerValue = moment(datePickerValue, 'dddd, D MMMM YYYY').startOf('week').format('dddd, D MMMM YYYY');
        $(inputId).val(datePickerValue);
      }
      logEvent('datetimepicker', '');
      updateChart($(this).closest('.charts'));
    });
  }

  function initChart(chartDiv) {

    var supply = $(chartDiv).find("input[name='supply']").val();
    var period = $(chartDiv).find("input[name='period']").val();

    var minMaxReadings = setMinMaxReadings(chartDiv);

    if ( period == 'weekly') {
      var defaultDate = minMaxReadings.max.clone().startOf('week');
      var defaultComparisonDate = defaultDate.clone().subtract(7, 'days');
    } else {
      var minMax = minMaxReadings;
      var defaultDate = minMaxReadings.max;
      var defaultComparisonDate = defaultDate.clone().subtract(1, 'days');
    }

    var firstDataPicker = $(chartDiv).find("input[name='first-date-picker']");
    var firstDataPickerWrapper = $(firstDataPicker).closest('.date');
    if (firstDataPickerWrapper.length) {
      setUpDatePicker(firstDataPickerWrapper, firstDataPicker, minMaxReadings, defaultComparisonDate, period);
    }

    var secondDataPicker = $(chartDiv).find("input[name='second-date-picker']");
    var secondDataPickerWrapper = $(secondDataPicker).closest('.date');
    if (secondDataPickerWrapper.length) {
      setUpDatePicker(secondDataPickerWrapper, secondDataPicker, minMaxReadings, defaultDate, period);
    }

    var chartContainer = $(chartDiv).find('.usage-chart').first();
    var chartConfig = chartContainer.data('chart-config');
    setupAxisControls(chartContainer[0], chartConfig);
    setupAnalysisControls(chartContainer[0], chartConfig);

    updateChart(chartDiv);
  }

  //Initialise this page
  if ($(".charts").length > 0) {
    $(".charts").each(function(index, chartDiv) {
      initChart(chartDiv);
    });
  }

  $(document).on('change', "select[name='meter']", function() {
    logEvent('meter', '');
    updateChart($(this).closest('.charts'));
  });

});
