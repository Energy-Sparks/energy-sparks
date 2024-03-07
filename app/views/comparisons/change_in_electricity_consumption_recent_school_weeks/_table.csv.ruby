CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.change_pct'),
    t('analytics.benchmarking.configuration.column_headings.change_£current'),
    t('analytics.benchmarking.configuration.column_headings.change_kwh')
  ]

  @results.each do |result|
    csv << [result.school.name,
            format_unit(result.difference_percent * 100, Float, true, :benchmark),
            format_unit(result.difference_gbpcurrent, Float, true, :benchmark),
            format_unit(result.difference_kwh, Float, true, :benchmark)]
  end
end.html_safe
