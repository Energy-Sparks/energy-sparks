CSV.generate do |csv|
  csv << @headers

  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.holiday_projected_usage_gbp, Float, true, :benchmark),
      format_unit(result.holiday_usage_to_date_gbp, Float, true, :benchmark),
      result.holiday_name
    ]
  end
end.html_safe
