CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.w_floor_area'),
    t('analytics.benchmarking.configuration.column_headings.average_peak_kw'),
    t('analytics.benchmarking.configuration.column_headings.exemplar_peak_kw'),
    t('analytics.benchmarking.configuration.column_headings.saving_if_match_exemplar_£')
  ]
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.average_school_day_last_year_kw_per_floor_area * 1000.0, Float, true, :benchmark),
      format_unit(result.average_school_day_last_year_kw, Float, true, :benchmark),
      format_unit(result.exemplar_kw, Float, true, :benchmark),
      format_unit(result.one_year_saving_versus_exemplar_gbp, Float, true, :benchmark),
    ]
  end
end.html_safe