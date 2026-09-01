# frozen_string_literal: true

CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.last_year_gas_kwh, Float),
      format_unit(result.estimated_hot_water_gas_kwh, Float),
      format_unit(result.last_year_gas_kwh - result.estimated_hot_water_gas_kwh, Float),
      format_unit(result.estimated_hot_water_percentage, Float)
    ]
  end
end.html_safe
