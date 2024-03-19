CSV.generate do |csv|
  # headers
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.avg_gas_per_pupil_gbp, Float, true, :benchmark),
      format_unit(result.benchmark_existing_gas_efficiency * 100, Float, true, :benchmark),
      format_unit(result.benchmark_gas_better_control_saving_gbp, Float, true, :benchmark),
      format_unit(result.benchmark_point_of_use_electric_saving_gbp, Float, true, :benchmark),
    ]
  end
end.html_safe
