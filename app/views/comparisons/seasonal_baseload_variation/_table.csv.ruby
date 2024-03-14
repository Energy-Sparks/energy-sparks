# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
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
