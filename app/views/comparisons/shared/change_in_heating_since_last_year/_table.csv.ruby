# frozen_string_literal: true

CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.previous_year_kwh, Float),
      format_unit(result.temperature_adjusted_previous_year_kwh, Float),
      format_unit(result.current_year_kwh, Float),
      format_unit(result.previous_year_co2, Float),
      format_unit(result.current_year_co2, Float),
      format_unit(result.previous_year_gbp, Float),
      format_unit(result.current_year_gbp, Float),
      format_csv_percent_change(result.previous_year_kwh, result.current_year_kwh),
      format_unit(result.temperature_adjusted_percent, Float)
    ]
  end
end.html_safe
