CSV.generate do |csv|
  csv << [
    "", "",
    t('analytics.benchmarking.configuration.column_groups.kwh'),
    "",
    "",
    "",
    t('analytics.benchmarking.configuration.column_groups.co2_kg'),
    "",
    "",
    t('analytics.benchmarking.configuration.column_groups.gbp'),
    "",
    ""
  ]
  csv << @heating_headers
  @results.each do |result|
    csv << [
      result.school.name,
      result.activation_date.iso8601,
      format_unit(result.gas_previous_period_kwh_unadjusted, Float, true, :benchmark),
      format_unit(result.gas_previous_period_kwh, Float, true, :benchmark),
      format_unit(result.gas_current_period_kwh, Float, true, :benchmark),
      format_unit(percent_change(result.gas_previous_period_kwh, result.gas_current_period_kwh) * 100, Float, true, :benchmark),
      format_unit(result.gas_previous_period_co2, Float, true, :benchmark),
      format_unit(result.gas_current_period_co2, Float, true, :benchmark),
      format_unit(percent_change(result.gas_previous_period_co2, result.gas_current_period_co2) * 100, Float, true, :benchmark),
      format_unit(result.gas_previous_period_gbp, Float, true, :benchmark),
      format_unit(result.gas_current_period_gbp, Float, true, :benchmark),
      format_unit(percent_change(result.gas_previous_period_gbp, result.gas_current_period_gbp) * 100, Float, true, :benchmark)
    ]
  end
end.html_safe
