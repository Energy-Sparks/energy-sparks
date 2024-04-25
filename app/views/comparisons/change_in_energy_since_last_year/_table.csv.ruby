CSV.generate do |csv|
  csv << [
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.metering'),
    I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.cost'),
    "",
    "",
    ""
  ]
  csv << @headers
  @results.each do |result|
    fields = [result.school.name]

    fields << result.fuel_type_names

    %i[kwh co2 £].each do |unit|
      fields << format_unit(
              sum_if_complete(result.all_previous_period(unit: unit), result.all_current_period(unit: unit)
              ), Float, true, :benchmark)
      fields << format_unit( sum_data(result.all_current_period(unit: unit)), Float, true, :benchmark)
      fields << format_unit( percent_change(
                      sum_if_complete( result.all_previous_period(unit: unit), result.all_current_period(unit: unit) ),
                      sum_data(result.all_current_period(unit: unit))), Float, true, :benchmark)
    end

    no_recent_data = (result.school.has_electricity? && result.electricity_current_period_kwh.nil? ||
                      result.school.has_gas? && result.gas_current_period_kwh.nil?) ? 'Y' : ''
    fields << no_recent_data

    csv << fields
  end
end.html_safe
