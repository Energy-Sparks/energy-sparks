CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.percent_of_annual_heating * 100, Float),
      format_unit(result.warm_weather_heating_days_all_days_kwh, Float),
      format_unit(result.warm_weather_heating_days_all_days_co2, Float),
      format_unit(result.warm_weather_heating_days_all_days_gbpcurrent, Float),
      format_unit(result.warm_weather_heating_days_all_days_days, Float)
    ]
  end
end.html_safe
