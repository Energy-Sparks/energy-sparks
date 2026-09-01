CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.annual_mains_consumed_kwh, Float),
      format_unit(result.annual_solar_pv_kwh, Float),
      format_unit(result.annual_solar_pv_consumed_onsite_kwh, Float),
      format_unit(result.annual_exported_solar_pv_kwh, Float),
      format_unit(result.annual_electricity_kwh, Float)
    ]
  end
end.html_safe
