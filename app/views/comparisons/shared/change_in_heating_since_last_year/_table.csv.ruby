# frozen_string_literal: true

CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.previous_year_kwh, Float, true, :benchmark),
      format_unit(result.temperature_adjusted_previous_year_kwh, Float, true, :benchmark),
      format_unit(result.current_year_kwh, Float, true, :benchmark),
      format_unit(result.previous_year_co2, Float, true, :benchmark),
      format_unit(result.current_year_co2, Float, true, :benchmark),
      format_unit(result.previous_year_gbp, Float, true, :benchmark),
      format_unit(result.current_year_gbp, Float, true, :benchmark),
      format_unit(percent_change(result.previous_year_kwh, result.current_year_kwh) * 100,
                  Float, true, :benchmark),
      format_unit(result.temperature_adjusted_percent, Float, true, :benchmark)
    ]
  end
end.html_safe
