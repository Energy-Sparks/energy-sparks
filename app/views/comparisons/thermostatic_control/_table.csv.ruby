CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.r2, Float ),
      format_unit(result.potential_saving_gbp, Float)
    ]
  end
end.html_safe
