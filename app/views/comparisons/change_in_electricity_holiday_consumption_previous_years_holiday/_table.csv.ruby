# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
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
