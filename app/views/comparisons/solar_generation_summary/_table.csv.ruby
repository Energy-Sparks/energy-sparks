CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.annual_solar_pv_kwh, Float, true, :benchmark),
      format_unit(result.annual_solar_pv_consumed_onsite_kwh, Float, true, :benchmark),
      format_unit(result.annual_exported_solar_pv_kwh, Float, true, :benchmark),
      format_unit(result.annual_mains_consumed_kwh, Float, true, :benchmark),
      format_unit(result.annual_electricity_kwh, Float, true, :benchmark)
    ]
  end
end.html_safe
