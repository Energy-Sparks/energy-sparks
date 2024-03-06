# frozen_string_literal: true

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
      format_unit(result.percent_intraday_variation * 100, Float, true, :benchmark),
      format_unit(result.min_day_kw,  Float, true, :benchmark),
      format_unit(result.max_day_kw,  Float, true, :benchmark),
      result.min_day_str,
      result.max_day_str,
      format_unit(result.annual_cost_gbpcurrent, :£, true, :benchmark)
    ]
  end
end.html_safe
