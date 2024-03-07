CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.school_day_open'),
    t('analytics.benchmarking.configuration.column_headings.school_day_closed'),
    t('analytics.benchmarking.configuration.column_headings.holiday'),
    t('analytics.benchmarking.configuration.column_headings.weekend'),
    t('analytics.benchmarking.configuration.column_headings.community'),
    t('analytics.benchmarking.configuration.column_headings.community_usage_cost'),
    t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_cost'),
    t('analytics.benchmarking.configuration.column_headings.saving_if_improve_to_exemplar')
  ]
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.schoolday_open_percent * 100, Float, true, :benchmark),
      format_unit(result.schoolday_closed_percent * 100, Float, true, :benchmark),
      format_unit(result.holidays_percent * 100, Float, true, :benchmark),
      format_unit(result.weekends_percent * 100, Float, true, :benchmark),
      format_unit(result.community_percent * 100, Float, true, :benchmark),
      format_unit(result.community_gbp, Float, true, :benchmark),
      format_unit(result.out_of_hours_gbp, Float, true, :benchmark),
      format_unit(result.potential_saving_gbp, Float, true, :benchmark)
    ]
  end
end.html_safe