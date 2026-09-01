CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.schoolday_open_percent * 100, Float),
      format_unit(result.schoolday_closed_percent * 100, Float),
      format_unit(result.holidays_percent * 100, Float),
      format_unit(result.weekends_percent * 100, Float),
      format_unit(result.community_percent * 100, Float),
      format_unit(result.community_gbp, Float),
      format_unit(result.out_of_hours_gbp, Float),
      format_unit(result.potential_saving_gbp, Float)
    ]
  end
end.html_safe
