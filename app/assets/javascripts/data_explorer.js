
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
    var first_date = whole_school ? $("#whole-school #first-date-picker").val() : $("#within-school #first-date-picker").val()
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

  //create a Cdate object used by the calendar picker
  //have to use these objects when setting min/max dates when using a custom data format
  function datetoCdate(date) {
    if (date.length) {
    var parts = date.split("-");
    if (parts.length > 2) {
      $.calendars.newDate(parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]));
    }
    }
  }

  //called by event handlers that need to update the graph
  //they should have already made any changes to the form we're using, so this just updates
  //the explanation and then triggers the data load
  function updateChart(el) {
    explain();
    if ($("#supply").val() == "electricity") {
      colors = ["#3bc0f0","#232b49"]
    } else {
      colors = ["#ffac21", "#ff4500"]
    }
    chart = Chartkick.charts["chart"];
    options = chart.options;
    options["colors"] = colors;
    options["ytitle"] = $('input[name=measurement]:checked').val();

    current_source = chart.getDataSource();
    new_source = current_source.split("?")[0] + "?" + $(el.form).serialize();
    console.log(new_source);
    chart.updateData(new_source, options);
    if (chart.getChartObject()) {
      chart.getChartObject().showLoading();
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
    var min = datetoCdate( $("#" + supply + "-start").attr("data-date") );
    var max = datetoCdate( $("#" + supply + "-end").attr("data-date") );

    //just in case date isn't valid
    if (min == null || max == null) {
      return;
    }

    $("#data-availability").html( dataRangesTemplate({
      supply: $("input[type=radio][name=supplyType]:checked").parent("label").text(),
      min: min.formatDate('DD, d MM yyyy'),
      max: max.formatDate('DD, d MM yyyy')
    }));

    $(".date-picker").each(function() {
      selected_date = $(this).calendarsPicker("getDate");
      if (selected_date.length > 0 && selected_date > max) {
        $(this).calendarsPicker("setDate", max);
      }
      if (selected_date.length > 0 && selected_date < min) {
        $(this).calendarsPicker("setDate", min);
      }
      $(this).calendarsPicker("option", {
        minDate: min,
        maxDate: max
      });
    });
  }

  /**
   * Highlight entire week when selecting a date
   * Select the first day of the week
   * Display a status bar to explain picking operation
   * Adapted from: http://keith-wood.name/datepick.HTML#extend
   *
   @param {jQuery} picker The completed datepicker division.
   @param {BaseCalendar} calendar The calendar implementation.
   @param {object} inst The current instance settings.
   */
  function selectWeek(picker, calendar, inst) {
    //HIGHLIGHT WEEK
    var renderer = inst.options.renderer;
    picker.find(renderer.daySelector + ' a, ' + renderer.daySelector + ' span').hover(function () {
        $(this).parents('tr').find(renderer.daySelector + ' *').addClass(renderer.highlightedClass);
      },
      function () {
        $(this).parents('tr').find(renderer.daySelector + ' *').removeClass(renderer.highlightedClass);
      });

    //SHOW A STATUS MESSAGE
    var isTR = (inst.options.renderer.selectedClass === 'ui-state-active');
    //for dates that can't be selected
    var defaultStatus = "No data for this week";
    var status = $('<div class="' + (!isTR ? 'calendars-status' :
        'ui-datepicker-status ui-widget-header ui-helper-clearfix ui-corner-all') + '">' +
      defaultStatus + '</div>').insertAfter(picker.find('.calendars-month-row:last,.ui-datepicker-row-break:last'));
    picker.find('*[title]').each(function () {
      //if the day has a title its selectable
      if ($(this).attr('title')) {
        var title = "Select this week";
      }
      $(this).removeAttr('title').hover(
        function () {
          status.text(title || defaultStatus);
        },
        function () {
          status.text(defaultStatus);
        });
    });

    //SELECT START OF WEEK
    //There's an issue where if user selects very first week of the data
    var target = $(this);
    picker.find('td a').each(function () {
      $(this).click(function () {
        var selected_date = target.calendarsPicker('retrieveDate', this);
        var start_of_week = selected_date.add(0 - selected_date.dayOfWeek(), "d");
        var dates = [start_of_week];
        target.calendarsPicker('setDate', dates).calendarsPicker('hide');
        target.blur();
      }).replaceAll(this);
    });
  }

  function datePickerConfig(selector) {
    var defaultDate = datetoCdate( $(selector).val() );
    var config = {
      dateFormat: 'DD, d MM yyyy',
      selectDefaultDate: true,
      onSelect: function(dates) {
        $(selector).val(dates);
        if (initialised) updateChart(this);
      }
    }
    if (defaultDate !== undefined && defaultDate.length) {
      config.defaultDate = defaultDate;
    }

    if ($("#daily-usage").length > 0) {
      config["onShow"] = selectWeek;
    }
    return config
  }

  //Initialise this page
  if ($(".charts").length > 0) {
    supply = $("input[name=supplyType]:checked").val();

    $(".first-date-picker").each( function() {
      $(this).calendarsPicker(datePickerConfig("#first-date"));
    });

    $(".to-date-picker").each( function() {
      $(this).calendarsPicker(datePickerConfig("#to-date"));
    });

    setMinMaxDates(supply);
    enableMeters(supply, false);
    explain();
    initialised = true;
  }

  //TODO tidy up the code
  $(document).on('change', 'input[type=radio][name=supplyType]', function() {
    initialised = false;
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
      $("#first-date").val($("#within-school #first-date-picker").val());

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

  $(document).on('change', 'input[type=radio][name=compare]', function() {
    if (this.value === "within-school") {
      $("#comparison").val("within-school");
      $("#whole-school").hide();
      $("#within-school").show();
      $("#first-meter").val($("#within-school #meter").val());
      $("#first-date").val($("#within-school #first-date-picker").val());

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
    // if (this.value === "within-school") {
    //   $("#comparison").val("within-school");
    //   $("#whole-school").hide();
    //   $("#within-school").show();
    //   $("#first-meter").val($("#within-school #meter").val());
    //   $("#first-date").val($("#within-school #first-date-picker").val());

    // } else {
    //   $("#comparison").val("whole-school");
    //   $("#within-school").hide();
    //   $("#whole-school").show();
    //   $("#first-meter").val($("#whole-school #meter").val());
    //   $("#first-date").val($("#whole-school #first-date-picker").val());

    // }
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


