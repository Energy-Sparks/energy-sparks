CSV.generate do |csv|
  csv << [
    "", "",
    t('analytics.benchmarking.configuration.column_groups.kwh'),
    "",
    "",
    t('analytics.benchmarking.configuration.column_groups.co2_kg'),
    "",
    "",
    t('analytics.benchmarking.configuration.column_groups.gbp'),
    "",
    ""
  ]
  csv << @electricity_headers
  @results.each do |result|
    next if result.electricity_current_period_kwh.blank?
    csv << [
      result.school.name,
      result.activation_date.iso8601,
      format_unit(result.electricity_previous_period_kwh, Float, true, :benchmark),
      format_unit(result.electricity_current_period_kwh, Float, true, :benchmark),
      format_unit(percent_change(result.electricity_previous_period_kwh, result.electricity_current_period_kwh) * 100, Float, true, :benchmark),
      format_unit(result.electricity_previous_period_co2, Float, true, :benchmark),
      format_unit(result.electricity_current_period_co2, Float, true, :benchmark),
      format_unit(percent_change(result.electricity_previous_period_co2, result.electricity_current_period_co2) * 100, Float, true, :benchmark),
      format_unit(result.electricity_previous_period_gbp, Float, true, :benchmark),
      format_unit(result.electricity_current_period_gbp, Float, true, :benchmark),
      format_unit(percent_change(result.electricity_previous_period_gbp, result.electricity_current_period_gbp) * 100, Float, true, :benchmark)
    ]
  end
end.html_safe
