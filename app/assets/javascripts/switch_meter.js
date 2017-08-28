$(document).on("turbolinks:load", function() {

    //set to true after we've initialised the page
    var initialised = false;

    //template used to explain the graphs
    var explainTemplate = Handlebars.compile("Graphing {{supply}} consumption on {{first_date}} " +
        "{{#if whole_school}}{{#if second_date}}and {{second_date}}{{/if}}{{/if}}" +
        " for {{first_meter}}{{#unless whole_school}}{{#if second_meter}} and {{second_meter}}{{/if}}{{/unless}}.");
    //template for updating data availability
    var dataRangesTemplate = Handlebars.compile("{{supply }} data is available from {{min}} to {{max}}");

    //explain the current state of the form, to help explain what the graph is currently showing
    function explain() {
        whole_school = $("input[type=radio][name=compare]:checked").val() == "whole-school";
        first_meter = whole_school ? $("#whole-school #meter option:selected").text() : $("#within-school #meter option:selected").text();
        first_date = whole_school ? $("#whole-school #first-date-picker").val() : $("#within-school #first-date-picker").val()
        data = {
            whole_school: whole_school,
            supply: $("#supply").val(),
            first_meter: first_meter,
            second_meter: $("#second_meter option:selected").val() == "" ? null : $("#second_meter option:selected").text(),
            school: $("#school").html(),
            homepage: $("#school").attr("href"),
            first_date: first_date,
            second_date: $("#to-date-picker").val() == "" ? null : $("#to-date-picker").val()
        };
        $("#graph-explainer").html( explainTemplate(data) );
    }

    //create a Cdate object used by the calendar picker
    //have to use these objects when setting min/max dates when using a custom data format
    function datetoCdate(date) {
        parts = date.split("-");
        if (parts.length < 3) {
            return null;
        }
        return $.calendars.newDate(parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]))
    }

    //called by event handlers that need to update the graph
    //they should have already made any changes to the form we're using, so this just updates
    //the explanation and then triggers the data load
    function updateChart(el) {
        explain();
        chart = Chartkick.charts["chart"];
        current_source = chart.getDataSource();
        new_source = current_source.split("?")[0] + "?" + $(el.form).serialize();
        chart.updateData(new_source);
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
        min = datetoCdate( $("#" + supply + "-start").attr("data-date") );
        max = datetoCdate( $("#" + supply + "-end").attr("data-date") );

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

    //Initialise this page
    if ($(".charts").length > 0) {
        console.log("init function");
        supply = $("input[name=supplyType]:checked").val();

        $(".first-date-picker").each( function() {
            $(this).calendarsPicker({
                dateFormat: 'DD, d MM yyyy',
                defaultDate: datetoCdate( $("#first-date").val() ),
                selectDefaultDate: true,
                onSelect: function(dates) {
                    console.log("select first-date");
                    $("#first-date").val(dates);
                    if (initialised) updateChart(this);
                }
            });
        });

        $(".to-date-picker").each( function() {
            $(this).calendarsPicker({
                dateFormat: 'DD, d MM yyyy',
                defaultDate: datetoCdate( $("#to-date").val() ),
                selectDefaultDate: true,
                onSelect: function(dates) {
                    console.log("select second-date");
                    $("#to-date").val(dates);
                    if (initialised) updateChart(this);
                }
            });
        });

        setMinMaxDates(supply);
        enableMeters(supply, false);
        explain();
        console.log("done");
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

    $(document).on('change', '.meter-filter', function() {
        $("#first-meter").val($(this).val());
        updateChart(this);
    });

    $(document).on('change', '.second-meter-filter', function() {
        $("#second-meter").val($(this).val());
        updateChart(this);
    });

});


