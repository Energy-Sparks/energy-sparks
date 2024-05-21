CSV.generate do |csv|
  csv << [
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.electricity_consumption'),
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.gas_consumption'),
    "",
    "",
    I18n.t('analytics.benchmarking.configuration.column_groups.storage_heater_consumption'),
    "",
    "",
    "",
    "",
    ""
  ]

  csv << @headers
  @results.each do |result|
    recent = (gas_or_electricity_data_stale?(result) ? I18n.t('common.labels.no_label') : I18n.t('common.labels.yes_label'))

    csv << [
      result.school.name,
      recent,
      format_unit(result.electricity_last_year_kwh, Float, true, :benchmark),
      format_unit(result.electricity_last_year_gbp, Float, true, :benchmark),
      format_unit(result.electricity_last_year_co2, Float, true, :benchmark),
      format_unit(result.gas_last_year_kwh, Float, true, :benchmark),
      format_unit(result.gas_last_year_gbp, Float, true, :benchmark),
      format_unit(result.gas_last_year_co2, Float, true, :benchmark),
      format_unit(result.storage_heaters_last_year_kwh, Float, true, :benchmark),
      format_unit(result.storage_heaters_last_year_gbp, Float, true, :benchmark),
      format_unit(result.storage_heaters_last_year_co2, Float, true, :benchmark),
      result.school_type_name,
      format_unit(result.pupils, :pupils, true, :benchmark),
      format_unit(result.floor_area, Float, true, :benchmark)
    ]
  end
end.html_safe
