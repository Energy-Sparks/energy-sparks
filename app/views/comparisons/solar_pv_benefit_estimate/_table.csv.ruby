CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.optimum_kwp, Float),
      format_unit(result.optimum_payback_years, Float),
      format_unit(result.optimum_mains_reduction_percent * 100, Float),
      format_unit(result.one_year_saving_gbpcurrent, Float)
    ]
  end
end.html_safe
