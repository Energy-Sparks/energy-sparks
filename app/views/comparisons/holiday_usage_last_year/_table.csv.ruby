CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.last_year_holiday_gas_gbp, Float),
      format_unit(result.last_year_holiday_electricity_gbp, Float),
      format_unit(result.last_year_holiday_gas_gbpcurrent, Float),
      format_unit(result.last_year_holiday_electricity_gbpcurrent, Float),
      format_unit(result.last_year_holiday_gas_kwh_per_floor_area, Float),
      format_unit(result.last_year_holiday_electricity_kwh_per_floor_area, Float),
      holiday_name(result.last_year_holiday_type, result.last_year_holiday_start_date, result.last_year_holiday_end_date)
    ]
  end
end.html_safe
