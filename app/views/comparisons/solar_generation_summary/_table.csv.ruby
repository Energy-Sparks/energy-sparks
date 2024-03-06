CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.solar_generation'),
    t('analytics.benchmarking.configuration.column_headings.solar_self_consume'),
    t('analytics.benchmarking.configuration.column_headings.solar_export'),
    t('analytics.benchmarking.configuration.column_headings.solar_mains_consume'),
    t('analytics.benchmarking.configuration.column_headings.solar_mains_onsite')
  ]
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.annual_solar_pv_kwh, Float, true, :benchmark),
      format_unit(result.annual_solar_pv_consumed_onsite_kwh, Float, true, :benchmark),
      format_unit(result.annual_exported_solar_pv_kwh, Float, true, :benchmark),
      format_unit(result.annual_mains_consumed_kwh, Float, true, :benchmark),
      format_unit(result.annual_electricity_kwh, Float, true, :benchmark)
    ]
  end
end.html_safe
