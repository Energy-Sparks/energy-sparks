CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.current_year_percent_of_target_relative * 100, Float, true, :benchmark),
      format_unit(result.current_year_unscaled_percent_of_target_relative * 100, Float, true, :benchmark),
      format_unit(result.current_year_kwh, Float, true, :benchmark),
      format_unit(result.current_year_target_kwh, Float, true, :benchmark),
      format_unit(result.unscaled_target_kwh_to_date, Float, true, :benchmark),
      format_unit(result.tracking_start_date, :date, true, :benchmark)
    ]
  end
end.html_safe
