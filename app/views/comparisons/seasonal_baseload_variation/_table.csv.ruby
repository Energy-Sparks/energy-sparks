# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.percent_seasonal_variation * 100, Float),
      format_unit(result.summer_kw, Float),
      format_unit(result.winter_kw, Float),
      format_unit(result.annual_cost_gbpcurrent, Float)
    ]
  end
end.html_safe
