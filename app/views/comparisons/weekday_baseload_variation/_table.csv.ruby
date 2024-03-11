# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.percent_intraday_variation * 100, Float, true, :benchmark),
      format_unit(result.min_day_kw, Float, true, :benchmark),
      format_unit(result.max_day_kw, Float, true, :benchmark),
      I18n.t('date.day_names')[result.min_day],
      I18n.t('date.day_names')[result.max_day],
      format_unit(result.annual_cost_gbpcurrent, Float, true, :benchmark)
    ]
  end
end.html_safe
