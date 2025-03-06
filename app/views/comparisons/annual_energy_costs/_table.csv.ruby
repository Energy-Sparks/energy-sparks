CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.last_year_electricity, Float, true, :benchmark),
      format_unit(result.last_year_gas, Float, true, :benchmark),
      format_unit(result.last_year_storage_heaters, Float, true, :benchmark),
      format_unit(result.last_year_gbp, Float, true, :benchmark),
      format_unit(result.one_year_energy_per_pupil_gbp, Float, true, :benchmark),
      format_unit(result.last_year_co2_tonnes, Float, true, :benchmark),
      format_unit(result.last_year_kwh, Float, true, :benchmark),
      result.school_type_name,
      format_unit(result.pupils, :pupils, true, :benchmark),
      format_unit(result.floor_area, Float, true, :benchmark)
    ]
  end
end.html_safe
