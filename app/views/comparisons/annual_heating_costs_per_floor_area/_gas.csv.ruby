CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers

  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.gas_last_year_kwh, Float, true, :benchmark),
      format_unit(result.gas_last_year_gbp, Float, true, :benchmark),
      format_unit(result.gas_last_year_co2, Float, true, :benchmark),
      format_unit(result.one_year_gas_per_floor_area_kwh, Float, true, :benchmark),
      format_unit(result.one_year_gas_per_floor_area_gbp, Float, true, :benchmark),
      format_unit(result.one_year_gas_per_floor_area_co2, Float, true, :benchmark),
      format_unit(result.saving_or_nil(:one_year_gas_saving_versus_exemplar_gbpcurrent), Float, true, :benchmark),
    ]
  end
end.html_safe
