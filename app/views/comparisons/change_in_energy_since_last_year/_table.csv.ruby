CSV.generate do |csv|
  csv << [
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
    I18n.t('analytics.benchmarking.configuration.column_groups.metering'),
    ""
  ]
  csv << @headers
  @results.each do |result|
    fields = [result.school.name]

    %i[kwh co2 £].each do |unit|
      fields << format_unit(
              sum_if_complete(result.all_previous_year(unit: unit), result.all_current_year(unit: unit)
              ), Float, true, :benchmark)
      fields << format_unit( sum_data(result.all_current_year(unit: unit)), Float, true, :benchmark)
      fields << format_unit( percent_change(
                      sum_if_complete( result.all_previous_year(unit: unit), result.all_current_year(unit: unit) ),
                      sum_data(result.all_current_year(unit: unit))), Float, true, :benchmark)
    end

    fields << [ result.current_year_electricity_kwh.nil? ? nil : 'E',
                result.current_year_gas_kwh.nil? ? nil : 'G',
                result.current_year_storage_heaters_kwh.nil? ? nil : 'SH',
                result.solar_type == '' ? nil : (result.solar_type == 'synthetic' ? 's' : 'S')
               ].compact.join(' + ')

    no_recent_data = (result.school.has_electricity? && result.current_year_electricity_kwh.nil? ||
                      result.school.has_gas? && result.current_year_gas_kwh.nil?) ? 'Y' : ''
    fields << no_recent_data

    csv << fields
  end
end.html_safe
