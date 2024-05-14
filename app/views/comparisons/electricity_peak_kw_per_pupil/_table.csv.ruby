CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.average_school_day_last_year_kw_per_floor_area * 1000.0, Float, true, :benchmark),
      format_unit(result.average_school_day_last_year_kw, Float, true, :benchmark),
      format_unit(result.exemplar_kw, Float, true, :benchmark),
      format_unit(result.one_year_saving_versus_exemplar_gbp, Float, true, :benchmark),
    ]
  end
end.html_safe
