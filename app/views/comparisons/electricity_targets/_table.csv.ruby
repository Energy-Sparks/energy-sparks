CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.percent_above_or_below_target_since_target_set'),
    t('analytics.benchmarking.configuration.column_headings.percent_above_or_below_last_year'),
    t('analytics.benchmarking.configuration.column_headings.kwh_consumption_since_target_set'),
    t('analytics.benchmarking.configuration.column_headings.target_kwh_consumption'),
    t('analytics.benchmarking.configuration.column_headings.last_year_kwh_consumption'),
    t('analytics.benchmarking.configuration.column_headings.start_date_for_target')
  ]

  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.current_year_percent_of_target_relative * 100, Float, true, :benchmark),
      format_unit(result.current_year_unscaled_percent_of_target_relative * 100, Float, true, :benchmark),
      format_unit(result.current_year_kwh, Float, true, :benchmark),
      format_unit(result.current_year_target_kwh, Float, true, :benchmark),
      format_unit(result.unscaled_target_kwh_to_date, Float, true, :benchmark),
      result.tracking_start_date.iso8601
    ]
  end
end.html_safe