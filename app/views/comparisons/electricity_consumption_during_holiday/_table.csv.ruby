CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.projected_usage_by_end_of_holiday'),
    t('analytics.benchmarking.configuration.column_headings.holiday_usage_to_date'),
    t('analytics.benchmarking.configuration.column_headings.holiday')
  ]

  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.holiday_projected_usage_gbp, Float, true, :benchmark),
      format_unit(result.holiday_usage_to_date_gbp, Float, true, :benchmark),
      result.holiday_name
    ]
  end
end.html_safe
