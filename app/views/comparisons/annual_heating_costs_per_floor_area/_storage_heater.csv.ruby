CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers

  @results.each do |result|
    next unless result.storage_heaters_last_year_kwh != nil
    csv << [
      result.school.name,
      format_unit(result.storage_heaters_last_year_kwh, Float, true, :benchmark),
      format_unit(result.storage_heaters_last_year_gbp, Float, true, :benchmark),
      format_unit(result.storage_heaters_last_year_co2, Float, true, :benchmark),
      format_unit(result.one_year_storage_heaters_per_floor_area_kwh, Float, true, :benchmark),
      format_unit(result.one_year_storage_heaters_per_floor_area_gbp, Float, true, :benchmark),
      format_unit(result.one_year_storage_heaters_per_floor_area_co2, Float, true, :benchmark),
      format_unit(result.saving_or_nil(:one_year_storage_heaters_saving_versus_exemplar_gbpcurrent), Float, true, :benchmark),
    ]
  end
end.html_safe
