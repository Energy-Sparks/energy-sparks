CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers

  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.last_year_kwh, Float),
      format_unit(result.last_year_gbp, Float),
      format_unit(result.last_year_co2, Float),
      format_unit(result.one_year_electricity_per_pupil_kwh, Float),
      format_unit(result.one_year_electricity_per_pupil_gbp, Float),
      format_unit(result.one_year_electricity_per_pupil_co2, Float),
      format_unit(result.one_year_saving_versus_exemplar_gbpcurrent, Float),
    ]
  end
end.html_safe
