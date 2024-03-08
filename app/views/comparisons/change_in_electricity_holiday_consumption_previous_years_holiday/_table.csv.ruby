# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.difference_percent * 100, Float, true, :benchmark),
      format_unit(result.difference_gbpcurrent, Float, true, :benchmark),
      format_unit(result.difference_kwh, Float, true, :benchmark),
      holiday_name(result.current_period_type, result.current_period_start_date, result.current_period_end_date,
                   partial: result.truncated_current_period),
      holiday_name(result.previous_period_type, result.previous_period_start_date, result.previous_period_end_date)
    ]
  end
end.html_safe
