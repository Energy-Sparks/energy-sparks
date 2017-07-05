$(document).on("turbolinks:load", function() {

    $.each(['gas', 'electricity'], function (idx, supply) {

        $("#" + supply + "-first-date-picker").datepicker(
            {
                dateFormat: 'DD, d MM yy',
                altFormat: 'yy-mm-dd',
                altField: $("#" + supply + "-first-date"),
                maxDate: -1,
                orientation: 'bottom',
                changeMonth: true,
                changeYear: true
            });

        $("#" + supply + "-to-date-picker").datepicker(
            {
                dateFormat: 'DD, d MM yy',
                altFormat: 'yy-mm-dd',
                altField: $("#" + supply + "-to-date"),
                maxDate: -1,
                orientation: 'bottom',
                changeMonth: true,
                changeYear: true
            });

    });


});

function updateChart(el) {
    chart_id = el.form.id.replace("-filter", "");
    chart = Chartkick.charts[chart_id];
    current_source = chart.getDataSource();
    new_source = current_source.split("?")[0] + "?" + $(el.form).serialize();
    chart.updateData(new_source);
    chart.getChartObject().showLoading();
}
$(document).on('change', '.meter-filter', function() {
    updateChart(this);
});
$(document).on('change', '.date-picker', function() {
    updateChart(this);
});

