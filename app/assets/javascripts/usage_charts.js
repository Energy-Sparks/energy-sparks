"use strict";

$(document).ready(function() {

  //template used to explain the graphs
  var explainDailyTemplate = Handlebars.compile("Graphing {{supply}} consumption on {{first_date}}" +
    "{{#if whole_school}}{{#if second_date}} and {{second_date}}{{/if}}{{/if}}" +
    "{{#if first_meter}} for {{first_meter}}{{/if}}{{#unless whole_school}}{{/unless}}.");
  var explainWeeklyTemplate = Handlebars.compile("Graphing {{supply}} consumption for the week{{#if whole_school}}{{#if second_date}}s{{/if}}{{/if}} starting {{first_date}}" +
    "{{#if whole_school}}{{#if second_date}} and {{second_date}}{{/if}}{{/if}}" +
    "{{#if first_meter}} for {{first_meter}}{{/if}}.");

  //template for updating data availability
  var dataRangesTemplate = Handlebars.compile("{{supply }} data is available from {{min}} to {{max}}");

  //explain the current state of the form, to help explain what the graph is currently showing
  function explain() {
    var whole_school = $("input[type=radio][name=compare]:checked").val() == "whole-school";
    var first_meter = whole_school ? $("#whole-school #meter option:selected").text() : $("#within-school #meter option:selected").text();
    var first_date = whole_school ? $("#whole-school #first-date-picker").val() : $("#within-school #week-picker").val();
    var second_date = whole_school ? $("#whole-school #comparison-date-picker").val() : null;
    var data = {
      whole_school: whole_school,
      supply: $("#supply").val(),
      first_meter: first_meter,
      school: $("#school").html(),
      first_date: first_date,
      second_date: second_date
    };
    if ($("#period").val() == 'weekly') {
      $("#graph-explainer").html( explainWeeklyTemplate(data) );
    } else {
      $("#graph-explainer").html( explainDailyTemplate(data) );
    }
  }

  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(el) {
    explain();

    var supply = $("input[name=supply]:checked").val();
    var period = $("#period").val();
    var config = $("#configuration").data(supply);

    var compare = $('input[type=radio][name=compare]:checked').val();

    var chartType = config[period]
    var chartContainer = $('.usage-chart').first();

    var measurementField = $('input[name=measurement]:checked');
    var measurement = measurementField.val();

    chartContainer.data('chart-type', chartType);

    if(compare == 'whole-school'){
      var meter = $("#whole-school #meter").val();
      if(meter != 'all'){
        chartContainer.data('chart-mpan-mprn', meter);
      } else {
        chartContainer.data('chart-mpan-mprn', null);
      }
      chartContainer.data('chart-series-breakdown', 'none');
    } else {
      chartContainer.data('chart-mpan-mprn', null);
      chartContainer.data('chart-series-breakdown', 'meter');
    }

    chartContainer.data('chart-y-axis-units', measurement);
    chartContainer.data('chart-date-ranges', getDateRanges(compare));

    processAnalysisChart(chartContainer[0]);

  }

  function getDateRanges(compare){
    var dateRanges = [];
    if ($('#period').val() ==  'weekly') {
      var rangeExtension = 6;
    } else {
      var rangeExtension = 0;
    }

    if(compare == 'whole-school'){
      addRange($('input#first-date-picker').val(), dateRanges, rangeExtension);
      addRange($('input#comparison-date-picker').val(), dateRanges, rangeExtension);
    } else {
      addRange($('input#week-picker').val(), dateRanges, rangeExtension);
    }
    return dateRanges;
  }

  function addRange(dateString, ranges, rangeExtension){
    if (dateString){
      var date = moment(dateString, 'dddd, D MMMM YYYY');
      ranges.push({start: date.format('YYYY-MM-DD'), end: date.add(rangeExtension, 'days').format('YYYY-MM-DD')});
    }
  }

  //ensure that the user can only select those meters which are for the currently
  //selected supply
  function enableMeters(supply, force) {
    if (supply == "electricity") {
      $("option[data-supply-type='gas']").hide();
      $("option[data-supply-type='electricity']").show();
    } else {
      $("option[data-supply-type='gas']").show();
      $("option[data-supply-type='electricity']").hide();
    }
    if (force == true) {
      //when switching, reset state, so select all meters
      $(".meter-filter option[value='all']").prop("selected", true);
    }
  }

  //set the minimum and maximum selectable dates in the calendar pickers
  //the dates may vary based on the supply
  //if the currently selected date is greater (or lower) than the new min/max
  //then the dates are updated. otherwise the control sets an empty value
  function setMinMaxReadings(supply) {
    var config = $("#configuration").data(supply);
    var min = moment(config.earliest_reading);
    var max = moment( config.last_reading );

    //just in case date isn't valid
    if (min == null || max == null) {
      return;
    }

    $(".data-availability").html( dataRangesTemplate({
      supply: $("input[type=radio][name=supply]:checked").parent("label").text(),
      min: min.format('dddd, D MMMM YYYY'),
      max: max.format('dddd, D MMMM YYYY')
    }));

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
    var supply = $("input[name=supply]:checked").val();
    var compare = $('input[type=radio][name=compare]:checked').val();

    var minMaxReadings = setMinMaxReadings(supply);

    if ($('#period').val() ==  'weekly') {
      var defaultDate = minMaxReadings.max.clone().startOf('week');
      var defaultComparisonDate= defaultDate.clone().subtract(7, 'days');
    } else {
      var minMax = minMaxReadings;
      var defaultDate = minMaxReadings.max;
      var defaultComparisonDate = defaultDate.clone().subtract(1, 'days');
    }

    if ($('#datetimepicker1').length) {
      setUpDatePicker('#datetimepicker1', 'input#first-date-picker', minMaxReadings, defaultDate);
    }
    if ($('#datetimepicker2').length) {
      setUpDatePicker('#datetimepicker2', 'input#comparison-date-picker', minMaxReadings, defaultComparisonDate);
    }
    if ($('#datetimepicker3').length) {
      setUpDatePicker('#datetimepicker3', 'input#week-picker',  minMaxReadings, defaultDate);
    }
    setupCompare($('input[type=radio][name=compare]:checked').val(), false);
    enableMeters(supply, false);
    updateChart($('.charts').first());
    explain();
  }

  function setupCompare(compareType){
    if (compareType === "within-school") {
      $("#whole-school").hide();
      $("#within-school").show();
    } else {
      $("#within-school").hide();
      $("#whole-school").show();
    }
  }

  //TODO tidy up the code
  $(document).on('change', 'input[type=radio][name=supply]', function() {
    if (this.value == 'electricity') {
      $(".card").removeClass("gas-card");

      $("div.indicator-light").removeClass("gas-light");
      $("div.indicator-light").addClass("electricity-light");
      $("div.indicator-dark").removeClass("gas-dark");
      $("div.indicator-dark").addClass("electricity-dark");

      $("#gas-interpretation").hide();
      $("#electricity-interpretation").show();
      $(".card").addClass("electricity-card");
    } else {
      $("option[data-supply-type='electricity']").hide();
      $("option[data-supply-type='gas']").show();

      $(".card").removeClass("electricity-card");

      $("div.indicator-light").removeClass("electricity-light");
      $("div.indicator-light").addClass("gas-light");
      $("div.indicator-dark").removeClass("electricity-dark");
      $("div.indicator-dark").addClass("gas-dark");

      $("#electricity-interpretation").hide();
      $("#gas-interpretation").show();

      $(".card").addClass("gas-card");
    }
    //after we've changed supply we need to ensure min/max dates are
    //correct, and that only the correct meters are enabled
    enableMeters(this.value, true);
    setMinMaxReadings(this.value);
    updateChart(this);
  });

  $(document).on('change', 'input[type=radio][name=compare]', function() {
    setupCompare(this.value);
    explain();
    updateChart(this);
  });

  $(document).on('change', 'input[type=radio][name=measurement]', function() {
    explain();
    updateChart(this);
  });

  $(document).on('change', '.meter-filter', function() {
    updateChart(this);
  });

});
