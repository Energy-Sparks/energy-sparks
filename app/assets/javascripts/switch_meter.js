$(document).on("turbolinks:load", function() {

    var initialised = false;
    var explainTemplate = Handlebars.compile("Graphing {{supply}} consumption on {{first_date}} " +
        "{{#if whole_school}}{{#if second_date}}and {{second_date}}{{/if}}{{/if}}" +
        " for {{first_meter}}{{#unless whole_school}}{{#if second_meter}} and {{second_meter}}{{/if}}{{/unless}}.");
    var dataRangesTemplate = Handlebars.compile("{{supply }} data is available from {{min}} to {{max}}");

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

    function datetoCdate(date) {
        parts = date.split("-");
        if (parts.length < 3) {
            return null;
        }
        return $.calendars.newDate(parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]))
    }

    $(".first-date-picker").each( function() {
        $(this).calendarsPicker({
            dateFormat: 'DD, d MM yyyy',
            defaultDate: datetoCdate( $("#first-date").val() ),
            selectDefaultDate: true,
            onSelect: function(dates) {
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
                $("#to-date").val(dates);
                if (initialised) updateChart(this);
            }
        });
    });

    //only run this on charts pages
    if ($(".charts").length > 0) {
        supply = $("input[name=supplyType]:checked").val();
        setMinMaxDates(supply);
        enableMeters(supply, false);
        explain();
        initialised = true;
    }

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

    //TODO tidy up the code
    $(document).on('change', 'input[type=radio][name=supplyType]', function() {
        initialised = false;
        if (this.value == 'electricity') {
            $(".card").removeClass("gas-card");

            $("div.indicator-light").removeClass("gas-light");
            $("div.indicator-light").addClass("electricity-light");
            $("div.indicator-dark").removeClass("gas-dark");
            $("div.indicator-dark").addClass("electricity-dark");

            $(".card").addClass("electricity-card");
        } else {
            $("option[data-supply-type='electricity']").hide();
            $("option[data-supply-type='gas']").show();

            $(".card").removeClass("electricity-card");

            $("div.indicator-light").removeClass("electricity-light");
            $("div.indicator-light").addClass("gas-light");
            $("div.indicator-dark").removeClass("electricity-dark");
            $("div.indicator-dark").addClass("gas-dark");

            $(".card").addClass("gas-card");
        }
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
        } else {
            $("#comparison").val("whole-school");
            $("#within-school").hide();
            $("#whole-school").show();
        }
        $("#first-meter").val($("#within-school #meter").val());
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


