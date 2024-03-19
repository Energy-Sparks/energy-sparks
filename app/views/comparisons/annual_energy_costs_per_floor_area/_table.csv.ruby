CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      I18n.t("common.school_types.#{result.school.school_type}"),
      format_unit(result.one_year_electricity_per_floor_area_kwh, Float, true, :benchmark),
      format_unit(result.one_year_gas_per_floor_area_kwh, Float, true, :benchmark),
      format_unit(result.one_year_storage_heater_per_floor_area_kwh, Float, true, :benchmark),

      format_unit(sum_data(result.floor_area_kwhs), Float, true, :benchmark),
      format_unit(sum_data(result.floor_area_costs), Float, true, :benchmark),
      format_unit(sum_data(result.floor_area_co2s), Float, true, :benchmark),
      format_unit(result.floor_area, Float, true, :benchmark)
    ]
  end
end.html_safe
