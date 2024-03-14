CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.one_year_electricity_per_pupil_kwh, Float, true, :benchmark),
      format_unit(result.one_year_gas_per_pupil_kwh, Float, true, :benchmark),
      format_unit(result.one_year_storage_heater_per_pupil_kwh, Float, true, :benchmark),

      format_unit(sum_data(result.kwhs), Float, true, :benchmark),
      format_unit(sum_data(result.costs), Float, true, :benchmark),
      format_unit(sum_data(result.co2s), Float, true, :benchmark),

      I18n.t("common.school_types.#{result.school.school_type}")

    ]
  end
end.html_safe
