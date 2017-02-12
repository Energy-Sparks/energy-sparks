$(function() {
    $(document).on('change', '.meter-filter', function() {
        chart_id = this.form.id.replace("-filter", "");
        chart = Chartkick.charts[chart_id];
        current_source = chart.getDataSource();
        new_source = current_source.split("?")[0] + "?" + $(this.form).serialize();
        chart.updateData(new_source);
        chart.getChartObject().showLoading();
    });
});
