CSV.generate do |csv|
  csv << @headers
  @results.each do |row|
    csv << [
      row.school.name,
      format_unit(row.optimum_kwp, Float , true, :benchmark),
      format_unit(row.optimum_payback_years, Float, true, :benchmark),
      format_unit(row.optimum_mains_reduction_percent * 100, Float, true, :benchmark),
      format_unit(row.one_year_saving_gbpcurrent, Float, true, :benchmark)
    ]
  end
end.html_safe
