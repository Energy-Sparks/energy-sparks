# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
  @results.order(avg_week_start_time: :desc).each do |result|
    csv << [
      result.school.name,
      result.avg_week_start_time_to_time_of_day,
      result.average_start_time_hh_mm_to_time_of_day,
      format_unit(result.one_year_optimum_start_saving_gbpcurrent, Float, true, :benchmark)
    ]
  end
end.html_safe
