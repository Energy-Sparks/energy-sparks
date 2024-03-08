CSV.generate do |csv|
  # headers
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school')
  ]
  @results.each do |row|
    csv << [
      row.school.name
    ]
  end
end.html_safe
