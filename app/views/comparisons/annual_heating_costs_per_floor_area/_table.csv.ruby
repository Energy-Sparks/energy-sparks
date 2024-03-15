CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.one_year_gas_per_floor_area_normalised_gbp, Float, true, :benchmark),
      format_unit(result.last_year_gbp, Float, true, :benchmark),
      format_unit(result.one_year_saving_versus_exemplar_gbpcurrent, Float, true, :benchmark),
      format_unit(result.last_year_kwh, Float, true, :benchmark),
      format_unit(result.last_year_co2 / 1000, Float, true, :benchmark)
    ]
  end
end.html_safe
