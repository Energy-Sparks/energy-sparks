CSV.generate do |csv|
  # headers
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.size_kwp'),
    t('analytics.benchmarking.configuration.column_headings.payback_years'),
    t('analytics.benchmarking.configuration.column_headings.reduction_in_mains_consumption_pct'),
    t('analytics.benchmarking.configuration.column_headings.saving_optimal_panels')
  ]
  @results.each do |row|
    csv << [
      row.school.name,
      format_unit(row.optimum_kwp, Float , true, :benchmark),
      format_unit(row.optimum_payback_years, Float, true, :benchmark),
      format_unit(row.optimum_mains_reduction_percent * 100, Float, true, :benchmark),
      format_unit(row.one_year_saving_gbpcurrent, Float, true, :benchmark)
    ]
  end
end.html_safe
