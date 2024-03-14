CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.schoolday_open_percent * 100, Float, true, :benchmark),
      format_unit(result.schoolday_closed_percent * 100, Float, true, :benchmark),
      format_unit(result.holidays_percent * 100, Float, true, :benchmark),
      format_unit(result.weekends_percent * 100, Float, true, :benchmark),
      format_unit(result.weekend_and_holiday_gbp, Float, true, :benchmark)
    ]
  end
end.html_safe
