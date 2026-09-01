CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.last_year_electricity, Float),
      format_unit(result.last_year_gas, Float),
      format_unit(result.last_year_storage_heaters, Float),
      format_unit(result.last_year_gbp, Float),
      format_unit(result.one_year_energy_per_pupil_gbp, Float),
      format_unit(result.last_year_co2_tonnes, Float),
      format_unit(result.last_year_kwh, Float),
      result.school_type_name,
      format_unit(result.pupils, :pupils),
      format_unit(result.floor_area, Float)
    ]
  end
end.html_safe
