CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.annual_saving_1_C_change_gbp, Float)
    ]
  end
end.html_safe
