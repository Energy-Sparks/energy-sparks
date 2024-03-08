CSV.generate do |csv|
  # headers
  csv << @headers

  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.one_year_electricity_per_pupil_gbp, Float, true, :benchmark),
      format_unit(result.last_year_gbp, Float, true, :benchmark),
      format_unit(result.one_year_saving_versus_exemplar_gbpcurrent, Float, true, :benchmark),
    ]
  end
end.html_safe
