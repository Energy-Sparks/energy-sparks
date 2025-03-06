CSV.generate do |csv|
  csv << @headers

  @results.each do |result|
    csv << [result.school.name,
        format_unit(result.one_year_baseload_per_pupil_kw * 1000.0, Float, true, :benchmark),
        format_unit(result.average_baseload_last_year_gbp, Float, true, :benchmark),
        format_unit(result.average_baseload_last_year_kw, Float, true, :benchmark),
        format_unit(result.annual_baseload_percent * 100, Float, true, :benchmark),
        format_unit([0.0, result.one_year_saving_versus_exemplar_gbp].max, Float, true, :benchmark)
       ]
  end
end.html_safe
