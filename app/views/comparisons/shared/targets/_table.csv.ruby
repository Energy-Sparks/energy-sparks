
CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.current_target, Float, true, :benchmark),
      format_unit(result.previous_to_current_year_change * 100, Float, true, :benchmark),
      format_unit(result.current_year_target_kwh, Float, true, :benchmark),
      format_unit(result.current_year_kwh, Float, true, :benchmark),
      result.tracking_start_date.iso8601
    ]
  end
end.html_safe
