
CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.current_target, Float, true, :benchmark),
      format_unit(result.current_year_percent_of_target_relative * 100, Float, true, :benchmark),
      format_unit(result.current_year_target_kwh, Float, true, :benchmark),
      format_unit(result.current_year_kwh, Float, true, :benchmark),
      result.tracking_start_date.iso8601
    ]
  end
end.html_safe
