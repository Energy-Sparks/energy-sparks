CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      I18n.t("common.school_types.#{result.school.school_type}"),
      format_unit(result.one_year_electricity_per_pupil_kwh, Float),
      format_unit(result.one_year_gas_per_pupil_kwh, Float),
      format_unit(result.one_year_storage_heater_per_pupil_kwh, Float),

      format_unit(sum_data(result.pupil_kwhs), Float),
      format_unit(sum_data(result.pupil_costs), Float),
      format_unit(sum_data(result.pupil_co2s), Float),
      format_unit(result.pupils, Float)
    ]
  end
end.html_safe
