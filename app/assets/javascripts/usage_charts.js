"use strict";

$(document).ready(function() {
  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(chartDiv) {
    const chartContainer = $(chartDiv).find('.usage-chart').first();
    var chartConfig = chartContainer.data('chart-config');

    // For SelectableSchoolChartsComponent
    updateSchoolSelection(chartDiv, chartConfig)
    updateChartTitleAndFootnoteFromSelections(chartDiv, chartConfig);

    // For Meter Specific Charts
    updateMeterSpecificChartState(chartDiv, chartConfig);

    // For pupil and recent usage analysis charts that use
    // shared/usage_controls
    updateMeterSelection(chartDiv, chartConfig);
    chartConfig.date_ranges = getDateRanges(chartDiv);

    const seriesBreakdown = chartDiv.querySelector("input[name='series_breakdown']");
    if (seriesBreakdown && seriesBreakdown.value) {
      chartConfig.series_breakdown = seriesBreakdown.value;
    }

    processAnalysisChart(chartContainer[0], chartConfig);
  }

  function updateMeterSelection(chartDiv, chartConfig) {
    const meterSelect = chartDiv.querySelector("select[name='meter']");
    const meter = meterSelect ? meterSelect.value : null;
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
  }

  // SelectableSchoolChartsComponent
  // Set alternate URL for loading chart json based on selected school
  function updateSchoolSelection(chartDiv, chartConfig) {
    const schoolSelector = chartDiv.querySelector("select[name='chart-selection-school-id']");
    if (schoolSelector && schoolSelector.value) {
      chartConfig.jsonUrl = `/schools/${schoolSelector.value}/chart.json`;
    }
  }

  // SelectableSchoolChartsComponent
  // Update chart title, subtitle and footer link based on combination of
  // selected chart and school.
  //
  // Relies on both select boxes having option elements containing certain data attributes.
  function updateChartTitleAndFootnoteFromSelections(chartDiv, chartConfig) {
    const chartSelector = chartDiv.querySelector("select[name='chart-selection-chart-type']");
    if (chartSelector && chartSelector.value) {
      chartConfig.type = chartSelector.value;
      const selectedChart = chartSelector.options[chartSelector.selectedIndex];
      const chartTitle = chartDiv.querySelector('.chart-title');
      if (chartTitle) {
        const title = selectedChart.getAttribute('data-title')
        if (title) {
          chartTitle.textContent = title;
        }
      }
      const schoolSelector = chartDiv.querySelector("select[name='chart-selection-school-id']");
      const chartSubTitle = chartDiv.querySelector('.chart-subtitle');
      if (chartSubTitle && schoolSelector) {
        const selectedSchool = schoolSelector.options[schoolSelector.selectedIndex];
        const subtitle = selectedChart.getAttribute('data-subtitle');
        if (subtitle) {
          const template = Handlebars.compile(subtitle);
          chartSubTitle.innerHTML = template({ ...selectedSchool.dataset });
        } else {
          chartSubTitle.innerHTML = '';
        }
      }
      const footerLink = chartDiv.querySelector('.chart-selection-analysis-link')
      if (footerLink && schoolSelector) {
        const selectedSchool = schoolSelector.options[schoolSelector.selectedIndex];
        const slug = encodeURIComponent(selectedSchool.value);
        const advice_page = encodeURIComponent(selectedChart.getAttribute('data-advice-page'));
        footerLink.href = `/schools/${slug}/advice/${advice_page}`;
      }
    }
  }

  // MeterSelectionChartComponent
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

  // For pupil and recent usage analysis charts that use
  // shared/usage_controls
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
      updateChart(this.closest('.charts'));
    });
  }

  // Updates school and chart type selections to disable and hide their options if their
  // data-fuel-type attribute doesn't match the provided fuel type. Allows filtering based on
  // fuel type on the client side, rather than requiring a reload to refresh list of charts and schools
  function setSelectorState(fuel_type, chartDiv) {
    const selectors = [
      "select[name='chart-selection-chart-type']",
      "select[name='chart-selection-school-id']"
    ];

    selectors.forEach(selector => {
      const chartSelector = chartDiv.querySelector(selector);
      if (chartSelector === null || chartSelector.length === 0) return;

      const chartOptions = chartSelector.querySelectorAll("option");
      let firstOption = null;

      chartOptions.forEach(option => {
        const optionFuelType = option.getAttribute("data-fuel-type") || "";

        if (optionFuelType.includes(fuel_type)) {
          if (firstOption === null) {
            firstOption = option.value;
          }
          option.disabled = false;
          option.hidden = false;
        } else {
          option.disabled = true;
          option.hidden = true;
        }
      });

      chartSelector.value = firstOption;
      $(chartSelector).select2({ theme: 'bootstrap' }); //requires jquery
    });
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

    const selectedFuelType = document.querySelector("input[name='chart-selection-fuel_type']:checked");
    if (selectedFuelType) {
      setSelectorState(selectedFuelType.getAttribute('data-fuel-type'), chartDiv);
    }
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
    const chartDiv = this.closest('.charts');
    updateChart(chartDiv);
  });

  $(document).on('change', "select[name='chart-selection-school-id'], select[name='chart-selection-chart-type']", function() {
    const chartDiv = this.closest('.charts');
    updateChart(chartDiv);
  });

  $(document).on('change', "input[name='chart-selection-fuel-type']", function() {
    const fuel_type = this.getAttribute("data-fuel-type");
    const chartDiv = this.closest('.charts');
    setSelectorState(fuel_type, chartDiv);
    updateChart(chartDiv);
  });

});
