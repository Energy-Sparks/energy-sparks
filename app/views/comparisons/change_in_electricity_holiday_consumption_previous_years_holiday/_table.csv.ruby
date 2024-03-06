# frozen_string_literal: true

CSV.generate do |csv|
  csv << [
    t('analytics.benchmarking.configuration.column_headings.school'),
    t('analytics.benchmarking.configuration.column_headings.change_pct'),
    t('analytics.benchmarking.configuration.column_headings.change_£current'),
    t('analytics.benchmarking.configuration.column_headings.change_kwh'),
    t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
    t('analytics.benchmarking.configuration.column_headings.previous_holiday')
  ]
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.difference_percent * 100, Float, true, :benchmark),
      format_unit(result.difference_gbpcurrent, Float, true, :benchmark),
      format_unit(result.difference_kwh, Float, true, :benchmark),
      t("analytics.holidays.#{result.current_period_type}", default: '') + \
      (result.truncated_current_period ? " #{t('advice_pages.tables.labels.partial')}" : ''),
      t("analytics.holidays.#{result.previous_period_type}", default: '')
    ]
  end
end.html_safe
