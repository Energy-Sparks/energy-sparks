# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers_optimum_start_analysis
  @results.each do |result|
    csv << [
      result.school.name,
      result.average_start_time_hh_mm_to_time_of_day,
      format_unit(result.start_time_standard_devation, Float),
      format_unit(result.rating, Float),
      format_unit(result.regression_start_time, Float),
      format_unit(result.optimum_start_sensitivity, Float),
      format_unit(result.regression_r2, Float),
      result.avg_week_start_time_to_time_of_day,
    ]
  end
end.html_safe
