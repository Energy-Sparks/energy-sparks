CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [result.school.name,
            format_unit(result.difference_percent * 100, Float, true, :benchmark),
            format_unit(result.difference_gbpcurrent, Float, true, :benchmark),
            format_unit(result.difference_kwh, Float, true, :benchmark)]
  end
end.html_safe
