$(document).on("turbolinks:load", function() {

    $("#first_date_picker").datepicker(
    {
        dateFormat: 'DD, d MM yy',
        altFormat: 'yy-mm-dd',
        altField: "#first_date",
//        minDate: -42,
        maxDate: -1,
        orientation: 'bottom'
    });

    $("#to_date_picker").datepicker(
        {
            dateFormat: 'DD, d MM yy',
            altFormat: 'yy-mm-dd',
            altField: "#to_date",
//            minDate: -42,
            maxDate: -1,
            orientation: 'bottom'
    });

    function updateChart(el) {
        console.log(el.id);
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
    $(document).on('change', '#first_date_picker', function() {
        updateChart(this);
    });
    $(document).on('change', '#to_date_picker', function() {
        updateChart(this);
    });

});
