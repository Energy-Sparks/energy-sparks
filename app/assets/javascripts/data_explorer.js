"use strict";

$(document).ready(function() {
  //set to true after we've initialised the page
  var initialised = false;

  //template used to explain the graphs
  var explainHourlyTemplate = Handlebars.compile("Graphing {{supply}} consumption on {{first_date}}" +
    "{{#if whole_school}}{{#if second_date}} and {{second_date}}{{/if}}{{/if}}" +
    " for {{first_meter}}{{#unless whole_school}}{{#if second_meter}} and {{second_meter}}{{/if}}{{/unless}}.");
  var explainDailyTemplate = Handlebars.compile("Graphing {{supply}} consumption for the week{{#if whole_school}}{{#if second_date}}s{{/if}}{{/if}} starting {{first_date}}" +
    "{{#if whole_school}}{{#if second_date}} and {{second_date}}{{/if}}{{/if}}" +
    " for {{first_meter}}{{#unless whole_school}}{{#if second_meter}} and {{second_meter}}{{/if}}{{/unless}}.");

  //template for updating data availability
  var dataRangesTemplate = Handlebars.compile("{{supply }} data is available from {{min}} to {{max}}");

  //explain the current state of the form, to help explain what the graph is currently showing
  function explain() {
    var whole_school = $("input[type=radio][name=compare]:checked").val() == "whole-school";
    var first_meter = whole_school ? $("#whole-school #meter option:selected").text() : $("#within-school #meter option:selected").text();
    var first_date = whole_school ? $("#whole-school #first-date-picker").val() : $("#within-school #first-date-picker").val();
    var data = {
      whole_school: whole_school,
      supply: $("#supply").val(),
      first_meter: first_meter,
      second_meter: $("#second_meter option:selected").val() == "" ? null : $("#second_meter option:selected").text(),
      school: $("#school").html(),
      homepage: $("#school").attr("href"),
      first_date: first_date,
      second_date: $("#to-date-picker").val() == "" ? null : $("#to-date-picker").val()
    };
    if ($("#daily-usage").length > 0) {
      $("#graph-explainer").html( explainDailyTemplate(data) );
    } else {
      $("#graph-explainer").html( explainHourlyTemplate(data) );
    }
  }

  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(el) {
    explain();
    // default gas
    var colors = ["#ffac21", "#ff4500"];
    if ($("#supply").val() == "electricity") {
      colors = ["#3bc0f0","#232b49"];
    }
    var chart = Chartkick.charts.chart;
    var options = chart.options;
    options.colors = colors;
    var measurementField = $('input[name=measurement]:checked');
    var measurement = measurementField.val();

    if (measurement) {
      options.ytitle = measurementField.parent()[0].innerText;

      var updatedURL = updateQueryStringParameter(location.href, 'measurement', measurement);

      var stateObj = { measurement: measurement };
      history.pushState(stateObj, measurement, updatedURL);
    }

    var currentSource = chart.getDataSource();
    var newSource = currentSource.split("?")[0] + "?" + $('form#chart-filter').serialize();

    chart.updateData(newSource, options);
    if (chart.getChartObject()) {
      chart.getChartObject().showLoading();
    }
  }

  // From https://stackoverflow.com/questions/5999118/how-can-i-add-or-update-a-query-string-parameter
  function updateQueryStringParameter(uri, key, value) {
    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
    if (uri.match(re)) {
      return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
    else {
      return uri + separator + key + "=" + value;
    }
  }

  //ensure that the user can only select those meters which are for the currently
  //selected supply
  function enableMeters(supply, force) {
    if (supply == "electricity") {
      $("option[data-supply-type='gas']").hide();
      $("option[data-supply-type='electricity']").show();

    } else {
      $("option[data-supply-type='electricity']").hide();
      $("option[data-supply-type='gas']").show();
    }
    if (force == true) {
      //when switching, reset state, so select all meters and no second selection
      $(".meter-filter option[value='all']").prop("selected", true);
      $("#second_meter option:first").prop("selected", true);

      $("#first-meter").val($("#meter").val());
    }
  }

  //set the minimum and maximum selectable dates in the calendar pickers
  //the dates may vary based on the supply
  //if the currently selected date is greater (or lower) than the new min/max
  //then the dates are updated. otherwise the control sets an empty value
  function setMinMaxDates(supply) {
    var min = moment( $("#" + supply + "-start").attr("data-date") );
    var max = moment( $("#" + supply + "-end").attr("data-date") );

    //just in case date isn't valid
    if (min == null || max == null) {
      return;
    }

    $("#data-availability").html( dataRangesTemplate({
      supply: $("input[type=radio][name=supplyType]:checked").parent("label").text(),
      min: min.format('dddd, Do MMMM YYYY'),
      max: max.format('dddd, Do MMMM YYYY')
    }));

    return { min: min, max: max };
  }

  function setUpDatePicker(divId, inputId, hiddenInputId, maxMin) {
    $(divId).datetimepicker({
        format: 'dddd, Do MMMM YYYY',
        minDate: maxMin.min,
        maxDate: maxMin.max,
        allowInputToggle: true,
        debug: true
    });

    $(divId).on('change.datetimepicker', function() {
      var datePickerValue = $(inputId).val();
      if ($("#daily-usage").length > 0) {
        datePickerValue = moment(datePickerValue, 'dddd, Do MMMM YYYY').startOf('week').format('dddd, Do MMMM YYYY');
        $(inputId).val(datePickerValue);
      }
      $(hiddenInputId).val(datePickerValue);

      updateChart(this);
    });

    // Close date picker on click outside
    $(document).click(function(e) {
      if (!$(e.target).parents(divId).length) {
        $(divId).datetimepicker('hide');
      }
    });
  }

  //Initialise this page
  if ($(".charts").length > 0) {
    var supply = $("input[name=supplyType]:checked").val();
    var maxMin = setMinMaxDates(supply);

    if ($('#datetimepicker1').length) {
      setUpDatePicker('#datetimepicker1', 'input#first-date-picker', '#first-date', maxMin);
    }
    if ($('#datetimepicker2').length) {
      setUpDatePicker('#datetimepicker2', 'input#to-date-picker', '#to-date', maxMin);
    }
    if ($('#datetimepicker3').length) {
      setUpDatePicker('#datetimepicker3', 'input#week-picker', '#first-date', maxMin);
    }
    enableMeters(supply, false);
    explain();
    initialised = true;
  }

  //TODO tidy up the code
  $(document).on('change', 'input[type=radio][name=supplyType]', function() {
    var initialised = false;
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
    $("#supply").val(this.value);
    enableMeters(this.value, true);
    setMinMaxDates(this.value);
    updateChart(this);
    initialised = true;
  });

  $(document).on('change', 'input[type=radio][name=compare]', function() {
    if (this.value === "within-school") {
      $("#comparison").val("within-school");
      $("#whole-school").hide();
      $("#within-school").show();
      $("#first-meter").val($("#within-school #meter").val());
      $("#first-date").val($("#within-school #week-picker").val());
    } else {
      $("#comparison").val("whole-school");
      $("#within-school").hide();
      $("#whole-school").show();
      $("#first-meter").val($("#whole-school #meter").val());
      $("#first-date").val($("#whole-school #first-date-picker").val());

    }
    explain();
    updateChart(this);
  });

  $(document).on('change', 'input[type=radio][name=measurement]', function() {
    explain();
    updateChart(this);
  });

  $(document).on('change', '.meter-filter', function() {
    $("#first-meter").val($(this).val());
    updateChart(this);
  });

  $(document).on('change', '.second-meter-filter', function() {
    $("#second-meter").val($(this).val());
    updateChart(this);
  });
});
