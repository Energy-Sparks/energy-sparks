"use strict";

$(document).ready(function() {
  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(chartDiv) {
    var chartContainer = $(chartDiv).find('.usage-chart').first();
    var chartConfig = chartContainer.data('chart-config');

    var meter = $(chartDiv).find("select[name='meter']").val();
    if (meter) {
      if (meter == 'all') {
        chartConfig.mpan_mprn = undefined;
        chartConfig.sub_meter = undefined;
      } else {
        var definitions = meter.split('>');
        chartConfig.mpan_mprn = definitions[0];
        // will either be name of a sub meter type or undefined
        chartConfig.sub_meter = definitions[1];
      }
    }

    const chart_type = $(chartDiv).find("select[name='chart_selection_chart_type']").val();
    if (chart_type) {
      chartConfig.type = chart_type;
    }

    const school_id = $(chartDiv).find("select[name='chart_selection_school_id']").val();
    if (school_id) {
      chartConfig.jsonUrl = `/schools/${school_id}/chart.json`;
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

  function setSelectorState(fuel_type, chartDiv) {
    const chartSelector = chartDiv.find("select[name='chart_selection_chart_type']").first();
    const chartOptions = chartSelector.find("option");

    var firstOption = null;
    $(chartOptions).each(function(index, option) {
      option_fuel_type = $(option).data('fuel-type');
      if (option_fuel_type == fuel_type) {
        if (firstOption == null) {
          firstOption = $(option).val();
        }
        option.disabled = false;
        option.hidden = false;
      } else {
        option.disabled = true;
        option.hidden = true;
      }
    });

    chartSelector.val(firstOption);
    chartSelector.select2({theme: 'bootstrap'});
  }

  function initChart(chartDiv) {

    var supply = $(chartDiv).find("input[name='supply']").val();
    var period = $(chartDiv).find("input[name='period']").val();

    var minMaxReadings = setMinMaxReadings(chartDiv);

    const params = new URLSearchParams(window.location.search);
    const compare_to = params.get('compare_to');
    const start_date = params.get('date');

    if ( period == 'weekly') {
      var defaultDate = compare_to ? moment(compare_to).startOf('week') : minMaxReadings.max.clone().startOf('week');
      var defaultComparisonDate = start_date ? moment(start_date).startOf('week') : defaultDate.clone().subtract(7, 'days');
    } else {
      var minMax = minMaxReadings;
      var defaultDate = compare_to ? moment(compare_to) : minMaxReadings.max;
      var defaultComparisonDate = start_date ? moment(start_date) : defaultDate.clone().subtract(1, 'days');
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
    setSelectorState('electricity', $(chartDiv)); // FIXME select first option in fuel type options
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

  $(document).on('change', "select[name='chart_selection_school_id'], select[name='chart_selection_chart_type']", function() {
    const chartDiv = $(this).closest('.charts');
    updateChart(chartDiv);
  });

  $(document).on('change', "input[name='chart_selection_fuel_type']", function() {
    const fuel_type = $(this).data('fuel-type');
    const chartDiv = $(this).closest('.charts');
    setSelectorState(fuel_type, chartDiv);
    updateChart(chartDiv);
  });

});
