CSV.generate do |csv|
  csv << [
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.metering'),
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.cost'),
    "",
    "",
  ]
  csv << @headers
  @results.each do |result|
    fields = [result.school.name]

    fields << result.fuel_type_names
    fields << (gas_or_electricity_data_stale?(result) ? I18n.t('common.labels.no_label') : I18n.t('common.labels.yes_label'))

    %i[kwh co2 £].each do |unit|
      fields << format_unit(
              sum_data(result.all_previous_period(unit: unit)), Float, true, :benchmark)
      fields << format_unit( sum_data(result.all_current_period(unit: unit)), Float, true, :benchmark)
      fields << format_unit( percent_change(
                      sum_data(result.all_previous_period(unit: unit)),
                      sum_data(result.all_current_period(unit: unit))
                      ), Float, true, :benchmark)
    end

    csv << fields
  end
end.html_safe
