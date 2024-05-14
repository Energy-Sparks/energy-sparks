CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.predicted_percent_increase_in_usage * 100, Float, true, :benchmark),
      format_unit(result.average_baseload_last_year_kw, Float, true, :benchmark),
      format_unit(result.average_baseload_last_week_kw, Float, true, :benchmark),
      format_unit(result.change_in_baseload_kw, Float, true, :benchmark),
      format_unit(result.next_year_change_in_baseload_gbpcurrent, Float, true, :benchmark),
    ]
  end
end.html_safe
