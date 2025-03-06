# frozen_string_literal: true

CSV.generate do |csv|
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.holiday_projected_usage_gbp, Float, true, :benchmark),
      format_unit(result.holiday_usage_to_date_gbp, Float, true, :benchmark),
      holiday_name(result.holiday_type, result.holiday_start_date, result.holiday_end_date)
    ]
  end
end.html_safe
