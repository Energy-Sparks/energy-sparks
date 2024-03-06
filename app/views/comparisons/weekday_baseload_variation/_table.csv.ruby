# frozen_string_literal: true

CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.variation_in_baseload_between_days_of_week'),
    t('analytics.benchmarking.configuration.column_headings.min_average_weekday_baseload_kw'),
    t('analytics.benchmarking.configuration.column_headings.max_average_weekday_baseload_kw'),
    t('analytics.benchmarking.configuration.column_headings.day_of_week_with_minimum_baseload'),
    t('analytics.benchmarking.configuration.column_headings.day_of_week_with_maximum_baseload'),
    t('analytics.benchmarking.configuration.column_headings.potential_saving')
  ]
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.percent_intraday_variation * 100, Float, true, :benchmark),
      format_unit(result.min_day_kw,  Float, true, :benchmark),
      format_unit(result.max_day_kw,  Float, true, :benchmark),
      result.min_day_str,
      result.max_day_str,
      format_unit(result.annual_cost_gbpcurrent, Float, true, :benchmark)
    ]
  end
end.html_safe
