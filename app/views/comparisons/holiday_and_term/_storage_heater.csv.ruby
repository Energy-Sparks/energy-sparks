CSV.generate do |csv|
  csv << csv_colgroups(@heating_colgroups)
  csv << @heating_headers
  @results.each do |result|
    next if result.storage_heater_current_period_kwh.blank?
    csv << [
      result.school.name,
      result.activation_date.iso8601,
      holiday_name(result.storage_heater_current_period_type, result.storage_heater_current_period_start_date, result.storage_heater_current_period_end_date,
                   partial: result.storage_heater_truncated_current_period),
      @include_previous_period_unadjusted && format_unit(result.storage_heater_previous_period_kwh_unadjusted, Float, true, :benchmark),
      format_unit(result.storage_heater_previous_period_kwh, Float, true, :benchmark),
      format_unit(result.storage_heater_current_period_kwh, Float, true, :benchmark),
      format_unit(percent_change(result.storage_heater_previous_period_kwh, result.storage_heater_current_period_kwh) * 100, Float, true, :benchmark),
      format_unit(result.storage_heater_previous_period_co2, Float, true, :benchmark),
      format_unit(result.storage_heater_current_period_co2, Float, true, :benchmark),
      format_unit(percent_change(result.storage_heater_previous_period_co2, result.storage_heater_current_period_co2) * 100, Float, true, :benchmark),
      format_unit(result.storage_heater_previous_period_gbp, Float, true, :benchmark),
      format_unit(result.storage_heater_current_period_gbp, Float, true, :benchmark),
      format_unit(percent_change(result.storage_heater_previous_period_gbp, result.storage_heater_current_period_gbp) * 100, Float, true, :benchmark)
    ].select(&:itself)
  end
end.html_safe
