CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w'),
    t('analytics.benchmarking.configuration.column_headings.last_year_cost_of_baseload'),
    t('analytics.benchmarking.configuration.column_headings.average_baseload_kw'),
    t('analytics.benchmarking.configuration.column_headings.baseload_percent'),
    t('analytics.benchmarking.configuration.column_headings.saving_if_matched_exemplar_school')
  ]

  @results.each do |result|
    csv << [result.school.name,
        format_unit(result.one_year_baseload_per_pupil_kw * 1000.0, Float, true, :benchmark),
        format_unit(result.average_baseload_last_year_gbp, Float, true, :benchmark),
        format_unit(result.average_baseload_last_year_kw, Float, true, :benchmark),
        format_unit(result.annual_baseload_percent * 100, Float, true, :benchmark),
        format_unit([0.0, result.one_year_saving_versus_exemplar_gbp].max, Float, true, :benchmark)
       ]
  end
end.html_safe