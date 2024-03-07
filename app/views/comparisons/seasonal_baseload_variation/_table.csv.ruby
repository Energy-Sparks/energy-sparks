# frozen_string_literal: true

CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.percent_increase_on_winter_baseload_over_summer'),
    t('analytics.benchmarking.configuration.column_headings.summer_baseload_kw'),
    t('analytics.benchmarking.configuration.column_headings.winter_baseload_kw'),
    t('analytics.benchmarking.configuration.column_headings.saving_if_same_all_year_around')
  ]
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.percent_seasonal_variation * 100, Float, true, :benchmark),
      format_unit(result.summer_kw, Float, true, :benchmark),
      format_unit(result.winter_kw, Float, true, :benchmark),
      format_unit(result.annual_cost_gbpcurrent, Float, true, :benchmark)
    ]
  end
end.html_safe
